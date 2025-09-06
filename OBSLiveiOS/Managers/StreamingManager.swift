import Foundation
import AVFoundation
import HaishinKit
import SwiftUI
import Combine

/// Main streaming manager that handles RTMP streaming using HaishinKit
@MainActor
class StreamingManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    @Published var isStreaming: Bool = false
    @Published var status: StreamingStatus = .idle
    @Published var stats: StreamingStats = StreamingStats()
    @Published var errorMessage: String?
    @Published var isCameraAuthorized: Bool = false
    @Published var isMicrophoneAuthorized: Bool = false
    
    // MARK: - Private Properties
    
    private var rtmpConnection: RTMPConnection?
    private var rtmpStream: RTMPStream?
    private var captureSession: AVCaptureSession?
    private var statsTimer: Timer?
    private var streamStartTime: Date?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Configuration
    
    private var currentConfiguration: StreamingConfiguration = .default
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupNotifications()
        checkPermissions()
    }
    
    deinit {
        stopStreaming()
        statsTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    /// Start streaming with the given configuration
    func startStreaming(with configuration: StreamingConfiguration) {
        guard !isStreaming else { return }
        
        currentConfiguration = configuration
        
        // Validate configuration
        guard validateConfiguration(configuration) else {
            updateStatus(.error, error: "Invalid streaming configuration")
            return
        }
        
        updateStatus(.connecting)
        
        Task {
            do {
                try await setupStreamingSession()
                try await startRTMPConnection()
                updateStatus(.streaming)
                startStatsMonitoring()
            } catch {
                updateStatus(.error, error: error.localizedDescription)
            }
        }
    }
    
    /// Stop the current stream
    func stopStreaming() {
        guard isStreaming else { return }
        
        updateStatus(.idle)
        stopStatsMonitoring()
        
        rtmpStream?.close()
        rtmpConnection?.close()
        
        rtmpStream = nil
        rtmpConnection = nil
        captureSession = nil
        
        streamStartTime = nil
    }
    
    /// Toggle camera position (front/back)
    func toggleCameraPosition() {
        let newPosition: AVCaptureDevice.Position = currentConfiguration.cameraPosition == .back ? .front : .back
        currentConfiguration.cameraPosition = newPosition
        updateCameraPosition(newPosition)
    }
    
    /// Update camera position
    func updateCameraPosition(_ position: AVCaptureDevice.Position) {
        currentConfiguration.cameraPosition = position
        
        guard let rtmpStream = rtmpStream else { return }
        
        Task {
            do {
                try await rtmpStream.attachCamera(DeviceUtil.device(withPosition: position))
            } catch {
                updateStatus(.error, error: "Failed to switch camera: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func validateConfiguration(_ config: StreamingConfiguration) -> Bool {
        guard !config.rtmpURL.isEmpty,
              config.rtmpURL.hasPrefix("rtmp://") else {
            return false
        }
        
        guard isCameraAuthorized && isMicrophoneAuthorized else {
            return false
        }
        
        return true
    }
    
    private func setupStreamingSession() async throws {
        // Create RTMP connection
        rtmpConnection = RTMPConnection()
        rtmpStream = RTMPStream(connection: rtmpConnection!)
        
        guard let rtmpStream = rtmpStream else {
            throw StreamingError.setupFailed
        }
        
        // Configure video settings
        rtmpStream.videoSettings = [
            .width: currentConfiguration.videoResolution.width,
            .height: currentConfiguration.videoResolution.height,
            .bitrate: currentConfiguration.videoBitrate.value,
            .profileLevel: kVTProfileLevel_H264_Baseline_AutoLevel,
            .maxKeyFrameIntervalDuration: 2.0
        ]
        
        // Configure audio settings
        rtmpStream.audioSettings = [
            .bitrate: currentConfiguration.audioSettings.bitrate * 1000,
            .sampleRate: Double(currentConfiguration.audioSettings.sampleRate),
            .channels: currentConfiguration.audioSettings.channels
        ]
        
        // Attach camera and microphone
        try await attachCamera()
        try await attachMicrophone()
    }
    
    private func attachCamera() async throws {
        guard let rtmpStream = rtmpStream else { return }
        
        let camera = DeviceUtil.device(withPosition: currentConfiguration.cameraPosition)
        try await rtmpStream.attachCamera(camera)
    }
    
    private func attachMicrophone() async throws {
        guard let rtmpStream = rtmpStream else { return }
        
        let microphone = AVCaptureDevice.default(for: .audio)
        try await rtmpStream.attachAudio(microphone)
    }
    
    private func startRTMPConnection() async throws {
        guard let rtmpConnection = rtmpConnection,
              let rtmpStream = rtmpStream else {
            throw StreamingError.connectionFailed
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            rtmpConnection.addEventListener(.rtmpStatus) { event in
                let data = event.data as! [String: Any]
                let code = data["code"] as! String
                
                switch code {
                case RTMPConnection.Code.connectSuccess.rawValue:
                    rtmpStream.publish(self.currentConfiguration.rtmpURL)
                    continuation.resume()
                    
                case RTMPConnection.Code.connectFailed.rawValue,
                     RTMPConnection.Code.connectClosed.rawValue:
                    continuation.resume(throwing: StreamingError.connectionFailed)
                    
                default:
                    break
                }
            }
            
            rtmpConnection.connect(self.currentConfiguration.rtmpURL)
        }
    }
    
    private func startStatsMonitoring() {
        streamStartTime = Date()
        statsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateStats()
        }
    }
    
    private func stopStatsMonitoring() {
        statsTimer?.invalidate()
        statsTimer = nil
    }
    
    private func updateStats() {
        guard let rtmpStream = rtmpStream,
              let startTime = streamStartTime else { return }
        
        let currentTime = Date()
        let duration = currentTime.timeIntervalSince(startTime)
        
        // Update basic stats
        stats.streamDuration = duration
        stats.currentBitrate = Int(rtmpStream.currentFPS * 1000) // Approximate
        stats.totalFrames = Int(rtmpStream.currentFPS * duration)
        
        // Update network status
        updateNetworkStatus()
    }
    
    private func updateNetworkStatus() {
        // This is a simplified implementation
        // In a real app, you'd use Network framework to get actual connection status
        stats.networkStatus = .wifi // Placeholder
    }
    
    private func updateStatus(_ newStatus: StreamingStatus, error: String? = nil) {
        status = newStatus
        isStreaming = newStatus == .streaming
        errorMessage = error
    }
    
    // MARK: - Permission Management
    
    private func checkPermissions() {
        checkCameraPermission()
        checkMicrophonePermission()
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraAuthorized = true
        case .notDetermined:
            requestCameraPermission()
        case .denied, .restricted:
            isCameraAuthorized = false
        @unknown default:
            isCameraAuthorized = false
        }
    }
    
    private func checkMicrophonePermission() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            isMicrophoneAuthorized = true
        case .notDetermined:
            requestMicrophonePermission()
        case .denied, .restricted:
            isMicrophoneAuthorized = false
        @unknown default:
            isMicrophoneAuthorized = false
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.isCameraAuthorized = granted
            }
        }
    }
    
    private func requestMicrophonePermission() {
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
            DispatchQueue.main.async {
                self?.isMicrophoneAuthorized = granted
            }
        }
    }
    
    // MARK: - Notifications
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func appDidEnterBackground() {
        // Optionally pause streaming when app goes to background
        // This depends on your app's requirements
    }
    
    @objc private func appWillEnterForeground() {
        // Resume streaming if needed
    }
}

// MARK: - Error Types

enum StreamingError: LocalizedError {
    case setupFailed
    case connectionFailed
    case cameraNotAvailable
    case microphoneNotAvailable
    case invalidConfiguration
    
    var errorDescription: String? {
        switch self {
        case .setupFailed:
            return "Failed to setup streaming session"
        case .connectionFailed:
            return "Failed to connect to streaming server"
        case .cameraNotAvailable:
            return "Camera is not available"
        case .microphoneNotAvailable:
            return "Microphone is not available"
        case .invalidConfiguration:
            return "Invalid streaming configuration"
        }
    }
}