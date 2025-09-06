import Foundation
import Combine
import HaishinKit
import AVFoundation
import UIKit
import VideoToolbox

final class StreamingManager: ObservableObject {
	enum StreamState: Equatable {
		case idle
		case connecting
		case streaming
		case error(String)
	}

	@Published var state: StreamState = .idle
	@Published var cameraPosition: AVCaptureDevice.Position = .back
	@Published var elapsedSeconds: Int = 0

	private let connection = RTMPConnection()
	private var stream: RTMPStream?
	private var statsTimer: Timer?

	// Expose for preview attachment
	var rtmpStream: RTMPStream? { stream }

	// MARK: - Public API
	func startStreaming(url: String, settings: SettingsViewModel) {
		guard !url.isEmpty else { return }
		state = .connecting

		prepare(with: settings)

		let (endpoint, streamName) = Self.splitRTMP(url: url)
		connection.connect(endpoint)
		stream?.publish(streamName)

		startTimer()
		state = .streaming
		Haptics.success()
	}

	func stopStreaming() {
		statsTimer?.invalidate()
		statsTimer = nil
		stream?.close()
		stream?.dispose()
		connection.close()
		stream = nil
		elapsedSeconds = 0
		state = .idle
		Haptics.impact()
	}

	func switchCamera() {
		cameraPosition = cameraPosition == .back ? .front : .back
		attachCamera(position: cameraPosition)
		Haptics.impact(.medium)
	}

	func attachPreview(to view: HKView) {
		view.attachStream(stream)
	}

	// MARK: - Private
	private func prepare(with settings: SettingsViewModel) {
		let stream = RTMPStream(connection: connection)
		self.stream = stream

		// Capture
		var capture: [String: Any] = [:]
		capture["fps"] = settings.videoFPS
		capture["sessionPreset"] = Self.sessionPreset(for: settings.videoResolution)
		stream.captureSettings = capture

		// Video
		var video: [String: Any] = [:]
		if let size = settings.videoResolution.size {
			video["width"] = Int(size.width)
			video["height"] = Int(size.height)
		} else {
			video["width"] = 0
			video["height"] = 0
		}
		video["bitrate"] = settings.videoBitrateKbps * 1000
		video["maxKeyFrameIntervalDuration"] = 2
		video["profileLevel"] = kVTProfileLevel_H264_Baseline_4_0
		stream.videoSettings = video

		// Audio
		var audio: [String: Any] = [:]
		audio["sampleRate"] = settings.audioSampleRateHz
		audio["bitrate"] = settings.audioBitrateKbps * 1000
		stream.audioSettings = audio

		// Devices
		let audioDevice = AVCaptureDevice.default(for: .audio)
		stream.attachAudio(audioDevice)
		attachCamera(position: cameraPosition)
	}

	private func attachCamera(position: AVCaptureDevice.Position) {
		guard let stream = stream else { return }
		let device = DeviceUtil.device(withPosition: position)
		stream.attachCamera(device)
	}

	private func startTimer() {
		statsTimer?.invalidate()
		elapsedSeconds = 0
		statsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			self?.elapsedSeconds += 1
		}
	}

	static func splitRTMP(url: String) -> (String, String) {
		if let idx = url.lastIndex(of: "/"), idx != url.startIndex {
			let base = String(url[..<idx])
			let name = String(url[url.index(after: idx)...])
			return (base, name)
		}
		return (url, "live")
	}

	private static func sessionPreset(for resolution: SettingsViewModel.VideoResolution) -> AVCaptureSession.Preset {
		switch resolution {
		case .auto: return .high
		case .p720: return .hd1280x720
		case .p1080: return .hd1920x1080
		}
	}
}