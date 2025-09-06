import Foundation

struct VideoResolution: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    let width: Int
    let height: Int
    
    // Common presets
    static let preset720p = VideoResolution(name: "720p", width: 1280, height: 720)
    static let preset1080p = VideoResolution(name: "1080p", width: 1920, height: 1080)
    static let preset4K = VideoResolution(name: "4K", width: 3840, height: 2160)
    
    static let allPresets = [preset720p, preset1080p, preset4K]
    
    var displayName: String {
        return "\(name) (\(width)×\(height))"
    }
}