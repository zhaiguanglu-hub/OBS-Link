import Foundation
import AVFoundation

final class SettingsViewModel: ObservableObject {
	@Published var rtmpURLString: String {
		didSet { UserDefaults.standard.set(rtmpURLString, forKey: Keys.rtmpURLString) }
	}
	@Published var videoResolutionPreset: VideoResolutionPreset {
		didSet { UserDefaults.standard.set(videoResolutionPreset.rawValue, forKey: Keys.videoResolutionPreset) }
	}
	@Published var fps: Int {
		didSet { UserDefaults.standard.set(fps, forKey: Keys.fps) }
	}
	@Published var videoBitrateKbps: Int {
		didSet { UserDefaults.standard.set(videoBitrateKbps, forKey: Keys.videoBitrateKbps) }
	}
	@Published var audioSampleRate: AudioSampleRate {
		didSet { UserDefaults.standard.set(audioSampleRate.rawValue, forKey: Keys.audioSampleRate) }
	}
	@Published var audioBitrateKbps: Int {
		didSet { UserDefaults.standard.set(audioBitrateKbps, forKey: Keys.audioBitrateKbps) }
	}
	@Published var showStatsOverlay: Bool {
		didSet { UserDefaults.standard.set(showStatsOverlay, forKey: Keys.showStatsOverlay) }
	}
	@Published var tapToFocusEnabled: Bool {
		didSet { UserDefaults.standard.set(tapToFocusEnabled, forKey: Keys.tapToFocusEnabled) }
	}
	@Published var orientationLock: OrientationLock {
		didSet { UserDefaults.standard.set(orientationLock.rawValue, forKey: Keys.orientationLock) }
	}

	var preferredCameraPosition: AVCaptureDevice.Position { .back }

	init() {
		rtmpURLString = UserDefaults.standard.string(forKey: Keys.rtmpURLString) ?? "rtmp://live.example.com/app/streamkey"
		videoResolutionPreset = VideoResolutionPreset(rawValue: UserDefaults.standard.string(forKey: Keys.videoResolutionPreset) ?? "p720") ?? .p720
		fps = UserDefaults.standard.integer(forKey: Keys.fps)
		if fps == 0 { fps = 30 }
		videoBitrateKbps = UserDefaults.standard.integer(forKey: Keys.videoBitrateKbps)
		if videoBitrateKbps == 0 { videoBitrateKbps = 3500 }
		audioSampleRate = AudioSampleRate(rawValue: UserDefaults.standard.string(forKey: Keys.audioSampleRate) ?? "hz48000") ?? .hz48000
		audioBitrateKbps = UserDefaults.standard.integer(forKey: Keys.audioBitrateKbps)
		if audioBitrateKbps == 0 { audioBitrateKbps = 128 }
		showStatsOverlay = UserDefaults.standard.object(forKey: Keys.showStatsOverlay) as? Bool ?? true
		tapToFocusEnabled = UserDefaults.standard.object(forKey: Keys.tapToFocusEnabled) as? Bool ?? true
		orientationLock = OrientationLock(rawValue: UserDefaults.standard.string(forKey: Keys.orientationLock) ?? "auto") ?? .auto
	}

	private enum Keys {
		static let rtmpURLString = "rtmpURLString"
		static let videoResolutionPreset = "videoResolutionPreset"
		static let fps = "fps"
		static let videoBitrateKbps = "videoBitrateKbps"
		static let audioSampleRate = "audioSampleRate"
		static let audioBitrateKbps = "audioBitrateKbps"
		static let showStatsOverlay = "showStatsOverlay"
		static let tapToFocusEnabled = "tapToFocusEnabled"
		static let orientationLock = "orientationLock"
	}
}

enum VideoResolutionPreset: String, CaseIterable {
	case p720
	case p1080
	case max

	var displayName: String {
		switch self {
		case .p720: return "720p"
		case .p1080: return "1080p"
		case .max: return "设备最高"
		}
	}

	var sessionPresetString: String {
		switch self {
		case .p720: return AVCaptureSession.Preset.hd1280x720.rawValue
		case .p1080: return AVCaptureSession.Preset.hd1920x1080.rawValue
		case .max: return AVCaptureSession.Preset.high.rawValue
		}
	}
}

enum AudioSampleRate: String, CaseIterable {
	case hz44100
	case hz48000

	var displayName: String {
		switch self {
		case .hz44100: return "44.1 kHz"
		case .hz48000: return "48 kHz"
		}
	}

	var hz: Int {
		switch self {
		case .hz44100: return 44100
		case .hz48000: return 48000
		}
	}
}

enum OrientationLock: String, CaseIterable {
	case auto
	case portrait
	case landscape

	var displayName: String {
		switch self {
		case .auto: return "自动"
		case .portrait: return "竖屏"
		case .landscape: return "横屏"
		}
	}
}