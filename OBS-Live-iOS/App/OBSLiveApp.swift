import SwiftUI

@main
struct OBSLiveApp: App {
	@StateObject private var settingsViewModel = SettingsViewModel()
	@StateObject private var streamingManager = StreamingManager()

	var body: some Scene {
		WindowGroup {
			MainStreamingView()
				.environmentObject(settingsViewModel)
				.environmentObject(streamingManager)
		}
	}
}