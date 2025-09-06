# OBS Live for iOS

A professional mobile streaming application for iOS that allows users to stream high-quality video to RTMP servers with advanced controls and settings.

## Features

### Core Streaming
- **RTMP Streaming**: Stream to any RTMP server (Twitch, YouTube, custom servers)
- **Camera Support**: Front and back camera with tap-to-focus
- **Audio Support**: High-quality audio streaming with configurable settings
- **Real-time Stats**: Live monitoring of bitrate, frame drops, and connection status

### Video Configuration
- **Multiple Resolutions**: 720p, 1080p, 1440p, 4K support
- **Frame Rates**: 24fps, 30fps, 60fps options
- **Bitrate Control**: Manual bitrate settings or automatic optimization
- **Orientation Lock**: Portrait, landscape, or auto orientation

### User Experience
- **Modern UI**: Clean, intuitive SwiftUI interface
- **Onboarding**: Guided setup for first-time users
- **Presets**: Save and quickly apply custom streaming configurations
- **Settings**: Comprehensive configuration options

## Technical Requirements

- **iOS**: 15.0 or later
- **Xcode**: 15.0 or later
- **Swift**: 5.9 or later
- **Dependencies**: HaishinKit for RTMP streaming

## Project Structure

```
OBSLiveiOS/
├── Models/
│   ├── StreamingModels.swift      # Data models for streaming configuration
│   └── SettingsViewModel.swift    # Settings management and persistence
├── Managers/
│   └── StreamingManager.swift     # Core streaming functionality
├── Views/
│   ├── StreamingView.swift        # Main streaming interface
│   ├── SettingsView.swift         # Settings configuration
│   ├── CameraPreviewView.swift    # Camera preview components
│   └── StatsOverlayView.swift     # Real-time statistics display
├── OBSLiveiOSApp.swift           # App entry point
└── ContentView.swift             # Main content view with onboarding
```

## Setup Instructions

### 1. Clone and Open Project
```bash
git clone <repository-url>
cd OBSLiveiOS
open OBSLiveiOS.xcodeproj
```

### 2. Configure Dependencies
The project uses Swift Package Manager for dependency management. HaishinKit will be automatically resolved when you open the project in Xcode.

### 3. Configure App Permissions
The app requires camera and microphone permissions. These are already configured in the Info.plist:
- `NSCameraUsageDescription`: "This app needs camera access to stream live video."
- `NSMicrophoneUsageDescription`: "This app needs microphone access to stream live audio."

### 4. Build and Run
1. Select your target device or simulator
2. Build and run the project (⌘+R)
3. Grant camera and microphone permissions when prompted

## Usage

### First Launch
1. The app will show an onboarding flow
2. Enter your RTMP server URL (e.g., `rtmp://live.twitch.tv/live/YOUR_STREAM_KEY`)
3. Complete the setup process

### Streaming
1. Tap the "Go Live" button to start streaming
2. Use the gear icon to access settings
3. Tap the camera icon to switch between front/back cameras
4. Double-tap the preview to toggle controls visibility

### Settings Configuration
- **Server**: Configure your RTMP server URL
- **Video**: Set resolution, frame rate, and bitrate
- **Audio**: Configure sample rate and bitrate
- **Camera**: Choose camera position and orientation lock
- **Presets**: Save and manage custom configurations

## RTMP Server Examples

### Twitch
```
rtmp://live.twitch.tv/live/YOUR_STREAM_KEY
```

### YouTube Live
```
rtmp://a.rtmp.youtube.com/live2/YOUR_STREAM_KEY
```

### Custom Server
```
rtmp://your-server.com/live/stream_key
```

## Architecture

### MVVM Pattern
The app follows the Model-View-ViewModel (MVVM) pattern:
- **Models**: Data structures and business logic
- **Views**: SwiftUI user interface components
- **ViewModels**: Observable objects that manage state and business logic

### Key Components

#### StreamingManager
- Manages RTMP connection and streaming
- Handles camera and microphone setup
- Provides real-time statistics
- Manages streaming state and errors

#### SettingsViewModel
- Manages user preferences and configuration
- Persists settings using UserDefaults
- Provides validation and preset management

#### CameraPreviewView
- SwiftUI wrapper for camera preview
- Supports tap-to-focus functionality
- Handles camera switching and orientation

## Customization

### Adding New Video Resolutions
Edit `StreamingModels.swift` and add new cases to `VideoResolution`:

```swift
static let allCases: [VideoResolution] = [
    // ... existing resolutions
    VideoResolution(width: 3840, height: 2160, name: "4K (UHD)"),
    VideoResolution(width: 2560, height: 1440, name: "1440p (QHD)")
]
```

### Adding New Presets
Edit `StreamingModels.swift` and add to `VideoPreset.presets`:

```swift
static let presets: [VideoPreset] = [
    // ... existing presets
    VideoPreset(name: "Custom Preset", resolution: .allCases[1], frameRate: .allCases[2], bitrate: .allCases[3])
]
```

## Troubleshooting

### Common Issues

1. **Camera not working**: Ensure camera permissions are granted
2. **Microphone not working**: Check microphone permissions
3. **Streaming fails**: Verify RTMP URL is correct and server is accessible
4. **Poor quality**: Adjust bitrate settings or lower resolution
5. **High battery usage**: Reduce frame rate or resolution

### Debug Information
- Check the stats overlay for real-time streaming information
- Monitor frame drop rates to identify performance issues
- Use Xcode's Instruments to profile CPU and memory usage

## Future Enhancements

### Planned Features
- Screen recording support (ReplayKit)
- Multiple platform streaming
- Advanced audio mixing
- Custom filters and effects
- Cloud storage integration
- Analytics dashboard

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review the code documentation

---

**Note**: This is a development version. For production use, ensure proper testing and security considerations are addressed.