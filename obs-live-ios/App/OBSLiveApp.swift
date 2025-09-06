import SwiftUI

@main
struct OBSLiveApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@StateObject private var settingsViewModel = SettingsViewModel()
	@StateObject private var streamingManager = StreamingManager()

	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(settingsViewModel)
				.environmentObject(streamingManager)
		}
	}
}