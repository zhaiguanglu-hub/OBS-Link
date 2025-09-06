import SwiftUI

struct MainStreamingView: View {
	@EnvironmentObject var settingsViewModel: SettingsViewModel
	@EnvironmentObject var streamingManager: StreamingManager

	@State private var showingSettings = false

	var body: some View {
		ZStack(alignment: .bottom) {
			CameraPreviewView()
				.ignoresSafeArea()

			StatsOverlayView(
				statusText: streamingManager.connectionState,
				resolutionText: streamingManager.resolutionText,
				fps: streamingManager.currentFps,
				bitrateKbps: streamingManager.uploadBitrateKbps,
				elapsedSeconds: streamingManager.elapsedSeconds
			)
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
			.padding()

			controlBar
		}
		.background(Color.black)
		.sheet(isPresented: $showingSettings) {
			SettingsSheetView()
				.environmentObject(settingsViewModel)
		}
	}

	private var controlBar: some View {
		HStack(spacing: 24) {
			Button(action: { toggleStreaming() }) {
				Text(streamingManager.isStreaming ? "停止直播" : "开始直播")
					.bold()
					.frame(maxWidth: .infinity)
					.padding()
					.background(streamingManager.isStreaming ? Color.red.opacity(0.9) : Color.green.opacity(0.9))
					.foregroundColor(.white)
					.cornerRadius(12)
			}
			Button(action: { streamingManager.switchCamera() }) {
				Image(systemName: "camera.rotate")
					.font(.system(size: 20, weight: .semibold))
					.frame(width: 48, height: 48)
					.background(Color.black.opacity(0.35))
					.foregroundColor(.white)
					.cornerRadius(10)
			}
			Button(action: { showingSettings = true }) {
				Image(systemName: "gearshape")
					.font(.system(size: 20, weight: .semibold))
					.frame(width: 48, height: 48)
					.background(Color.black.opacity(0.35))
					.foregroundColor(.white)
					.cornerRadius(10)
			}
		}
		.padding()
		.background(.ultraThinMaterial)
	}

	private func toggleStreaming() {
		#if os(iOS)
		let generator = UINotificationFeedbackGenerator()
		generator.prepare()
		#endif
		if streamingManager.isStreaming {
			streamingManager.stopStreaming()
			#if os(iOS)
			generator.notificationOccurred(.warning)
			#endif
		} else {
			streamingManager.startStreaming(rtmpURLString: settingsViewModel.rtmpURLString, settings: settingsViewModel)
			#if os(iOS)
			generator.notificationOccurred(.success)
			#endif
		}
	}
}

private struct SettingsSheetView: View {
	@EnvironmentObject var settingsViewModel: SettingsViewModel

	var body: some View {
		NavigationView {
			Form {
				Section(header: Text("服务器")) {
					TextField("RTMP URL", text: $settingsViewModel.rtmpURLString)
						.keyboardType(.URL)
						.textInputAutocapitalization(.never)
						.disableAutocorrection(true)
				}
				Section(header: Text("视频")) {
					Picker("分辨率", selection: $settingsViewModel.videoResolutionPreset) {
						ForEach(VideoResolutionPreset.allCases, id: \.self) { preset in
							Text(preset.displayName).tag(preset)
						}
					}
					Stepper(value: $settingsViewModel.fps, in: 15...60, step: 1) {
						Text("帧率 \(settingsViewModel.fps) fps")
					}
					Stepper(value: $settingsViewModel.videoBitrateKbps, in: 300...12000, step: 100) {
						Text("视频码率 \(settingsViewModel.videoBitrateKbps) kbps")
					}
				}
				Section(header: Text("音频")) {
					Picker("采样率", selection: $settingsViewModel.audioSampleRate) {
						ForEach(AudioSampleRate.allCases, id: \.self) { rate in
							Text(rate.displayName).tag(rate)
						}
					}
					Stepper(value: $settingsViewModel.audioBitrateKbps, in: 32...320, step: 16) {
						Text("音频码率 \(settingsViewModel.audioBitrateKbps) kbps")
					}
				}
				Section(header: Text("偏好")) {
					Toggle("显示状态信息", isOn: $settingsViewModel.showStatsOverlay)
					Toggle("触屏对焦", isOn: $settingsViewModel.tapToFocusEnabled)
					Picker("方向锁定", selection: $settingsViewModel.orientationLock) {
						ForEach(OrientationLock.allCases, id: \.self) { lock in
							Text(lock.displayName).tag(lock)
						}
					}
				}
			}
			.navigationTitle("设置")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}