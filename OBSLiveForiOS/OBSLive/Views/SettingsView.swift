import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showPresetNameAlert = false
    @State private var presetName = ""
    
    var body: some View {
        NavigationView {
            Form {
                // Server Settings Section
                Section {
                    TextField("RTMP Server URL", text: $settingsViewModel.serverURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(.URL)
                    
                    SecureField("Stream Key", text: $settingsViewModel.streamKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Label("Server Configuration", systemImage: "server.rack")
                } footer: {
                    Text("Example: rtmp://live.twitch.tv/live")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Presets Section
                Section {
                    if !settingsViewModel.presets.isEmpty {
                        ForEach(settingsViewModel.presets) { preset in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(preset.name)
                                        .font(.headline)
                                    Text("\(preset.resolution.displayName) • \(preset.fps)fps • \(preset.videoBitrate)kbps")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if settingsViewModel.selectedPreset?.id == preset.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                settingsViewModel.loadPreset(preset)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                settingsViewModel.deletePreset(settingsViewModel.presets[index])
                            }
                        }
                    }
                    
                    Button(action: {
                        showPresetNameAlert = true
                    }) {
                        Label("Save Current Settings as Preset", systemImage: "plus.circle")
                    }
                } header: {
                    Label("Presets", systemImage: "list.bullet.rectangle")
                }
                
                // Video Settings Section
                Section {
                    Picker("Resolution", selection: $settingsViewModel.selectedResolution) {
                        ForEach(VideoResolution.allPresets) { resolution in
                            Text(resolution.displayName)
                                .tag(resolution)
                        }
                    }
                    
                    Picker("Frame Rate", selection: $settingsViewModel.fps) {
                        ForEach(settingsViewModel.availableFPS, id: \.self) { fps in
                            Text("\(fps) fps")
                                .tag(fps)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Video Bitrate: \(settingsViewModel.videoBitrate) kbps")
                            .font(.subheadline)
                        Slider(value: Binding(
                            get: { Double(settingsViewModel.videoBitrate) },
                            set: { settingsViewModel.videoBitrate = Int($0) }
                        ), in: 500...10000, step: 100)
                    }
                } header: {
                    Label("Video Settings", systemImage: "video")
                }
                
                // Audio Settings Section
                Section {
                    Picker("Sample Rate", selection: $settingsViewModel.audioSampleRate) {
                        ForEach(settingsViewModel.availableAudioSampleRates, id: \.self) { rate in
                            Text("\(Int(rate / 1000))kHz")
                                .tag(rate)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Audio Bitrate: \(settingsViewModel.audioBitrate) kbps")
                            .font(.subheadline)
                        Slider(value: Binding(
                            get: { Double(settingsViewModel.audioBitrate) },
                            set: { settingsViewModel.audioBitrate = Int($0) }
                        ), in: 64...320, step: 32)
                    }
                } header: {
                    Label("Audio Settings", systemImage: "waveform")
                }
                
                // Display Settings Section
                Section {
                    Toggle("Show Live Stats", isOn: $settingsViewModel.showStats)
                    
                    Toggle("Lock Orientation", isOn: $settingsViewModel.orientationLocked)
                    
                    if settingsViewModel.orientationLocked {
                        Picker("Streaming Mode", selection: $settingsViewModel.isLandscapeMode) {
                            Text("Portrait").tag(false)
                            Text("Landscape").tag(true)
                        }
                        .pickerStyle(.segmented)
                    }
                } header: {
                    Label("Display Settings", systemImage: "display")
                }
                
                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://github.com/yourusername/obslive-ios")!) {
                        HStack {
                            Text("Source Code")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Label("About", systemImage: "info.circle")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("New Preset", isPresented: $showPresetNameAlert) {
            TextField("Preset Name", text: $presetName)
            Button("Cancel", role: .cancel) {
                presetName = ""
            }
            Button("Save") {
                if !presetName.isEmpty {
                    settingsViewModel.savePreset(name: presetName)
                    presetName = ""
                }
            }
        } message: {
            Text("Enter a name for this preset")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsViewModel())
    }
}