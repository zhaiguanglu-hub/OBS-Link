//
//  ContentView.swift
//  OBSLive
//
//  Created by OBS Live Team
//

import SwiftUI

struct ContentView: View {
    @StateObject private var streamingManager = StreamingManager()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var showingSettings = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 相机预览背景
                CameraPreviewView(streamingManager: streamingManager)
                    .ignoresSafeArea()
                
                // 状态覆盖层
                if streamingManager.isStreaming {
                    StatsOverlayView(streamingManager: streamingManager)
                        .padding()
                }
                
                // 底部控制栏
                VStack {
                    Spacer()
                    
                    // 控制栏背景
                    HStack(spacing: 30) {
                        // 设置按钮
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        // 主直播按钮
                        Button(action: {
                            if streamingManager.isStreaming {
                                streamingManager.stopStreaming()
                            } else {
                                streamingManager.startStreaming(
                                    rtmpURL: settingsViewModel.rtmpURL,
                                    settings: settingsViewModel.currentSettings
                                )
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(streamingManager.isStreaming ? Color.red : Color.blue)
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: streamingManager.isStreaming ? "stop.fill" : "play.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                        .scaleEffect(streamingManager.isStreaming ? 0.9 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: streamingManager.isStreaming)
                        
                        Spacer()
                        
                        // 切换摄像头按钮
                        Button(action: {
                            streamingManager.switchCamera()
                        }) {
                            Image(systemName: "camera.rotate.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .disabled(streamingManager.isStreaming)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0),
                                Color.black.opacity(0.7)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 150)
                    )
                }
                
                // 连接状态指示器
                if streamingManager.connectionState != .idle {
                    VStack {
                        HStack {
                            Spacer()
                            ConnectionStatusView(state: streamingManager.connectionState)
                                .padding()
                        }
                        Spacer()
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: settingsViewModel)
        }
        .onAppear {
            streamingManager.setupCamera()
        }
        .alert("直播错误", isPresented: .constant(streamingManager.lastError != nil)) {
            Button("确定") {
                streamingManager.clearError()
            }
        } message: {
            if let error = streamingManager.lastError {
                Text(error.localizedDescription)
            }
        }
    }
}

// 连接状态视图
struct ConnectionStatusView: View {
    let state: StreamingManager.ConnectionState
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
                .scaleEffect(state == .connecting ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: state == .connecting)
            
            Text(statusText)
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.7))
        .clipShape(Capsule())
    }
    
    private var statusColor: Color {
        switch state {
        case .idle:
            return .gray
        case .connecting:
            return .yellow
        case .connected:
            return .green
        case .disconnected:
            return .red
        }
    }
    
    private var statusText: String {
        switch state {
        case .idle:
            return "待机"
        case .connecting:
            return "连接中"
        case .connected:
            return "已连接"
        case .disconnected:
            return "连接断开"
        }
    }
}

#Preview {
    ContentView()
}