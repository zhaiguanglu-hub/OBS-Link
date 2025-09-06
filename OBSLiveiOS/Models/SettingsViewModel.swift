import Foundation
import SwiftUI
import Combine

/// ViewModel for managing streaming settings and configuration
@MainActor
class SettingsViewModel: ObservableObject {
    @Published var configuration: StreamingConfiguration = .default
    @Published var customPresets: [VideoPreset] = []
    @Published var showAdvancedSettings: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var availableResolutions: [VideoResolution] {
        VideoResolution.allCases
    }
    
    var availableFrameRates: [FrameRate] {
        FrameRate.allCases
    }
    
    var availableBitrates: [VideoBitrate] {
        VideoBitrate.allCases
    }
    
    var availablePresets: [VideoPreset] {
        VideoPreset.presets + customPresets
    }
    
    var isConfigurationValid: Bool {
        !configuration.rtmpURL.isEmpty && 
        configuration.rtmpURL.hasPrefix("rtmp://")
    }
    
    // MARK: - Initialization
    
    init() {
        loadSettings()
        setupBindings()
    }
    
    // MARK: - Settings Management
    
    func loadSettings() {
        if let data = userDefaults.data(forKey: "streaming_configuration"),
           let config = try? JSONDecoder().decode(StreamingConfiguration.self, from: data) {
            configuration = config
        }
        
        if let data = userDefaults.data(forKey: "custom_presets"),
           let presets = try? JSONDecoder().decode([VideoPreset].self, from: data) {
            customPresets = presets
        }
    }
    
    func saveSettings() {
        if let data = try? JSONEncoder().encode(configuration) {
            userDefaults.set(data, forKey: "streaming_configuration")
        }
        
        if let data = try? JSONEncoder().encode(customPresets) {
            userDefaults.set(data, forKey: "custom_presets")
        }
    }
    
    private func setupBindings() {
        // Auto-save configuration when it changes
        $configuration
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveSettings()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Configuration Updates
    
    func updateRTMPURL(_ url: String) {
        configuration.rtmpURL = url
    }
    
    func updateVideoResolution(_ resolution: VideoResolution) {
        configuration.videoResolution = resolution
    }
    
    func updateFrameRate(_ frameRate: FrameRate) {
        configuration.frameRate = frameRate
    }
    
    func updateVideoBitrate(_ bitrate: VideoBitrate) {
        configuration.videoBitrate = bitrate
    }
    
    func updateCameraPosition(_ position: AVCaptureDevice.Position) {
        configuration.cameraPosition = position
    }
    
    func updateOrientationLock(_ orientation: OrientationLock) {
        configuration.orientationLock = orientation
    }
    
    func updateAudioSettings(_ settings: AudioSettings) {
        configuration.audioSettings = settings
    }
    
    // MARK: - Preset Management
    
    func applyPreset(_ preset: VideoPreset) {
        configuration.videoResolution = preset.resolution
        configuration.frameRate = preset.frameRate
        configuration.videoBitrate = preset.bitrate
    }
    
    func saveCurrentAsPreset(name: String) {
        let preset = VideoPreset(
            name: name,
            resolution: configuration.videoResolution,
            frameRate: configuration.frameRate,
            bitrate: configuration.videoBitrate
        )
        customPresets.append(preset)
        saveSettings()
    }
    
    func deleteCustomPreset(_ preset: VideoPreset) {
        customPresets.removeAll { $0.id == preset.id }
        saveSettings()
    }
    
    // MARK: - Validation
    
    func validateRTMPURL(_ url: String) -> Bool {
        return !url.isEmpty && url.hasPrefix("rtmp://")
    }
    
    func getSuggestedBitrate(for resolution: VideoResolution, frameRate: FrameRate) -> VideoBitrate {
        let totalPixels = resolution.width * resolution.height
        let fps = frameRate.value
        
        // Simple bitrate calculation based on resolution and frame rate
        let suggestedBitrate: Int
        
        if totalPixels <= 1280 * 720 {
            suggestedBitrate = fps <= 30 ? 1000 : 2500
        } else if totalPixels <= 1920 * 1080 {
            suggestedBitrate = fps <= 30 ? 2500 : 5000
        } else if totalPixels <= 2560 * 1440 {
            suggestedBitrate = fps <= 30 ? 5000 : 10000
        } else {
            suggestedBitrate = fps <= 30 ? 10000 : 15000
        }
        
        return VideoBitrate.allCases.first { $0.value == suggestedBitrate } ?? .allCases[2]
    }
    
    // MARK: - Reset Functions
    
    func resetToDefaults() {
        configuration = .default
        saveSettings()
    }
    
    func clearCustomPresets() {
        customPresets.removeAll()
        saveSettings()
    }
}