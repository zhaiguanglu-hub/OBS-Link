import SwiftUI

struct SettingsView: View {
	@EnvironmentObject var settings: SettingsViewModel
	@Environment(\.dismiss) private var dismiss

	private let availableFPS = [24, 30, 60]
	private let availableSampleRates = [44100, 48000]
	private let availableAudioBitrates = [96, 128, 160, 192]

	var body: some View {
		NavigationView {
			Form {
				Section(header: Text("Server")) {
					TextField("RTMP URL", text: $settings.rtmpURL)
						.keyboardType(.URL)
						.textInputAutocapitalization(.never)
						.autocorrectionDisabled(true)
				}

				Section(header: Text("Video")) {
					Picker("Resolution", selection: $settings.videoResolution) {
						ForEach(SettingsViewModel.VideoResolution.allCases) { res in
							Text(res.rawValue).tag(res)
						}
					}
					Picker("FPS", selection: $settings.videoFPS) {
						ForEach(availableFPS, id: \.self) { fps in
							Text("\(fps)").tag(fps)
						}
					}
					Stepper(value: $settings.videoBitrateKbps, in: 300...12000, step: 100) {
						HStack {
							Text("Video Bitrate")
							Spacer()
							Text("\(settings.videoBitrateKbps) kbps")
						}
					}
				}

				Section(header: Text("Audio")) {
					Picker("Sample Rate", selection: $settings.audioSampleRateHz) {
						ForEach(availableSampleRates, id: \.self) { sr in
							Text("\(sr / 1000) kHz").tag(sr)
						}
					}
					Picker("Bitrate", selection: $settings.audioBitrateKbps) {
						ForEach(availableAudioBitrates, id: \.self) { br in
							Text("\(br) kbps").tag(br)
						}
					}
				}

				Section(header: Text("Behavior")) {
					Toggle("Lock Landscape", isOn: $settings.isLandscapeLocked)
						.onChange(of: settings.isLandscapeLocked) { locked in
							OrientationManager.shared.setLandscapeLocked(locked)
						}
				}
			}
			.navigationTitle("Settings")
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("Done") {
						Haptics.impact(.light)
						dismiss()
					}
				}
			}
		}
	}
}