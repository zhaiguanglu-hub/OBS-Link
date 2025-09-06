import Foundation
import CoreGraphics

final class SettingsViewModel: ObservableObject {
	// MARK: - Published settings
	@Published var rtmpURL: String { didSet { save() } }
	@Published var videoResolution: VideoResolution { didSet { save() } }
	@Published var videoFPS: Int { didSet { save() } }
	@Published var videoBitrateKbps: Int { didSet { save() } }
	@Published var audioSampleRateHz: Int { didSet { save() } }
	@Published var audioBitrateKbps: Int { didSet { save() } }
	@Published var isLandscapeLocked: Bool { didSet { save() } }

	// MARK: - Video Resolution
	enum VideoResolution: String, CaseIterable, Identifiable {
		case auto = "Auto"
		case p720 = "1280x720"
		case p1080 = "1920x1080"

		var id: String { rawValue }

		var size: CGSize? {
			switch self {
			case .auto: return nil
			case .p720: return CGSize(width: 1280, height: 720)
			case .p1080: return CGSize(width: 1920, height: 1080)
			}
		}
	}

	// MARK: - Defaults
	private struct Keys {
		static let rtmpURL = "settings.rtmpURL"
		static let videoResolution = "settings.videoResolution"
		static let videoFPS = "settings.videoFPS"
		static let videoBitrateKbps = "settings.videoBitrateKbps"
		static let audioSampleRateHz = "settings.audioSampleRateHz"
		static let audioBitrateKbps = "settings.audioBitrateKbps"
		static let isLandscapeLocked = "settings.isLandscapeLocked"
	}

	private let defaults = UserDefaults.standard

	init() {
		rtmpURL = defaults.string(forKey: Keys.rtmpURL) ?? ""
		if let raw = defaults.string(forKey: Keys.videoResolution), let res = VideoResolution(rawValue: raw) {
			videoResolution = res
		} else {
			videoResolution = .p720
		}
		let fps = defaults.integer(forKey: Keys.videoFPS)
		videoFPS = fps == 0 ? 30 : fps
		let vbr = defaults.integer(forKey: Keys.videoBitrateKbps)
		videoBitrateKbps = vbr == 0 ? 2500 : vbr
		let asr = defaults.integer(forKey: Keys.audioSampleRateHz)
		audioSampleRateHz = asr == 0 ? 48000 : asr
		let abr = defaults.integer(forKey: Keys.audioBitrateKbps)
		audioBitrateKbps = abr == 0 ? 128 : abr
		isLandscapeLocked = defaults.object(forKey: Keys.isLandscapeLocked) as? Bool ?? false
	}

	private func save() {
		defaults.set(rtmpURL, forKey: Keys.rtmpURL)
		defaults.set(videoResolution.rawValue, forKey: Keys.videoResolution)
		defaults.set(videoFPS, forKey: Keys.videoFPS)
		defaults.set(videoBitrateKbps, forKey: Keys.videoBitrateKbps)
		defaults.set(audioSampleRateHz, forKey: Keys.audioSampleRateHz)
		defaults.set(audioBitrateKbps, forKey: Keys.audioBitrateKbps)
		defaults.set(isLandscapeLocked, forKey: Keys.isLandscapeLocked)
	}
}