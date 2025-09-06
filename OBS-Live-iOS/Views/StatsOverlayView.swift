import SwiftUI

struct StatsOverlayView: View {
	let statusText: String
	let resolutionText: String
	let fps: Int
	let bitrateKbps: Int
	let elapsedSeconds: Int

	private var elapsedText: String {
		let h = elapsedSeconds / 3600
		let m = (elapsedSeconds % 3600) / 60
		let s = elapsedSeconds % 60
		return String(format: "%02d:%02d:%02d", h, m, s)
	}

	var body: some View {
		if statusText.isEmpty { EmptyView() } else {
			VStack(alignment: .leading, spacing: 6) {
				Text(statusText).bold()
				HStack(spacing: 12) {
					Text(resolutionText)
					Text("\(fps) fps")
					Text("\(bitrateKbps) kbps")
					Text(elapsedText)
				}
			}
			.font(.caption)
			.padding(8)
			.background(Color.black.opacity(0.4))
			.foregroundColor(.white)
			.cornerRadius(8)
		}
	}
}