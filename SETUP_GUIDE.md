# OBS Live iOS - Setup Guide

## Quick Start

### 1. Open in Xcode
```bash
open OBSLiveiOS.xcodeproj
```

### 2. Add HaishinKit Dependency
1. In Xcode, go to **File → Add Package Dependencies**
2. Enter URL: `https://github.com/shogo4405/HaishinKit.swift.git`
3. Click **Add Package**
4. Select **HaishinKit** and click **Add Package**

### 3. Configure Signing
1. Select the project in the navigator
2. Go to **Signing & Capabilities**
3. Select your development team
4. Ensure **Bundle Identifier** is unique (e.g., `com.yourname.obsliveios`)

### 4. Build and Run
1. Select your target device (iPhone/iPad or Simulator)
2. Press **⌘+R** to build and run
3. Grant camera and microphone permissions when prompted

## Project Structure

```
OBSLiveiOS/
├── 📱 OBSLiveiOSApp.swift          # App entry point
├── 🎯 ContentView.swift            # Main content with onboarding
├── 📊 Models/
│   ├── StreamingModels.swift       # Data models
│   └── SettingsViewModel.swift     # Settings management
├── ⚙️ Managers/
│   └── StreamingManager.swift      # Core streaming logic
├── 🎨 Views/
│   ├── StreamingView.swift         # Main streaming interface
│   ├── SettingsView.swift          # Settings configuration
│   ├── CameraPreviewView.swift     # Camera preview
│   └── StatsOverlayView.swift      # Real-time statistics
├── 📋 Info.plist                   # App permissions
└── 🎨 Assets.xcassets/             # App icons and colors
```

## Key Features Implemented

### ✅ Core Streaming
- RTMP streaming to any server
- Front/back camera support
- High-quality audio streaming
- Real-time statistics monitoring

### ✅ Video Configuration
- Multiple resolutions (720p, 1080p, 1440p, 4K)
- Frame rates (24fps, 30fps, 60fps)
- Bitrate control (manual/auto)
- Orientation lock options

### ✅ User Experience
- Modern SwiftUI interface
- Guided onboarding flow
- Custom preset management
- Comprehensive settings

### ✅ Advanced Features
- Tap-to-focus camera
- Real-time stats overlay
- Error handling and recovery
- Settings persistence

## Configuration Examples

### Twitch Streaming
```
RTMP URL: rtmp://live.twitch.tv/live/YOUR_STREAM_KEY
Resolution: 1080p
Frame Rate: 30fps
Bitrate: 2500 kbps
```

### YouTube Live
```
RTMP URL: rtmp://a.rtmp.youtube.com/live2/YOUR_STREAM_KEY
Resolution: 1080p
Frame Rate: 30fps
Bitrate: 5000 kbps
```

### Custom Server
```
RTMP URL: rtmp://your-server.com/live/stream_key
Resolution: 720p
Frame Rate: 30fps
Bitrate: 1000 kbps
```

## Troubleshooting

### Common Issues

1. **Build Errors**
   - Ensure HaishinKit is properly added
   - Check iOS deployment target (15.0+)
   - Verify Swift version (5.9+)

2. **Camera Not Working**
   - Check camera permissions in Settings
   - Ensure device has camera hardware
   - Try switching between front/back cameras

3. **Streaming Fails**
   - Verify RTMP URL format
   - Check network connectivity
   - Ensure server is accessible

4. **Performance Issues**
   - Lower resolution or frame rate
   - Reduce bitrate settings
   - Close other apps

### Debug Tips

- Use the stats overlay to monitor performance
- Check Xcode console for error messages
- Test with different network conditions
- Use Instruments for performance profiling

## Next Steps

### For Development
1. Test on physical device (camera requires real hardware)
2. Configure your RTMP server for testing
3. Customize UI colors and branding
4. Add additional video presets

### For Production
1. Add proper error handling
2. Implement analytics
3. Add crash reporting
4. Optimize for App Store submission

## Dependencies

- **HaishinKit**: RTMP streaming library
- **AVFoundation**: Camera and audio capture
- **SwiftUI**: User interface framework
- **Combine**: Reactive programming

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+
- Physical device for camera testing

---

**Ready to stream!** 🎥✨

The app is now fully functional and ready for testing. Start with the onboarding flow to configure your RTMP server, then tap "Go Live" to begin streaming!