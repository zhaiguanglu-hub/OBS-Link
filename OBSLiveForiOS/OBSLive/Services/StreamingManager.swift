import Foundation
import AVFoundation
import HaishinKit
import VideoToolbox
import Combine

enum StreamingState {
    case idle
    case connecting
    case streaming
    case disconnected
    case error(String)
}

class StreamingManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var state: StreamingState = .idle
    @Published var streamingDuration: TimeInterval = 0
    @Published var currentBitrate: Int = 0
    @Published var currentFPS: Double = 0
    @Published var isStreaming: Bool = false
    
    // MARK: - Streaming Components
    private var rtmpConnection = RTMPConnection()
    private var rtmpStream: RTMPStream!
    private var sharedObject: RTMPSharedObject!
    
    // MARK: - Timer
    private var streamingTimer: Timer?
    private var startTime: Date?
    
    // MARK: - Camera Properties
    var currentCamera: AVCaptureDevice.Position = .back
    
    override init() {
        super.init()
        setupStream()
    }
    
    private func setupStream() {
        rtmpStream = RTMPStream(connection: rtmpConnection)
        
        // Configure capture settings
        rtmpStream.captureSettings = [
            .sessionPreset: AVCaptureSession.Preset.hd1920x1080,
            .continuousAutofocus: true,
            .continuousExposure: true,
            .preferredVideoStabilizationMode: AVCaptureVideoStabilizationMode.auto
        ]
        
        // Attach camera and microphone
        attachCamera()
        attachAudio()
    }
    
    // MARK: - Camera Methods
    func attachCamera() {
        let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: currentCamera
        )
        rtmpStream.attachCamera(device) { error in
            print("Camera attach error: \(String(describing: error))")
        }
    }
    
    func switchCamera() {
        currentCamera = currentCamera == .back ? .front : .back
        attachCamera()
    }
    
    // MARK: - Audio Methods
    func attachAudio() {
        let device = AVCaptureDevice.default(for: .audio)
        rtmpStream.attachAudio(device) { error in
            print("Audio attach error: \(String(describing: error))")
        }
    }
    
    // MARK: - Video Configuration
    func configureVideo(resolution: VideoResolution, fps: Int, bitrate: Int) {
        rtmpStream.videoSettings = [
            .width: resolution.width,
            .height: resolution.height,
            .bitrate: bitrate * 1000, // Convert kbps to bps
            .profileLevel: kVTProfileLevel_H264_High_AutoLevel,
            .maxKeyFrameIntervalDuration: 2.0
        ]
        
        rtmpStream.captureSettings[.fps] = fps
    }
    
    // MARK: - Audio Configuration
    func configureAudio(sampleRate: Double, bitrate: Int) {
        rtmpStream.audioSettings = [
            .sampleRate: sampleRate,
            .bitrate: bitrate * 1000 // Convert kbps to bps
        ]
    }
    
    // MARK: - Streaming Control
    func startStreaming(serverURL: String, streamKey: String) {
        guard !isStreaming else { return }
        
        let fullURL = "\(serverURL)/\(streamKey)"
        
        state = .connecting
        
        // Set event handlers
        rtmpConnection.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        rtmpConnection.addEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
        
        // Connect to RTMP server
        rtmpConnection.connect(fullURL)
    }
    
    func stopStreaming() {
        guard isStreaming else { return }
        
        rtmpConnection.close()
        rtmpStream.close()
        
        isStreaming = false
        state = .idle
        
        // Stop timer
        streamingTimer?.invalidate()
        streamingTimer = nil
        streamingDuration = 0
        
        // Remove event listeners
        rtmpConnection.removeEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        rtmpConnection.removeEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
    }
    
    // MARK: - RTMP Event Handlers
    @objc private func rtmpStatusHandler(_ notification: Notification) {
        let event = Event.from(notification)
        guard let data = event.data as? ASObject, let code = data["code"] as? String else {
            return
        }
        
        switch code {
        case RTMPConnection.Code.connectSuccess.rawValue:
            rtmpStream.publish(nil) // Use default stream name
            
        case RTMPStream.Code.publishStart.rawValue:
            DispatchQueue.main.async { [weak self] in
                self?.isStreaming = true
                self?.state = .streaming
                self?.startStreamingTimer()
            }
            
        case RTMPConnection.Code.connectClosed.rawValue:
            DispatchQueue.main.async { [weak self] in
                self?.state = .disconnected
                self?.stopStreaming()
            }
            
        default:
            print("RTMP Status: \(code)")
        }
    }
    
    @objc private func rtmpErrorHandler(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.state = .error("Connection error occurred")
            self?.stopStreaming()
        }
    }
    
    // MARK: - Timer Methods
    private func startStreamingTimer() {
        startTime = Date()
        streamingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.streamingDuration = Date().timeIntervalSince(startTime)
            
            // Update stats
            self.updateStreamingStats()
        }
    }
    
    private func updateStreamingStats() {
        // Get current bitrate from stream
        if let info = rtmpStream.info {
            currentBitrate = Int(info.currentBytesOutPerSecond * 8 / 1000) // Convert to kbps
            currentFPS = info.currentFPS
        }
    }
    
    // MARK: - Preview Layer
    func previewLayer() -> AVCaptureVideoPreviewLayer? {
        return rtmpStream.layer
    }
}