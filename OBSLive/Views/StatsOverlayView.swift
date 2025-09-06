//
//  StatsOverlayView.swift
//  OBSLive
//
//  Created by OBS Live Team
//

import SwiftUI

/// 直播统计信息覆盖视图，显示实时流数据
struct StatsOverlayView: View {
    @ObservedObject var streamingManager: StreamingManager
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 0) {
                    // 简化状态指示器
                    if !isExpanded {
                        CompactStatsView(stats: streamingManager.streamStats)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isExpanded = true
                                }
                            }
                    } else {
                        // 详细统计信息
                        DetailedStatsView(stats: streamingManager.streamStats)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isExpanded = false
                                }
                            }
                    }
                }
            }
            
            Spacer()
        }
    }
}

/// 紧凑型统计视图
struct CompactStatsView: View {
    let stats: StreamStats
    
    var body: some View {
        HStack(spacing: 8) {
            // 直播时长
            Text(formatDuration(stats.streamDuration))
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.white)
            
            // 分隔符
            Circle()
                .fill(Color.white.opacity(0.6))
                .frame(width: 3, height: 3)
            
            // 码率指示器
            HStack(spacing: 4) {
                Circle()
                    .fill(bitrateIndicatorColor)
                    .frame(width: 6, height: 6)
                
                Text("\(stats.currentBitrate)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.7))
        .clipShape(Capsule())
    }
    
    private var bitrateIndicatorColor: Color {
        if stats.currentBitrate > 2000 {
            return .green
        } else if stats.currentBitrate > 1000 {
            return .yellow
        } else {
            return .red
        }
    }
}

/// 详细统计视图
struct DetailedStatsView: View {
    let stats: StreamStats
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            // 标题
            HStack {
                Text("直播统计")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.up")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            // 统计信息网格
            VStack(alignment: .trailing, spacing: 4) {
                StatRow(label: "时长", value: formatDuration(stats.streamDuration))
                StatRow(label: "码率", value: "\(stats.currentBitrate) KB/s")
                StatRow(label: "网速", value: "\(stats.networkSpeed) KB/s")
                StatRow(label: "丢帧", value: "\(stats.droppedFrames)")
            }
        }
        .padding(12)
        .background(Color.black.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .frame(minWidth: 140)
    }
}

/// 统计行视图
struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(.caption2, design: .default))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(.white)
        }
    }
}

/// 网络质量指示器
struct NetworkQualityIndicator: View {
    let speed: Int // KB/s
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(barColor(for: index))
                    .frame(width: 3, height: CGFloat(4 + index * 2))
            }
        }
    }
    
    private func barColor(for index: Int) -> Color {
        let qualityLevel = networkQualityLevel
        return index < qualityLevel ? .green : .gray.opacity(0.3)
    }
    
    private var networkQualityLevel: Int {
        if speed > 3000 { return 4 }      // 优秀
        else if speed > 2000 { return 3 } // 良好
        else if speed > 1000 { return 2 } // 一般
        else if speed > 500 { return 1 }  // 较差
        else { return 0 }                 // 很差
    }
}

/// 性能监控视图
struct PerformanceMonitorView: View {
    let stats: StreamStats
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 性能概览
            HStack {
                Text("性能")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    showingDetails.toggle()
                }) {
                    Image(systemName: showingDetails ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                }
            }
            .foregroundColor(.white)
            
            if showingDetails {
                VStack(alignment: .leading, spacing: 4) {
                    PerformanceBar(label: "CPU", value: 0.6, color: .blue)
                    PerformanceBar(label: "内存", value: 0.4, color: .green)
                    PerformanceBar(label: "网络", value: Double(stats.networkSpeed) / 5000.0, color: .orange)
                }
            }
        }
        .padding(10)
        .background(Color.black.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

/// 性能条视图
struct PerformanceBar: View {
    let label: String
    let value: Double // 0.0 - 1.0
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.white)
                .frame(width: 30, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geometry.size.width * value, height: 4)
                        .animation(.easeInOut(duration: 0.5), value: value)
                }
            }
            .frame(height: 4)
            
            Text("\(Int(value * 100))%")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 30, alignment: .trailing)
        }
    }
}

// MARK: - Helper Functions

/// 格式化时长显示
private func formatDuration(_ seconds: Int) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let secs = seconds % 60
    
    if hours > 0 {
        return String(format: "%d:%02d:%02d", hours, minutes, secs)
    } else {
        return String(format: "%d:%02d", minutes, secs)
    }
}

/// 格式化数据大小
private func formatDataSize(_ bytes: Int64) -> String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useKB, .useMB, .useGB]
    formatter.countStyle = .file
    return formatter.string(fromByteCount: bytes)
}

#Preview {
    ZStack {
        Color.black
        
        StatsOverlayView(streamingManager: StreamingManager())
            .padding()
    }
}