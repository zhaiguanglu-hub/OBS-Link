import Foundation
import AVFoundation

// MARK: - Streaming Configuration Models

/// Represents video resolution settings
struct VideoResolution: Identifiable, Codable, CaseIterable {
    let id = UUID()
    let width: Int
    let height: Int
    let name: String
    
    static let allCases: [VideoResolution] = [
        VideoResolution(width: 1280, height: 720, name: "720p (HD)"),
        VideoResolution(width: 1920, height: 1080, name: "1080p (FHD)"),
        VideoResolution(width: 2560, height: 1440, name: "1440p (QHD)"),
        VideoResolution(width: 3840, height: 2160, name: "4K (UHD)")
    ]
    
    var displayName: String {
        return name
    }
    
    var cgSize: CGSize {
        return CGSize(width: width, height: height)
    }
}

/// Represents frame rate settings
struct FrameRate: Identifiable, Codable, CaseIterable {
    let id = UUID()
    let value: Int
    let name: String
    
    static let allCases: [FrameRate] = [
        FrameRate(value: 24, name: "24 FPS"),
        FrameRate(value: 30, name: "30 FPS"),
        FrameRate(value: 60, name: "60 FPS")
    ]
    
    var displayName: String {
        return name
    }
}

/// Represents video bitrate settings
struct VideoBitrate: Identifiable, Codable, CaseIterable {
    let id = UUID()
    let value: Int
    let name: String
    
    static let allCases: [VideoBitrate] = [
        VideoBitrate(value: 1000, name: "1 Mbps"),
        VideoBitrate(value: 2500, name: "2.5 Mbps"),
        VideoBitrate(value: 5000, name: "5 Mbps"),
        VideoBitrate(value: 10000, name: "10 Mbps"),
        VideoBitrate(value: 0, name: "Auto")
    ]
    
    var displayName: String {
        return name
    }
}

/// Represents audio settings
struct AudioSettings: Codable {
    var sampleRate: Int = 44100
    var bitrate: Int = 128
    var channels: Int = 2
    
    static let `default` = AudioSettings()
}

/// Complete streaming configuration
struct StreamingConfiguration: Codable {
    var rtmpURL: String = ""
    var videoResolution: VideoResolution = .allCases[0] // 720p default
    var frameRate: FrameRate = .allCases[1] // 30fps default
    var videoBitrate: VideoBitrate = .allCases[2] // 5 Mbps default
    var audioSettings: AudioSettings = .default
    var cameraPosition: AVCaptureDevice.Position = .back
    var orientationLock: OrientationLock = .auto
    
    static let `default` = StreamingConfiguration()
}

/// Camera orientation lock settings
enum OrientationLock: String, CaseIterable, Codable {
    case auto = "auto"
    case portrait = "portrait"
    case landscape = "landscape"
    
    var displayName: String {
        switch self {
        case .auto: return "Auto"
        case .portrait: return "Portrait"
        case .landscape: return "Landscape"
        }
    }
}

// MARK: - Streaming State Models

/// Current streaming status
enum StreamingStatus: String, CaseIterable {
    case idle = "idle"
    case connecting = "connecting"
    case streaming = "streaming"
    case error = "error"
    case disconnected = "disconnected"
    
    var displayName: String {
        switch self {
        case .idle: return "Ready"
        case .connecting: return "Connecting..."
        case .streaming: return "Live"
        case .error: return "Error"
        case .disconnected: return "Disconnected"
        }
    }
    
    var isStreaming: Bool {
        return self == .streaming
    }
}

/// Real-time streaming statistics
struct StreamingStats: Codable {
    var currentBitrate: Int = 0
    var averageBitrate: Int = 0
    var droppedFrames: Int = 0
    var totalFrames: Int = 0
    var streamDuration: TimeInterval = 0
    var networkStatus: NetworkStatus = .unknown
    
    var frameDropRate: Double {
        guard totalFrames > 0 else { return 0 }
        return Double(droppedFrames) / Double(totalFrames) * 100
    }
}

/// Network connection status
enum NetworkStatus: String, Codable, CaseIterable {
    case unknown = "unknown"
    case wifi = "wifi"
    case cellular = "cellular"
    case disconnected = "disconnected"
    
    var displayName: String {
        switch self {
        case .unknown: return "Unknown"
        case .wifi: return "WiFi"
        case .cellular: return "Cellular"
        case .disconnected: return "Disconnected"
        }
    }
    
    var icon: String {
        switch self {
        case .unknown: return "questionmark.circle"
        case .wifi: return "wifi"
        case .cellular: return "antenna.radiowaves.left.and.right"
        case .disconnected: return "wifi.slash"
        }
    }
}

// MARK: - Preset Templates

/// Video preset template for quick configuration
struct VideoPreset: Identifiable, Codable {
    let id = UUID()
    var name: String
    var resolution: VideoResolution
    var frameRate: FrameRate
    var bitrate: VideoBitrate
    
    static let presets: [VideoPreset] = [
        VideoPreset(name: "Outdoor Smooth", resolution: .allCases[0], frameRate: .allCases[1], bitrate: .allCases[0]),
        VideoPreset(name: "Indoor HD", resolution: .allCases[1], frameRate: .allCases[1], bitrate: .allCases[2]),
        VideoPreset(name: "Gaming High FPS", resolution: .allCases[0], frameRate: .allCases[2], bitrate: .allCases[1]),
        VideoPreset(name: "Ultra Quality", resolution: .allCases[1], frameRate: .allCases[2], bitrate: .allCases[3])
    ]
}