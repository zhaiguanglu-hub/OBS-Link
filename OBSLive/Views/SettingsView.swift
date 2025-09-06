//
//  SettingsView.swift
//  OBSLive
//
//  Created by OBS Live Team
//

import SwiftUI

/// 设置界面，提供流配置和预设管理
struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingPresetCreator = false
    @State private var newPresetName = ""
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                // RTMP服务器设置
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("RTMP服务器地址")
                            .font(.headline)
                        TextField("rtmp://live.example.com/app/streamkey", text: $viewModel.rtmpURL)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                        
                        if !viewModel.rtmpURL.isEmpty && !viewModel.validateRTMPURL(viewModel.rtmpURL) {
                            Label("请输入有效的RTMP地址", systemImage: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                    }
                } header: {
                    Label("服务器配置", systemImage: "server.rack")
                }
                
                // 视频设置
                Section {
                    Picker("分辨率", selection: $viewModel.selectedResolution) {
                        ForEach(VideoResolution.allCases, id: \.self) { resolution in
                            Text(resolution.rawValue).tag(resolution)
                        }
                    }
                    
                    Picker("帧率", selection: $viewModel.frameRate) {
                        ForEach(viewModel.availableFrameRates, id: \.self) { rate in
                            Text("\(rate) fps").tag(rate)
                        }
                    }
                    
                    Toggle("自动调整码率", isOn: $viewModel.autoAdjustBitrate)
                    
                    if !viewModel.autoAdjustBitrate {
                        HStack {
                            Text("视频码率")
                            Spacer()
                            TextField("2500", value: $viewModel.videoBitrate, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                            Text("kbps")
                        }
                    } else {
                        HStack {
                            Text("推荐码率")
                            Spacer()
                            Text("\(viewModel.selectedResolution.recommendedBitrate) kbps")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                } header: {
                    Label("视频设置", systemImage: "video")
                } footer: {
                    Text("更高的分辨率和码率将提供更好的画质，但需要更稳定的网络连接")
                }
                
                // 音频设置
                Section {
                    Picker("音频码率", selection: $viewModel.audioBitrate) {
                        ForEach(viewModel.availableAudioBitrates, id: \.self) { bitrate in
                            Text("\(bitrate) kbps").tag(bitrate)
                        }
                    }
                    
                    Picker("采样率", selection: $viewModel.sampleRate) {
                        ForEach(viewModel.availableSampleRates, id: \.self) { rate in
                            Text("\(rate) Hz").tag(rate)
                        }
                    }
                } header: {
                    Label("音频设置", systemImage: "waveform")
                }
                
                // 预设管理
                Section {
                    ForEach(viewModel.savedPresets) { preset in
                        PresetRowView(preset: preset) {
                            viewModel.applyPreset(preset)
                            dismiss()
                        } onDelete: {
                            viewModel.deletePreset(preset)
                        }
                    }
                    
                    Button(action: {
                        showingPresetCreator = true
                    }) {
                        Label("保存当前设置为预设", systemImage: "plus.circle")
                    }
                } header: {
                    Label("预设管理", systemImage: "list.bullet.rectangle")
                } footer: {
                    Text("预设可以帮助您快速切换不同的直播场景配置")
                }
                
                // 其他设置
                Section {
                    Button("重置为默认设置", role: .destructive) {
                        showingResetAlert = true
                    }
                } header: {
                    Label("其他", systemImage: "gearshape.2")
                }
            }
            .navigationTitle("直播设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingPresetCreator) {
            PresetCreatorView(presetName: $newPresetName) {
                viewModel.saveCurrentAsPreset(name: newPresetName)
                newPresetName = ""
            }
        }
        .alert("重置设置", isPresented: $showingResetAlert) {
            Button("取消", role: .cancel) { }
            Button("重置", role: .destructive) {
                viewModel.resetToDefaults()
            }
        } message: {
            Text("这将重置所有设置为默认值，但不会删除已保存的预设。")
        }
    }
}

// MARK: - Supporting Views

/// 预设行视图
struct PresetRowView: View {
    let preset: StreamPreset
    let onApply: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(preset.name)
                    .font(.headline)
                
                Text(presetDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("应用") {
                onApply()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("删除", role: .destructive) {
                onDelete()
            }
        }
    }
    
    private var presetDescription: String {
        let settings = preset.settings
        return "\(settings.resolution.rawValue.components(separatedBy: " ").first ?? "") • \(settings.frameRate)fps • \(settings.videoBitrate)kbps"
    }
}

/// 预设创建视图
struct PresetCreatorView: View {
    @Binding var presetName: String
    let onCreate: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("预设名称")
                        .font(.headline)
                    TextField("输入预设名称", text: $presetName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("新建预设")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        onCreate()
                        dismiss()
                    }
                    .disabled(presetName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel())
}