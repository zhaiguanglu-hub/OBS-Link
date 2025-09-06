import SwiftUI

/// Settings interface for configuring streaming parameters
struct SettingsView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingPresetSheet = false
    @State private var showingResetAlert = false
    @State private var newPresetName = ""
    
    var body: some View {
        NavigationView {
            Form {
                // Server Configuration
                serverConfigurationSection
                
                // Video Settings
                videoSettingsSection
                
                // Audio Settings
                audioSettingsSection
                
                // Camera Settings
                cameraSettingsSection
                
                // Presets
                presetsSection
                
                // Advanced Settings
                advancedSettingsSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingPresetSheet) {
            presetSheet
        }
        .alert("Reset Settings", isPresented: $showingResetAlert) {
            Button("Reset", role: .destructive) {
                settingsViewModel.resetToDefaults()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will reset all settings to their default values. This action cannot be undone.")
        }
    }
    
    // MARK: - Server Configuration Section
    
    private var serverConfigurationSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                TextField("RTMP Server URL", text: Binding(
                    get: { settingsViewModel.configuration.rtmpURL },
                    set: { settingsViewModel.updateRTMPURL($0) }
                ))
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.URL)
                
                if !settingsViewModel.isConfigurationValid && !settingsViewModel.configuration.rtmpURL.isEmpty {
                    Text("Please enter a valid RTMP URL (e.g., rtmp://live.example.com/app/streamkey)")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        } header: {
            Text("Server Configuration")
        } footer: {
            Text("Enter your RTMP server URL. This is where your stream will be sent.")
        }
    }
    
    // MARK: - Video Settings Section
    
    private var videoSettingsSection: some View {
        Section {
            // Resolution
            Picker("Resolution", selection: Binding(
                get: { settingsViewModel.configuration.videoResolution },
                set: { settingsViewModel.updateVideoResolution($0) }
            )) {
                ForEach(settingsViewModel.availableResolutions) { resolution in
                    Text(resolution.displayName).tag(resolution)
                }
            }
            .pickerStyle(.menu)
            
            // Frame Rate
            Picker("Frame Rate", selection: Binding(
                get: { settingsViewModel.configuration.frameRate },
                set: { settingsViewModel.updateFrameRate($0) }
            )) {
                ForEach(settingsViewModel.availableFrameRates) { frameRate in
                    Text(frameRate.displayName).tag(frameRate)
                }
            }
            .pickerStyle(.menu)
            
            // Bitrate
            Picker("Video Bitrate", selection: Binding(
                get: { settingsViewModel.configuration.videoBitrate },
                set: { settingsViewModel.updateVideoBitrate($0) }
            )) {
                ForEach(settingsViewModel.availableBitrates) { bitrate in
                    Text(bitrate.displayName).tag(bitrate)
                }
            }
            .pickerStyle(.menu)
            
            // Auto bitrate suggestion
            if settingsViewModel.configuration.videoBitrate.value == 0 {
                Button("Use Suggested Bitrate") {
                    let suggested = settingsViewModel.getSuggestedBitrate(
                        for: settingsViewModel.configuration.videoResolution,
                        frameRate: settingsViewModel.configuration.frameRate
                    )
                    settingsViewModel.updateVideoBitrate(suggested)
                }
                .foregroundColor(.blue)
            }
        } header: {
            Text("Video Settings")
        } footer: {
            Text("Higher resolution and frame rate require more bandwidth and processing power.")
        }
    }
    
    // MARK: - Audio Settings Section
    
    private var audioSettingsSection: some View {
        Section {
            // Sample Rate
            Picker("Sample Rate", selection: Binding(
                get: { settingsViewModel.configuration.audioSettings.sampleRate },
                set: { 
                    var settings = settingsViewModel.configuration.audioSettings
                    settings.sampleRate = $0
                    settingsViewModel.updateAudioSettings(settings)
                }
            )) {
                Text("44.1 kHz").tag(44100)
                Text("48 kHz").tag(48000)
            }
            .pickerStyle(.segmented)
            
            // Audio Bitrate
            HStack {
                Text("Audio Bitrate")
                Spacer()
                Text("\(settingsViewModel.configuration.audioSettings.bitrate) kbps")
                    .foregroundColor(.secondary)
            }
            
            Slider(
                value: Binding(
                    get: { Double(settingsViewModel.configuration.audioSettings.bitrate) },
                    set: {
                        var settings = settingsViewModel.configuration.audioSettings
                        settings.bitrate = Int($0)
                        settingsViewModel.updateAudioSettings(settings)
                    }
                ),
                in: 64...320,
                step: 32
            )
        } header: {
            Text("Audio Settings")
        } footer: {
            Text("Higher bitrate provides better audio quality but uses more bandwidth.")
        }
    }
    
    // MARK: - Camera Settings Section
    
    private var cameraSettingsSection: some View {
        Section {
            // Camera Position
            Picker("Camera", selection: Binding(
                get: { settingsViewModel.configuration.cameraPosition },
                set: { settingsViewModel.updateCameraPosition($0) }
            )) {
                Text("Back Camera").tag(AVCaptureDevice.Position.back)
                Text("Front Camera").tag(AVCaptureDevice.Position.front)
            }
            .pickerStyle(.segmented)
            
            // Orientation Lock
            Picker("Orientation Lock", selection: Binding(
                get: { settingsViewModel.configuration.orientationLock },
                set: { settingsViewModel.updateOrientationLock($0) }
            )) {
                ForEach(OrientationLock.allCases, id: \.self) { orientation in
                    Text(orientation.displayName).tag(orientation)
                }
            }
            .pickerStyle(.menu)
        } header: {
            Text("Camera Settings")
        } footer: {
            Text("Choose your preferred camera and orientation settings.")
        }
    }
    
    // MARK: - Presets Section
    
    private var presetsSection: some View {
        Section {
            // Quick presets
            ForEach(settingsViewModel.availablePresets) { preset in
                Button(action: {
                    settingsViewModel.applyPreset(preset)
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(preset.name)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            Text("\(preset.resolution.displayName) • \(preset.frameRate.displayName) • \(preset.bitrate.displayName)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if preset.name.contains("Custom") {
                            Button("Delete") {
                                settingsViewModel.deleteCustomPreset(preset)
                            }
                            .foregroundColor(.red)
                            .font(.caption)
                        }
                    }
                }
            }
            
            // Save current as preset
            Button("Save Current Settings as Preset") {
                showingPresetSheet = true
            }
            .foregroundColor(.blue)
        } header: {
            Text("Video Presets")
        } footer: {
            Text("Quickly apply common streaming configurations or save your own custom presets.")
        }
    }
    
    // MARK: - Advanced Settings Section
    
    private var advancedSettingsSection: some View {
        Section {
            Toggle("Show Advanced Settings", isOn: $settingsViewModel.showAdvancedSettings)
            
            if settingsViewModel.showAdvancedSettings {
                // Additional advanced options can be added here
                Button("Reset All Settings") {
                    showingResetAlert = true
                }
                .foregroundColor(.red)
            }
        } header: {
            Text("Advanced")
        }
    }
    
    // MARK: - Preset Sheet
    
    private var presetSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Preset Name", text: $newPresetName)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Save Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingPresetSheet = false
                        newPresetName = ""
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !newPresetName.isEmpty {
                            settingsViewModel.saveCurrentAsPreset(name: newPresetName)
                            showingPresetSheet = false
                            newPresetName = ""
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(newPresetName.isEmpty)
                }
            }
        }
    }
}

// MARK: - Previews

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settingsViewModel: SettingsViewModel())
            .previewDisplayName("Settings View")
    }
}