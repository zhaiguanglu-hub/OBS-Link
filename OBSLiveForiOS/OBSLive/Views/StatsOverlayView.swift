import SwiftUI

struct StatsOverlayView: View {
    @EnvironmentObject var streamingManager: StreamingManager
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        if settingsViewModel.showStats && streamingManager.isStreaming {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .foregroundColor(.red)
                    Text("LIVE")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.red)
                    Text(formatDuration(streamingManager.streamingDuration))
                        .font(.system(size: 12, weight: .medium))
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Image(systemName: "video")
                            .font(.system(size: 10))
                        Text("\(settingsViewModel.selectedResolution.displayName)")
                            .font(.system(size: 11))
                    }
                    
                    HStack {
                        Image(systemName: "speedometer")
                            .font(.system(size: 10))
                        Text("\(Int(streamingManager.currentFPS)) fps")
                            .font(.system(size: 11))
                    }
                    
                    HStack {
                        Image(systemName: "arrow.up.circle")
                            .font(.system(size: 10))
                        Text("\(streamingManager.currentBitrate) kbps")
                            .font(.system(size: 11))
                    }
                }
            }
            .padding(8)
            .background(Color.black.opacity(0.7))
            .cornerRadius(8)
            .foregroundColor(.white)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}