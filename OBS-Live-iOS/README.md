OBS Live for iOS (WIP)

Overview

OBS Live for iOS is a Swift/SwiftUI mobile RTMP live streaming app. It targets iOS 15+ and focuses on high-quality streaming with a clean UI. The app integrates with HaishinKit (Swift) for camera/audio capture and RTMP push.

Status

- MVP scaffold in place (SwiftUI views + managers)
- Ready to integrate HaishinKit via SPM in Xcode

Key Features (MVP)

- Custom RTMP URL (e.g., rtmp://live.example.com/app/streamkey)
- Camera preview, front/back switching
- Microphone audio capture
- Video settings: resolution presets, FPS, bitrate
- Audio settings: sample rate, bitrate
- Start/Stop streaming with status and basic stats overlay

Tech Stack

- Swift 5+, SwiftUI for UI
- AVFoundation, CoreVideo
- HaishinKit (RTMP)

Project Structure

- App/OBSLiveApp.swift — App entry and scene setup
- Views/MainStreamingView.swift — Main camera preview and controls
- Views/CameraPreviewView.swift — HaishinKit HKView wrapper (UIViewRepresentable)
- Views/StatsOverlayView.swift — Live stats overlay
- Managers/StreamingManager.swift — RTMP streaming orchestration
- ViewModels/SettingsViewModel.swift — User settings (UserDefaults persistence)
- docs/requirements.md — Full product requirements (Chinese)
- docs/ROADMAP.md — Version roadmap

Xcode Setup

1) Open this folder in Xcode (or create an iOS App project and copy sources in):
   - File > Open > select OBS-Live-iOS
2) Add required iOS permissions in Info:
   - NSCameraUsageDescription
   - NSMicrophoneUsageDescription
3) Add dependency (HaishinKit) via Swift Package Manager:
   - File > Add Packages…
   - URL: https://github.com/shogo4405/HaishinKit.swift
   - Up to Next Major Version
4) Targets > Signing & Capabilities: configure your team and bundle identifier.

Permissions Strings (example)

- Camera access is required to capture video for live streaming.
- Microphone access is required to capture audio for live streaming.

Build & Run

- Use a real device (simulator lacks camera/mic/RTMP networking performance)
- Press Run to launch, configure RTMP URL in Settings, then Start Streaming

Notes

- Some code paths are guarded with `#if canImport(HaishinKit)` so the project can compile before adding the package. After adding HaishinKit, these paths will activate automatically.
- For screen broadcasting (ReplayKit), plan a Broadcast Upload Extension in a later version.

License

TBD.

