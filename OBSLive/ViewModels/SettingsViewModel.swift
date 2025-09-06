//
//  SettingsViewModel.swift
//  OBSLive
//
//  Created by OBS Live Team
//

import Foundation
import Combine

/// 设置视图模型，管理所有用户配置
@MainActor
class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var rtmpURL: String = ""
    @Published var selectedResolution: VideoResolution = .hd720p
    @Published var frameRate: Int = 30
    @Published var videoBitrate: Int = 2500
    @Published var audioBitrate: Int = 128
    @Published var sampleRate: Int = 44100
    @Published var autoAdjustBitrate: Bool = true
    @Published var savedPresets: [StreamPreset] = []
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constants
    private enum Keys {
        static let rtmpURL = "rtmpURL"
        static let selectedResolution = "selectedResolution"
        static let frameRate = "frameRate"
        static let videoBitrate = "videoBitrate"
        static let audioBitrate = "audioBitrate"
        static let sampleRate = "sampleRate"
        static let autoAdjustBitrate = "autoAdjustBitrate"
        static let savedPresets = "savedPresets"
    }
    
    // MARK: - Computed Properties
    var currentSettings: StreamSettings {
        StreamSettings(
            resolution: selectedResolution,
            frameRate: frameRate,
            videoBitrate: autoAdjustBitrate ? selectedResolution.recommendedBitrate : videoBitrate,
            audioBitrate: audioBitrate,
            sampleRate: sampleRate
        )
    }
    
    var availableFrameRates: [Int] {
        [24, 30, 60]
    }
    
    var availableAudioBitrates: [Int] {
        [64, 128, 192, 256]
    }
    
    var availableSampleRates: [Int] {
        [22050, 44100, 48000]
    }
    
    // MARK: - Initialization
    init() {
        loadSettings()
        setupObservers()
        loadDefaultPresets()
    }
    
    // MARK: - Public Methods
    
    /// 保存当前设置为预设
    func saveCurrentAsPreset(name: String) {
        let preset = StreamPreset(
            name: name,
            settings: currentSettings
        )
        
        savedPresets.append(preset)
        savePresets()
    }
    
    /// 应用预设
    func applyPreset(_ preset: StreamPreset) {
        selectedResolution = preset.settings.resolution
        frameRate = preset.settings.frameRate
        videoBitrate = preset.settings.videoBitrate
        audioBitrate = preset.settings.audioBitrate
        sampleRate = preset.settings.sampleRate
        
        saveSettings()
    }
    
    /// 删除预设
    func deletePreset(_ preset: StreamPreset) {
        savedPresets.removeAll { $0.id == preset.id }
        savePresets()
    }
    
    /// 重置为默认设置
    func resetToDefaults() {
        rtmpURL = ""
        selectedResolution = .hd720p
        frameRate = 30
        videoBitrate = 2500
        audioBitrate = 128
        sampleRate = 44100
        autoAdjustBitrate = true
        
        saveSettings()
    }
    
    /// 验证RTMP URL格式
    func validateRTMPURL(_ url: String) -> Bool {
        return url.lowercased().hasPrefix("rtmp://") || url.lowercased().hasPrefix("rtmps://")
    }
    
    // MARK: - Private Methods
    
    private func setupObservers() {
        // 监听设置变化并自动保存
        Publishers.CombineLatest4(
            $rtmpURL,
            $selectedResolution,
            $frameRate,
            $videoBitrate
        )
        .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
        .sink { [weak self] _, _, _, _ in
            self?.saveSettings()
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest3(
            $audioBitrate,
            $sampleRate,
            $autoAdjustBitrate
        )
        .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
        .sink { [weak self] _, _, _ in
            self?.saveSettings()
        }
        .store(in: &cancellables)
        
        // 当分辨率改变时，自动调整码率
        $selectedResolution
            .sink { [weak self] resolution in
                if self?.autoAdjustBitrate == true {
                    self?.videoBitrate = resolution.recommendedBitrate
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadSettings() {
        rtmpURL = userDefaults.string(forKey: Keys.rtmpURL) ?? ""
        
        if let resolutionRaw = userDefaults.string(forKey: Keys.selectedResolution),
           let resolution = VideoResolution(rawValue: resolutionRaw) {
            selectedResolution = resolution
        }
        
        let savedFrameRate = userDefaults.integer(forKey: Keys.frameRate)
        frameRate = savedFrameRate > 0 ? savedFrameRate : 30
        
        let savedVideoBitrate = userDefaults.integer(forKey: Keys.videoBitrate)
        videoBitrate = savedVideoBitrate > 0 ? savedVideoBitrate : 2500
        
        let savedAudioBitrate = userDefaults.integer(forKey: Keys.audioBitrate)
        audioBitrate = savedAudioBitrate > 0 ? savedAudioBitrate : 128
        
        let savedSampleRate = userDefaults.integer(forKey: Keys.sampleRate)
        sampleRate = savedSampleRate > 0 ? savedSampleRate : 44100
        
        autoAdjustBitrate = userDefaults.bool(forKey: Keys.autoAdjustBitrate)
        
        loadPresets()
    }
    
    private func saveSettings() {
        userDefaults.set(rtmpURL, forKey: Keys.rtmpURL)
        userDefaults.set(selectedResolution.rawValue, forKey: Keys.selectedResolution)
        userDefaults.set(frameRate, forKey: Keys.frameRate)
        userDefaults.set(videoBitrate, forKey: Keys.videoBitrate)
        userDefaults.set(audioBitrate, forKey: Keys.audioBitrate)
        userDefaults.set(sampleRate, forKey: Keys.sampleRate)
        userDefaults.set(autoAdjustBitrate, forKey: Keys.autoAdjustBitrate)
    }
    
    private func loadPresets() {
        if let data = userDefaults.data(forKey: Keys.savedPresets),
           let presets = try? JSONDecoder().decode([StreamPreset].self, from: data) {
            savedPresets = presets
        }
    }
    
    private func savePresets() {
        if let data = try? JSONEncoder().encode(savedPresets) {
            userDefaults.set(data, forKey: Keys.savedPresets)
        }
    }
    
    private func loadDefaultPresets() {
        if savedPresets.isEmpty {
            savedPresets = [
                StreamPreset(
                    name: "高清流畅 (720p)",
                    settings: StreamSettings(
                        resolution: .hd720p,
                        frameRate: 30,
                        videoBitrate: 2500,
                        audioBitrate: 128,
                        sampleRate: 44100
                    )
                ),
                StreamPreset(
                    name: "超高清 (1080p)",
                    settings: StreamSettings(
                        resolution: .fhd1080p,
                        frameRate: 30,
                        videoBitrate: 5000,
                        audioBitrate: 192,
                        sampleRate: 48000
                    )
                ),
                StreamPreset(
                    name: "省流模式 (480p)",
                    settings: StreamSettings(
                        resolution: .sd480p,
                        frameRate: 24,
                        videoBitrate: 1000,
                        audioBitrate: 64,
                        sampleRate: 44100
                    )
                )
            ]
            savePresets()
        }
    }
}

// MARK: - Supporting Types

/// 流预设配置
struct StreamPreset: Identifiable, Codable {
    let id = UUID()
    let name: String
    let settings: StreamSettings
    let createdAt: Date
    
    init(name: String, settings: StreamSettings) {
        self.name = name
        self.settings = settings
        self.createdAt = Date()
    }
}

// 让StreamSettings支持Codable
extension StreamSettings: Codable {
    enum CodingKeys: String, CodingKey {
        case resolution, frameRate, videoBitrate, audioBitrate, sampleRate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let resolutionRaw = try container.decode(String.self, forKey: .resolution)
        resolution = VideoResolution(rawValue: resolutionRaw) ?? .hd720p
        frameRate = try container.decode(Int.self, forKey: .frameRate)
        videoBitrate = try container.decode(Int.self, forKey: .videoBitrate)
        audioBitrate = try container.decode(Int.self, forKey: .audioBitrate)
        sampleRate = try container.decode(Int.self, forKey: .sampleRate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(resolution.rawValue, forKey: .resolution)
        try container.encode(frameRate, forKey: .frameRate)
        try container.encode(videoBitrate, forKey: .videoBitrate)
        try container.encode(audioBitrate, forKey: .audioBitrate)
        try container.encode(sampleRate, forKey: .sampleRate)
    }
}

extension VideoResolution: Codable {}