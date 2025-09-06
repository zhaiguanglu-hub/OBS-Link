# OBS Live for iOS

A powerful and intuitive iOS streaming app that allows content creators to stream high-quality video directly from their iPhone to any RTMP server.

## Features

### Core Streaming
- **RTMP Streaming**: Stream to any RTMP server (Twitch, YouTube, Bilibili, custom servers)
- **High Quality Video**: Support for 720p, 1080p, and 4K resolutions
- **Flexible Frame Rates**: 24, 30, and 60 fps options
- **Adjustable Bitrate**: Fine-tune video quality from 500 to 10,000 kbps
- **Audio Configuration**: Customizable sample rates and bitrates

### User Experience
- **Modern UI**: Clean, intuitive interface following iOS design guidelines
- **Real-time Stats**: Live monitoring of bitrate, FPS, and streaming duration
- **Preset Management**: Save and quickly switch between streaming configurations
- **Camera Switching**: Seamlessly switch between front and rear cameras
- **Orientation Support**: Stream in portrait or landscape mode with lock options

### Performance
- **Hardware Acceleration**: Leverages iOS hardware encoding for efficient streaming
- **Low Latency**: Optimized for minimal delay
- **Battery Efficient**: Optimized resource usage for longer streaming sessions

## Requirements

- iOS 15.0 or later
- iPhone X or newer (recommended)
- Stable internet connection (WiFi or 4G/5G)

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/obslive-ios.git
cd obslive-ios
```

### 2. Open in Xcode
1. Open `OBSLive.xcodeproj` in Xcode 15 or later
2. Select your development team in project settings
3. Update the bundle identifier to match your developer account

### 3. Configure Dependencies
The project uses Swift Package Manager. Dependencies will be automatically resolved when you open the project in Xcode.

### 4. Build and Run
1. Connect your iPhone
2. Select your device as the build target
3. Press Cmd+R to build and run

## Configuration

### Server Settings
1. Open Settings in the app
2. Enter your RTMP server URL (e.g., `rtmp://live.twitch.tv/live`)
3. Enter your stream key

### Video Quality
Choose from preset configurations or customize:
- Resolution: 720p, 1080p, 4K
- Frame Rate: 24, 30, 60 fps
- Bitrate: 500-10,000 kbps

### Audio Settings
- Sample Rate: 44.1kHz or 48kHz
- Bitrate: 64-320 kbps

## Development with Cursor

This project is optimized for development with Cursor IDE:

1. **Code Generation**: Use Cmd+K to generate Swift code snippets
2. **API Help**: Select HaishinKit code and ask for explanations
3. **Error Fixing**: Paste compiler errors for fix suggestions
4. **Documentation**: Generate function documentation automatically

## Architecture

### Project Structure
```
OBSLive/
├── Models/          # Data models
├── Views/           # SwiftUI views
├── ViewModels/      # View models with business logic
├── Services/        # Core services (streaming, etc.)
├── Utils/           # Utility functions
└── Resources/       # Assets and configurations
```

### Key Components
- **StreamingManager**: Handles RTMP connection and streaming
- **SettingsViewModel**: Manages user preferences and configurations
- **CameraPreviewView**: Displays camera feed
- **StatsOverlayView**: Shows real-time streaming statistics

## Testing

### Local RTMP Server
For testing, you can set up a local RTMP server using Docker:

```bash
docker run -d -p 1935:1935 --name nginx-rtmp tiangolo/nginx-rtmp
```

Then use `rtmp://localhost/live` as your server URL.

### Test Platforms
- **Twitch**: `rtmp://live.twitch.tv/live`
- **YouTube**: `rtmp://a.rtmp.youtube.com/live2`
- **Facebook**: `rtmps://live-api-s.facebook.com:443/rtmp`

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [HaishinKit](https://github.com/shogo4405/HaishinKit.swift) - RTMP streaming library
- OBS Project for inspiration
- iOS developer community

## Roadmap

### Version 1.5
- [ ] Basic filters and color adjustments
- [ ] Streaming history
- [ ] Enhanced preset management

### Version 2.0
- [ ] Screen recording support (ReplayKit)
- [ ] Multi-platform simultaneous streaming
- [ ] Advanced audio mixing
- [ ] Stream overlays and graphics

## Support

For issues and feature requests, please use the GitHub issue tracker.