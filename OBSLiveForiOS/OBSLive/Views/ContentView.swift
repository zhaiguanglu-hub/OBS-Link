import SwiftUI

struct ContentView: View {
    @EnvironmentObject var streamingManager: StreamingManager
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var showSettings = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Camera Preview
                CameraPreviewView()
                    .edgesIgnoringSafeArea(.all)
                
                // Top Stats Overlay
                VStack {
                    HStack {
                        StatsOverlayView()
                        Spacer()
                    }
                    .padding()
                    
                    Spacer()
                }
                
                // Bottom Control Bar
                VStack {
                    Spacer()
                    
                    ControlBarView(showSettings: $showSettings)
                        .padding(.bottom, geometry.safeAreaInsets.bottom)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .alert("Streaming Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                configureOrientation()
                requestPermissions()
            }
            .onChange(of: streamingManager.state) { newState in
                handleStreamingStateChange(newState)
            }
        }
    }
    
    private func configureOrientation() {
        if settingsViewModel.orientationLocked {
            let orientation: UIInterfaceOrientationMask = settingsViewModel.isLandscapeMode ? .landscape : .portrait
            AppDelegate.orientationLock = orientation
            
            if settingsViewModel.isLandscapeMode {
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            }
        } else {
            AppDelegate.orientationLock = .all
        }
    }
    
    private func requestPermissions() {
        // Request camera permission
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if !granted {
                DispatchQueue.main.async {
                    errorMessage = "Camera access is required for streaming"
                    showError = true
                }
            }
        }
        
        // Request microphone permission
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            if !granted {
                DispatchQueue.main.async {
                    errorMessage = "Microphone access is required for streaming"
                    showError = true
                }
            }
        }
    }
    
    private func handleStreamingStateChange(_ state: StreamingState) {
        switch state {
        case .error(let message):
            errorMessage = message
            showError = true
        default:
            break
        }
    }
}

// Control Bar Component
struct ControlBarView: View {
    @EnvironmentObject var streamingManager: StreamingManager
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Binding var showSettings: Bool
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 30) {
            // Settings Button
            Button(action: {
                showSettings = true
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            
            // Stream Button
            Button(action: {
                toggleStreaming()
            }) {
                ZStack {
                    Circle()
                        .fill(streamingManager.isStreaming ? Color.red : Color.blue)
                        .frame(width: 80, height: 80)
                    
                    if streamingManager.state == .connecting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    } else {
                        Image(systemName: streamingManager.isStreaming ? "stop.fill" : "play.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .offset(x: streamingManager.isStreaming ? 0 : 3)
                    }
                }
                .scaleEffect(isAnimating ? 0.9 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isAnimating)
            }
            .disabled(streamingManager.state == .connecting || !settingsViewModel.isConfigValid)
            
            // Camera Switch Button
            Button(action: {
                streamingManager.switchCamera()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }) {
                Image(systemName: "camera.rotate.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            .disabled(streamingManager.isStreaming)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.black.opacity(0.6))
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func toggleStreaming() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.1)) {
            isAnimating = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isAnimating = false
        }
        
        if streamingManager.isStreaming {
            streamingManager.stopStreaming()
        } else {
            // Configure video and audio settings
            streamingManager.configureVideo(
                resolution: settingsViewModel.selectedResolution,
                fps: settingsViewModel.fps,
                bitrate: settingsViewModel.videoBitrate
            )
            
            streamingManager.configureAudio(
                sampleRate: settingsViewModel.audioSampleRate,
                bitrate: settingsViewModel.audioBitrate
            )
            
            // Start streaming
            streamingManager.startStreaming(
                serverURL: settingsViewModel.serverURL,
                streamKey: settingsViewModel.streamKey
            )
        }
    }
}

// App Delegate for orientation control
class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}