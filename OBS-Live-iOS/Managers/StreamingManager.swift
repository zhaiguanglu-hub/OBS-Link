import Foundation
import Combine
import AVFoundation

#if canImport(HaishinKit)
import HaishinKit
#endif

final class StreamingManager: ObservableObject {
	@Published var isStreaming: Bool = false
	@Published var connectionState: String = "未连接"
	@Published var uploadBitrateKbps: Int = 0
	@Published var currentFps: Int = 0
	@Published var resolutionText: String = ""
	@Published var elapsedSeconds: Int = 0

	#if canImport(HaishinKit)
	private(set) var rtmpConnection: RTMPConnection?
	private(set) var rtmpStream: RTMPStream?
	#else
	var rtmpStream: Any? { nil }
	#endif

	private var statsTimer: Timer?

	func startStreaming(rtmpURLString: String, settings: SettingsViewModel) {
		stopStatsTimer()
		elapsedSeconds = 0
		connectionState = "连接中…"

		#if canImport(HaishinKit)
		let connection = RTMPConnection()
		let stream = RTMPStream(connection: connection)

		configure(stream: stream, with: settings)

		// Attach audio and video
		stream.attachAudio(AVCaptureDevice.default(for: .audio)) { _ in }

		let position: AVCaptureDevice.Position = settings.preferredCameraPosition
		if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) {
			stream.attachCamera(device) { _ in }
		}

		connection.addEventListener(Event.RTMP_STATUS, selector: #selector(rtmpStatusHandler(_:)), observer: self)

		let (connectURL, streamName) = splitRTMP(urlString: rtmpURLString) ?? (rtmpURLString, "live")
		connection.connect(connectURL)

		self.rtmpConnection = connection
		self.rtmpStream = stream
		self.isStreaming = true
		self.connectionState = "连接中…"
		#else
		// Fallback simulation
		isStreaming = true
		connectionState = "直播中（模拟）"
		startStatsTimer(simulated: true)
		#endif
	}

	func stopStreaming() {
		#if canImport(HaishinKit)
		rtmpStream?.close()
		rtmpStream?.dispose()
		rtmpConnection?.close()
		rtmpConnection = nil
		rtmpStream = nil
		#endif
		isStreaming = false
		connectionState = "已断开"
		stopStatsTimer()
	}

	func switchCamera() {
		#if canImport(HaishinKit)
		guard let stream = rtmpStream else { return }
		stream.swapCamera()
		#endif
	}

	#if canImport(HaishinKit)
	@objc
	private func rtmpStatusHandler(_ notification: Notification) {
		guard let e = Event.from(notification) else { return }
		switch e.type {
		case .rtmpStatus:
			if let data = e.data as? ASObject,
			   let code = data["code"] as? String {
				if code == RTMPConnection.Code.connectSuccess.rawValue {
					connectionState = "已连接"
					rtmpStream?.publish(splitRTMP(urlString: rtmpConnection?.uri ?? "").map { $0.1 } ?? "live")
					startStatsTimer(simulated: false)
				} else if code == RTMPConnection.Code.connectClosed.rawValue {
					connectionState = "已断开"
					isStreaming = false
					stopStatsTimer()
				}
			}
		default:
			break
		}
	}

	private func configure(stream: RTMPStream, with settings: SettingsViewModel) {
		stream.captureSettings = [
			.fps: settings.fps,
			.sessionPreset: settings.videoResolutionPreset.sessionPresetString
		]
		stream.videoSettings = [
			.bitrate: settings.videoBitrateKbps * 1000
		]
		stream.audioSettings = [
			.bitrate: settings.audioBitrateKbps * 1000,
			.sampleRate: settings.audioSampleRate.hz
		]
		resolutionText = settings.videoResolutionPreset.displayName
	}
	#endif

	private func startStatsTimer(simulated: Bool) {
		stopStatsTimer()
		statsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			guard let self = self else { return }
			self.elapsedSeconds += 1
			if simulated {
				self.uploadBitrateKbps = Int.random(in: 800...2500)
				self.currentFps = Int.random(in: 24...self.settingsDefaultFps)
				self.resolutionText = "720p"
			} else {
				#if canImport(HaishinKit)
				if let stream = self.rtmpStream {
					self.currentFps = Int(stream.currentFPS)
				}
				#endif
			}
		}
		RunLoop.main.add(statsTimer!, forMode: .common)
	}

	private func stopStatsTimer() {
		statsTimer?.invalidate()
		statsTimer = nil
	}

	private var settingsDefaultFps: Int { 30 }

	#if canImport(HaishinKit)
	private func splitRTMP(urlString: String) -> (String, String)? {
		guard let components = URLComponents(string: urlString), let host = components.host else {
			return nil
		}
		let scheme = components.scheme ?? "rtmp"
		let portPart = components.port.map { ":\($0)" } ?? ""
		let hostPart = "\(scheme)://\(host)\(portPart)"
		let pathComponents = components.path.split(separator: "/")
		guard pathComponents.count >= 2 else { return nil }
		let basePath = pathComponents.dropLast().joined(separator: "/")
		let streamName = String(pathComponents.last!)
		let connectURL = hostPart + "/" + basePath
		return (connectURL, streamName)
	}
	#endif
}