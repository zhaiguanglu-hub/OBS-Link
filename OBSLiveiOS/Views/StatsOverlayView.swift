import SwiftUI

/// Real-time streaming statistics overlay
struct StatsOverlayView: View {
    let stats: StreamingStats
    let status: StreamingStatus
    let isVisible: Bool
    
    @State private var isExpanded = false
    
    var body: some View {
        if isVisible {
            VStack(alignment: .leading, spacing: 8) {
                // Status indicator
                HStack(spacing: 8) {
                    statusIndicator
                    Text(status.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 4) {
                        // Network status
                        HStack(spacing: 6) {
                            Image(systemName: stats.networkStatus.icon)
                                .foregroundColor(networkStatusColor)
                                .font(.caption2)
                            Text(stats.networkStatus.displayName)
                                .font(.caption2)
                        }
                        
                        // Bitrate info
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.circle")
                                .foregroundColor(.blue)
                                .font(.caption2)
                            Text("\(stats.currentBitrate) kbps")
                                .font(.caption2)
                        }
                        
                        // Frame drop rate
                        if stats.frameDropRate > 0 {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(stats.frameDropRate > 5 ? .red : .orange)
                                    .font(.caption2)
                                Text("\(String(format: "%.1f", stats.frameDropRate))% dropped")
                                    .font(.caption2)
                            }
                        }
                        
                        // Stream duration
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                                .font(.caption2)
                            Text(formatDuration(stats.streamDuration))
                                .font(.caption2)
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isExpanded)
        }
    }
    
    // MARK: - Status Indicator
    
    @ViewBuilder
    private var statusIndicator: some View {
        Circle()
            .fill(statusColor)
            .frame(width: 8, height: 8)
            .overlay(
                Circle()
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(status == .streaming ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), 
                      value: status == .streaming)
    }
    
    // MARK: - Computed Properties
    
    private var statusColor: Color {
        switch status {
        case .idle:
            return .gray
        case .connecting:
            return .orange
        case .streaming:
            return .green
        case .error:
            return .red
        case .disconnected:
            return .red
        }
    }
    
    private var networkStatusColor: Color {
        switch stats.networkStatus {
        case .wifi:
            return .green
        case .cellular:
            return .orange
        case .disconnected:
            return .red
        case .unknown:
            return .gray
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

/// Compact stats view for smaller displays
struct CompactStatsView: View {
    let stats: StreamingStats
    let status: StreamingStatus
    
    var body: some View {
        HStack(spacing: 12) {
            // Status dot
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
            
            // Duration
            Text(formatDuration(stats.streamDuration))
                .font(.caption2)
                .fontWeight(.medium)
            
            // Bitrate
            Text("\(stats.currentBitrate)k")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // Network icon
            Image(systemName: stats.networkStatus.icon)
                .font(.caption2)
                .foregroundColor(networkStatusColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
    }
    
    private var statusColor: Color {
        switch status {
        case .idle: return .gray
        case .connecting: return .orange
        case .streaming: return .green
        case .error: return .red
        case .disconnected: return .red
        }
    }
    
    private var networkStatusColor: Color {
        switch stats.networkStatus {
        case .wifi: return .green
        case .cellular: return .orange
        case .disconnected: return .red
        case .unknown: return .gray
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

/// Stats view for settings screen
struct DetailedStatsView: View {
    let stats: StreamingStats
    let status: StreamingStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Stream Statistics")
                    .font(.headline)
                Spacer()
                StatusBadge(status: status)
            }
            
            // Stats grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                StatCard(
                    title: "Duration",
                    value: formatDuration(stats.streamDuration),
                    icon: "clock"
                )
                
                StatCard(
                    title: "Current Bitrate",
                    value: "\(stats.currentBitrate) kbps",
                    icon: "arrow.up.circle"
                )
                
                StatCard(
                    title: "Average Bitrate",
                    value: "\(stats.averageBitrate) kbps",
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                StatCard(
                    title: "Frame Drop Rate",
                    value: "\(String(format: "%.1f", stats.frameDropRate))%",
                    icon: "exclamationmark.triangle",
                    valueColor: stats.frameDropRate > 5 ? .red : .primary
                )
                
                StatCard(
                    title: "Total Frames",
                    value: "\(stats.totalFrames)",
                    icon: "rectangle.stack"
                )
                
                StatCard(
                    title: "Network",
                    value: stats.networkStatus.displayName,
                    icon: stats.networkStatus.icon,
                    valueColor: networkStatusColor
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        )
    }
    
    private var networkStatusColor: Color {
        switch stats.networkStatus {
        case .wifi: return .green
        case .cellular: return .orange
        case .disconnected: return .red
        case .unknown: return .gray
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

/// Individual stat card component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    var valueColor: Color = .primary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(valueColor)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
}

/// Status badge component
struct StatusBadge: View {
    let status: StreamingStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
            Text(status.displayName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(statusColor.opacity(0.2))
        )
    }
    
    private var statusColor: Color {
        switch status {
        case .idle: return .gray
        case .connecting: return .orange
        case .streaming: return .green
        case .error: return .red
        case .disconnected: return .red
        }
    }
}

// MARK: - Previews

struct StatsOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StatsOverlayView(
                stats: StreamingStats(
                    currentBitrate: 2500,
                    averageBitrate: 2400,
                    droppedFrames: 5,
                    totalFrames: 1000,
                    streamDuration: 125.5,
                    networkStatus: .wifi
                ),
                status: .streaming,
                isVisible: true
            )
            .previewDisplayName("Streaming Stats")
            
            CompactStatsView(
                stats: StreamingStats(
                    currentBitrate: 1500,
                    streamDuration: 45.2,
                    networkStatus: .cellular
                ),
                status: .streaming
            )
            .previewDisplayName("Compact Stats")
        }
    }
}