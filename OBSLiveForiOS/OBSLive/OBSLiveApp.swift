import SwiftUI

@main
struct OBSLiveApp: App {
    @StateObject private var streamingManager = StreamingManager()
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(streamingManager)
                .environmentObject(settingsViewModel)
                .preferredColorScheme(.dark)
        }
    }
}