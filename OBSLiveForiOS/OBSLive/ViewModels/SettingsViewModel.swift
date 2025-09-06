import Foundation
import Combine

struct StreamingPreset: Codable, Identifiable {
    let id = UUID()
    var name: String
    var resolution: VideoResolution
    var fps: Int
    var videoBitrate: Int
    var audioBitrate: Int
    var audioSampleRate: Double
}

class SettingsViewModel: ObservableObject {
    // MARK: - Server Settings
    @Published var serverURL: String {
        didSet { saveSettings() }
    }
    
    @Published var streamKey: String {
        didSet { saveSettings() }
    }
    
    // MARK: - Video Settings
    @Published var selectedResolution: VideoResolution {
        didSet { saveSettings() }
    }
    
    @Published var fps: Int {
        didSet { saveSettings() }
    }
    
    @Published var videoBitrate: Int {
        didSet { saveSettings() }
    }
    
    // MARK: - Audio Settings
    @Published var audioSampleRate: Double {
        didSet { saveSettings() }
    }
    
    @Published var audioBitrate: Int {
        didSet { saveSettings() }
    }
    
    // MARK: - UI Settings
    @Published var showStats: Bool {
        didSet { saveSettings() }
    }
    
    @Published var orientationLocked: Bool {
        didSet { saveSettings() }
    }
    
    @Published var isLandscapeMode: Bool {
        didSet { saveSettings() }
    }
    
    // MARK: - Presets
    @Published var presets: [StreamingPreset] = []
    @Published var selectedPreset: StreamingPreset?
    
    // Available options
    let availableFPS = [24, 30, 60]
    let availableAudioSampleRates = [44100.0, 48000.0]
    
    init() {
        // Load saved settings or use defaults
        self.serverURL = UserDefaults.standard.string(forKey: "serverURL") ?? ""
        self.streamKey = UserDefaults.standard.string(forKey: "streamKey") ?? ""
        
        // Video defaults
        let savedResolutionData = UserDefaults.standard.data(forKey: "selectedResolution")
        if let data = savedResolutionData,
           let resolution = try? JSONDecoder().decode(VideoResolution.self, from: data) {
            self.selectedResolution = resolution
        } else {
            self.selectedResolution = VideoResolution.preset1080p
        }
        
        self.fps = UserDefaults.standard.integer(forKey: "fps") != 0 ? UserDefaults.standard.integer(forKey: "fps") : 30
        self.videoBitrate = UserDefaults.standard.integer(forKey: "videoBitrate") != 0 ? UserDefaults.standard.integer(forKey: "videoBitrate") : 4000
        
        // Audio defaults
        self.audioSampleRate = UserDefaults.standard.double(forKey: "audioSampleRate") != 0 ? UserDefaults.standard.double(forKey: "audioSampleRate") : 44100.0
        self.audioBitrate = UserDefaults.standard.integer(forKey: "audioBitrate") != 0 ? UserDefaults.standard.integer(forKey: "audioBitrate") : 128
        
        // UI defaults
        self.showStats = UserDefaults.standard.bool(forKey: "showStats")
        self.orientationLocked = UserDefaults.standard.bool(forKey: "orientationLocked")
        self.isLandscapeMode = UserDefaults.standard.bool(forKey: "isLandscapeMode")
        
        loadPresets()
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(serverURL, forKey: "serverURL")
        UserDefaults.standard.set(streamKey, forKey: "streamKey")
        
        if let encodedResolution = try? JSONEncoder().encode(selectedResolution) {
            UserDefaults.standard.set(encodedResolution, forKey: "selectedResolution")
        }
        
        UserDefaults.standard.set(fps, forKey: "fps")
        UserDefaults.standard.set(videoBitrate, forKey: "videoBitrate")
        UserDefaults.standard.set(audioSampleRate, forKey: "audioSampleRate")
        UserDefaults.standard.set(audioBitrate, forKey: "audioBitrate")
        UserDefaults.standard.set(showStats, forKey: "showStats")
        UserDefaults.standard.set(orientationLocked, forKey: "orientationLocked")
        UserDefaults.standard.set(isLandscapeMode, forKey: "isLandscapeMode")
    }
    
    // MARK: - Preset Management
    func savePreset(name: String) {
        let preset = StreamingPreset(
            name: name,
            resolution: selectedResolution,
            fps: fps,
            videoBitrate: videoBitrate,
            audioBitrate: audioBitrate,
            audioSampleRate: audioSampleRate
        )
        
        presets.append(preset)
        savePresets()
    }
    
    func loadPreset(_ preset: StreamingPreset) {
        selectedResolution = preset.resolution
        fps = preset.fps
        videoBitrate = preset.videoBitrate
        audioBitrate = preset.audioBitrate
        audioSampleRate = preset.audioSampleRate
        selectedPreset = preset
    }
    
    func deletePreset(_ preset: StreamingPreset) {
        presets.removeAll { $0.id == preset.id }
        savePresets()
    }
    
    private func savePresets() {
        if let encoded = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(encoded, forKey: "streamingPresets")
        }
    }
    
    private func loadPresets() {
        if let data = UserDefaults.standard.data(forKey: "streamingPresets"),
           let decoded = try? JSONDecoder().decode([StreamingPreset].self, from: data) {
            presets = decoded
        } else {
            // Add default presets
            presets = [
                StreamingPreset(
                    name: "Outdoor Smooth",
                    resolution: VideoResolution.preset720p,
                    fps: 30,
                    videoBitrate: 2000,
                    audioBitrate: 96,
                    audioSampleRate: 44100.0
                ),
                StreamingPreset(
                    name: "Indoor HD",
                    resolution: VideoResolution.preset1080p,
                    fps: 30,
                    videoBitrate: 4000,
                    audioBitrate: 128,
                    audioSampleRate: 48000.0
                ),
                StreamingPreset(
                    name: "Gaming High Quality",
                    resolution: VideoResolution.preset1080p,
                    fps: 60,
                    videoBitrate: 6000,
                    audioBitrate: 160,
                    audioSampleRate: 48000.0
                )
            ]
            savePresets()
        }
    }
    
    // MARK: - Validation
    var isConfigValid: Bool {
        return !serverURL.isEmpty && !streamKey.isEmpty
    }
}