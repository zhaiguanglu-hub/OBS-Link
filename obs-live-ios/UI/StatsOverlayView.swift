import SwiftUI

struct StatsOverlayView: View {
	@EnvironmentObject var settings: SettingsViewModel
	@EnvironmentObject var streaming: StreamingManager

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text("State: \(stateText)")
			Text("Elapsed: \(formatTime(streaming.elapsedSeconds))")
			Text("Video: \(settings.videoResolution.rawValue) @ \(settings.videoFPS) fps")
			Text("Bitrate: \(settings.videoBitrateKbps) kbps")
		}
		.font(.system(size: 12, weight: .medium, design: .monospaced))
		.padding(8)
		.background(Color.black.opacity(0.4))
		.clipShape(RoundedRectangle(cornerRadius: 8))
		.foregroundColor(.white)
	}

	private var stateText: String {
		switch streaming.state {
		case .idle: return "Idle"
		case .connecting: return "Connecting"
		case .streaming: return "Live"
		case .error(let msg): return "Error: \(msg)"
		}
	}

	private func formatTime(_ s: Int) -> String {
		let h = s / 3600
		let m = (s % 3600) / 60
		let sec = s % 60
		if h > 0 {
			return String(format: "%d:%02d:%02d", h, m, sec)
		} else {
			return String(format: "%02d:%02d", m, sec)
		}
	}
}