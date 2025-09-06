//
//  StreamingManager.swift
//  OBSLive
//
//  Created by OBS Live Team
//

import Foundation
import AVFoundation
import HaishinKit
import Combine

/// 核心推流管理类，负责处理RTMP连接、视频编码和推流控制
@MainActor
class StreamingManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isStreaming = false
    @Published var connectionState: ConnectionState = .idle
    @Published var streamStats = StreamStats()
    @Published var lastError: Error?
    
    // MARK: - Private Properties
    private var rtmpConnection = RTMPConnection()
    private(set) var rtmpStream: RTMPStream!
    private var currentCamera: AVCaptureDevice?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Enums
    enum ConnectionState {
        case idle
        case connecting
        case connected
        case disconnected
    }
    
    // MARK: - Initialization
    init() {
        setupRTMPStream()
        setupObservers()
    }
    
    // MARK: - Public Methods
    
    /// 设置相机
    func setupCamera() {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("❌ 无法获取后置摄像头")
            return
        }
        
        currentCamera = camera
        rtmpStream.attachCamera(camera) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.lastError = error
                }
            }
        }
        
        // 设置音频
        rtmpStream.attachAudio(AVCaptureDevice.default(for: .audio)) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.lastError = error
                }
            }
        }
    }
    
    /// 开始推流
    func startStreaming(rtmpURL: String, settings: StreamSettings) {
        guard !rtmpURL.isEmpty else {
            lastError = StreamingError.invalidURL
            return
        }
        
        // 应用流设置
        applyStreamSettings(settings)
        
        // 连接RTMP服务器
        connectionState = .connecting
        
        rtmpConnection.connect(rtmpURL)
    }
    
    /// 停止推流
    func stopStreaming() {
        rtmpConnection.close()
        isStreaming = false
        connectionState = .idle
        resetStreamStats()
    }
    
    /// 切换摄像头
    func switchCamera() {
        guard !isStreaming else { return }
        
        let currentPosition = currentCamera?.position ?? .back
        let newPosition: AVCaptureDevice.Position = currentPosition == .back ? .front : .back
        
        guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else {
            print("❌ 无法获取\(newPosition == .front ? "前置" : "后置")摄像头")
            return
        }
        
        currentCamera = newCamera
        rtmpStream.attachCamera(newCamera) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.lastError = error
                }
            }
        }
    }
    
    /// 清除错误
    func clearError() {
        lastError = nil
    }
    
    // MARK: - Private Methods
    
    private func setupRTMPStream() {
        rtmpStream = RTMPStream(connection: rtmpConnection)
        
        // 设置默认视频配置
        rtmpStream.videoSettings.videoSize = CGSize(width: 1280, height: 720)
        rtmpStream.videoSettings.profileLevel = kVTProfileLevel_H264_Main_AutoLevel as String
        rtmpStream.videoSettings.bitRate = 2500 * 1000 // 2.5 Mbps
        rtmpStream.videoSettings.maxKeyFrameIntervalDuration = 2
        
        // 设置默认音频配置
        rtmpStream.audioSettings.bitRate = 128 * 1000 // 128 kbps
        rtmpStream.audioSettings.sampleRate = 44100
    }
    
    private func setupObservers() {
        // 监听连接状态变化
        rtmpConnection.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        rtmpConnection.addEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
        
        // 定时更新流统计信息
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateStreamStats()
            }
            .store(in: &cancellables)
    }
    
    @objc private func rtmpStatusHandler(_ notification: Notification) {
        guard let data = notification.userInfo as? [String: Any],
              let code = data["code"] as? String else { return }
        
        DispatchQueue.main.async {
            switch code {
            case RTMPConnection.Code.connectSuccess.rawValue:
                self.connectionState = .connected
                self.rtmpStream.publish("live") // 默认流名称
                self.isStreaming = true
                
            case RTMPConnection.Code.connectClosed.rawValue,
                 RTMPConnection.Code.connectFailed.rawValue:
                self.connectionState = .disconnected
                self.isStreaming = false
                
            default:
                break
            }
        }
    }
    
    @objc private func rtmpErrorHandler(_ notification: Notification) {
        DispatchQueue.main.async {
            self.connectionState = .disconnected
            self.isStreaming = false
            self.lastError = StreamingError.connectionFailed
        }
    }
    
    private func applyStreamSettings(_ settings: StreamSettings) {
        // 应用视频设置
        rtmpStream.videoSettings.videoSize = settings.resolution.cgSize
        rtmpStream.videoSettings.bitRate = settings.videoBitrate * 1000
        
        // 设置帧率
        if let camera = currentCamera {
            do {
                try camera.lockForConfiguration()
                camera.activeVideoMinFrameDuration = CMTime(value: 1, timescale: CMTimeScale(settings.frameRate))
                camera.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: CMTimeScale(settings.frameRate))
                camera.unlockForConfiguration()
            } catch {
                print("❌ 设置帧率失败: \(error)")
            }
        }
        
        // 应用音频设置
        rtmpStream.audioSettings.bitRate = settings.audioBitrate * 1000
        rtmpStream.audioSettings.sampleRate = Double(settings.sampleRate)
    }
    
    private func updateStreamStats() {
        guard isStreaming else { return }
        
        // 更新统计信息
        streamStats.currentBitrate = Int(rtmpStream.info.videoDataBytesOut / 1024) // KB/s
        streamStats.droppedFrames = rtmpStream.info.videoFrameDropCount
        streamStats.streamDuration += 1
        
        // 计算网络状态
        let currentTime = Date().timeIntervalSince1970
        if streamStats.lastUpdateTime > 0 {
            let timeDiff = currentTime - streamStats.lastUpdateTime
            let bytesDiff = rtmpStream.info.videoDataBytesOut - streamStats.lastBytesOut
            streamStats.networkSpeed = Int(Double(bytesDiff) / timeDiff / 1024) // KB/s
        }
        
        streamStats.lastUpdateTime = currentTime
        streamStats.lastBytesOut = rtmpStream.info.videoDataBytesOut
    }
    
    private func resetStreamStats() {
        streamStats = StreamStats()
    }
}

// MARK: - Supporting Types

/// 流统计信息
struct StreamStats {
    var currentBitrate: Int = 0 // KB/s
    var networkSpeed: Int = 0 // KB/s
    var droppedFrames: Int64 = 0
    var streamDuration: Int = 0 // 秒
    var lastUpdateTime: TimeInterval = 0
    var lastBytesOut: Int64 = 0
}

/// 流设置
struct StreamSettings {
    var resolution: VideoResolution = .hd720p
    var frameRate: Int = 30
    var videoBitrate: Int = 2500 // kbps
    var audioBitrate: Int = 128 // kbps
    var sampleRate: Int = 44100
}

/// 视频分辨率枚举
enum VideoResolution: String, CaseIterable {
    case sd480p = "480p (854x480)"
    case hd720p = "720p (1280x720)"
    case fhd1080p = "1080p (1920x1080)"
    
    var cgSize: CGSize {
        switch self {
        case .sd480p:
            return CGSize(width: 854, height: 480)
        case .hd720p:
            return CGSize(width: 1280, height: 720)
        case .fhd1080p:
            return CGSize(width: 1920, height: 1080)
        }
    }
    
    var recommendedBitrate: Int {
        switch self {
        case .sd480p:
            return 1000
        case .hd720p:
            return 2500
        case .fhd1080p:
            return 5000
        }
    }
}

/// 流错误类型
enum StreamingError: LocalizedError {
    case invalidURL
    case connectionFailed
    case encodingError
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的RTMP服务器地址"
        case .connectionFailed:
            return "连接服务器失败，请检查网络和服务器地址"
        case .encodingError:
            return "视频编码错误"
        case .permissionDenied:
            return "缺少相机或麦克风权限"
        }
    }
}