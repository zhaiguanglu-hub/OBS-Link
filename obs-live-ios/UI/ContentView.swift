import SwiftUI

struct ContentView: View {
	@EnvironmentObject var settings: SettingsViewModel
	@EnvironmentObject var streaming: StreamingManager

	@State private var isShowingSettings = false
	@State private var showURLAlert = false

	var body: some View {
		ZStack(alignment: .bottom) {
			ZStack(alignment: .topLeading) {
				CameraPreviewView()
					.ignoresSafeArea()
					.environmentObject(streaming)

				StatsOverlayView()
					.padding(12)
			}

			controlBar
		}
		.sheet(isPresented: $isShowingSettings) {
			SettingsView()
				.environmentObject(settings)
		}
		.alert("Please enter RTMP URL", isPresented: $showURLAlert) {
			Button("OK", role: .cancel) {}
		}
	}

	private var controlBar: some View {
		HStack(spacing: 24) {
			Button {
				isShowingSettings = true
				Haptics.impact(.light)
			} label: {
				Image(systemName: "gearshape")
					.font(.system(size: 20, weight: .semibold))
			}
			.foregroundColor(.white)

			Spacer()

			Button {
				streaming.switchCamera()
			} label: {
				Image(systemName: "arrow.triangle.2.circlepath.camera")
					.font(.system(size: 22, weight: .bold))
			}
			.foregroundColor(.white)

			Spacer()

			Button {
				toggleStreaming()
			} label: {
				Text(streaming.state == .streaming ? "Stop" : "Start")
					.font(.system(size: 18, weight: .bold))
					.frame(width: 100, height: 44)
					.background(streaming.state == .streaming ? Color.red.opacity(0.9) : Color.green.opacity(0.9))
					.foregroundColor(.white)
					.clipShape(Capsule())
			}
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 12)
		.background(Color.black.opacity(0.35))
		.cornerRadius(14)
		.padding(.horizontal, 16)
		.padding(.bottom, 20)
	}

	private func toggleStreaming() {
		switch streaming.state {
		case .idle, .error:
			guard !settings.rtmpURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
				showURLAlert = true
				return
			}
			streaming.startStreaming(url: settings.rtmpURL, settings: settings)
		case .connecting, .streaming:
			streaming.stopStreaming()
		}
	}
}