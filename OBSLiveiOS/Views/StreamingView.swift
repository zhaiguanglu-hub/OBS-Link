import SwiftUI
import AVFoundation

/// Main streaming interface with camera preview and controls
struct StreamingView: View {
    @StateObject private var streamingManager = StreamingManager()
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    @State private var showingSettings = false
    @State private var showingStats = false
    @State private var showingError = false
    @State private var isControlsVisible = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Camera preview
                cameraPreview
                
                // Overlay content
                VStack {
                    // Top controls
                    topControls
                    
                    Spacer()
                    
                    // Bottom controls
                    bottomControls
                }
                
                // Stats overlay
                statsOverlay(geometry: geometry)
                
                // Error alert
                if showingError {
                    errorAlert
                }
            }
        }
        .ignoresSafeArea(.all)
        .onAppear {
            checkPermissions()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(settingsViewModel: settingsViewModel)
        }
        .sheet(isPresented: $showingStats) {
            DetailedStatsView(
                stats: streamingManager.stats,
                status: streamingManager.status
            )
        }
        .onChange(of: streamingManager.errorMessage) { error in
            if error != nil {
                showingError = true
            }
        }
    }
    
    // MARK: - Camera Preview
    
    private var cameraPreview: some View {
        InteractiveCameraPreviewView(
            isStreaming: $streamingManager.isStreaming,
            cameraPosition: settingsViewModel.configuration.cameraPosition
        ) { tapLocation in
            // Handle tap to focus
            handleTapToFocus(at: tapLocation)
        }
        .onTapGesture(count: 2) {
            // Double tap to toggle controls
            withAnimation(.easeInOut(duration: 0.3)) {
                isControlsVisible.toggle()
            }
        }
    }
    
    // MARK: - Top Controls
    
    private var topControls: some View {
        HStack {
            // Settings button
            Button(action: { showingSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                    )
            }
            
            Spacer()
            
            // Camera switch button
            Button(action: {
                streamingManager.toggleCameraPosition()
                settingsViewModel.updateCameraPosition(streamingManager.currentConfiguration.cameraPosition)
            }) {
                Image(systemName: "camera.rotate.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .opacity(isControlsVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: isControlsVisible)
    }
    
    // MARK: - Bottom Controls
    
    private var bottomControls: some View {
        VStack(spacing: 20) {
            // Status and stats
            statusSection
            
            // Main control button
            mainControlButton
            
            // Additional controls
            additionalControls
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
        .opacity(isControlsVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: isControlsVisible)
    }
    
    private var statusSection: some View {
        HStack {
            // Status indicator
            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text(streamingManager.status.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Stats button
            Button(action: { showingStats = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "chart.bar.fill")
                        .font(.caption)
                    Text("Stats")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )
            }
        }
    }
    
    private var mainControlButton: some View {
        Button(action: toggleStreaming) {
            HStack(spacing: 12) {
                Image(systemName: streamingManager.isStreaming ? "stop.fill" : "play.fill")
                    .font(.title2)
                
                Text(streamingManager.isStreaming ? "Stop Live" : "Go Live")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(streamingManager.isStreaming ? .red : .blue)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            )
        }
        .disabled(!canStartStreaming)
        .scaleEffect(streamingManager.isStreaming ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: streamingManager.isStreaming)
    }
    
    private var additionalControls: some View {
        HStack(spacing: 20) {
            // Orientation lock button
            Button(action: toggleOrientationLock) {
                Image(systemName: orientationLockIcon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                    )
            }
            
            Spacer()
            
            // Quality indicator
            qualityIndicator
            
            Spacer()
            
            // Flash/torch button (if available)
            if hasTorch {
                Button(action: toggleTorch) {
                    Image(systemName: isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
            }
        }
    }
    
    // MARK: - Stats Overlay
    
    private func statsOverlay(geometry: GeometryProxy) -> some View {
        VStack {
            HStack {
                Spacer()
                StatsOverlayView(
                    stats: streamingManager.stats,
                    status: streamingManager.status,
                    isVisible: streamingManager.isStreaming
                )
                .padding(.trailing, 20)
                .padding(.top, 60)
            }
            Spacer()
        }
    }
    
    // MARK: - Error Alert
    
    private var errorAlert: some View {
        VStack {
            Spacer()
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("Streaming Error")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    Text(streamingManager.errorMessage ?? "Unknown error occurred")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Dismiss") {
                    showingError = false
                    streamingManager.errorMessage = nil
                }
                .font(.headline)
                .foregroundColor(.blue)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeInOut(duration: 0.3), value: showingError)
    }
    
    // MARK: - Computed Properties
    
    private var statusColor: Color {
        switch streamingManager.status {
        case .idle: return .gray
        case .connecting: return .orange
        case .streaming: return .green
        case .error: return .red
        case .disconnected: return .red
        }
    }
    
    private var canStartStreaming: Bool {
        streamingManager.isCameraAuthorized &&
        streamingManager.isMicrophoneAuthorized &&
        settingsViewModel.isConfigurationValid &&
        !streamingManager.isStreaming
    }
    
    private var orientationLockIcon: String {
        switch settingsViewModel.configuration.orientationLock {
        case .auto: return "rotate.3d"
        case .portrait: return "rectangle.portrait"
        case .landscape: return "rectangle"
        }
    }
    
    private var qualityIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: "video.fill")
                .font(.caption)
            Text(settingsViewModel.configuration.videoResolution.displayName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
    }
    
    private var hasTorch: Bool {
        guard let device = AVCaptureDevice.default(for: .video) else { return false }
        return device.hasTorch
    }
    
    private var isTorchOn: Bool {
        guard let device = AVCaptureDevice.default(for: .video) else { return false }
        return device.torchMode == .on
    }
    
    // MARK: - Actions
    
    private func toggleStreaming() {
        if streamingManager.isStreaming {
            streamingManager.stopStreaming()
        } else {
            streamingManager.startStreaming(with: settingsViewModel.configuration)
        }
    }
    
    private func toggleOrientationLock() {
        let current = settingsViewModel.configuration.orientationLock
        let next: OrientationLock
        
        switch current {
        case .auto: next = .portrait
        case .portrait: next = .landscape
        case .landscape: next = .auto
        }
        
        settingsViewModel.updateOrientationLock(next)
    }
    
    private func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = device.torchMode == .on ? .off : .on
            device.unlockForConfiguration()
        } catch {
            print("Failed to toggle torch: \(error)")
        }
    }
    
    private func handleTapToFocus(at location: CGPoint) {
        // Focus handling is done in the InteractiveCameraPreviewView
    }
    
    private func checkPermissions() {
        // Permissions are checked in the StreamingManager
    }
}

// MARK: - Previews

struct StreamingView_Previews: PreviewProvider {
    static var previews: some View {
        StreamingView()
            .previewDisplayName("Streaming View")
    }
}