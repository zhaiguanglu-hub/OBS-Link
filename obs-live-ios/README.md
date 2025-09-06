# OBS Live for iOS (Starter)

A SwiftUI-based starter for an iOS live streaming app that pushes to RTMP servers (Twitch, YouTube, Bilibili, custom RTMP). This repo contains Swift files you can drop into an Xcode project, plus setup notes.

This code uses HaishinKit for RTMP streaming.

## Requirements

- Xcode 15+
- iOS 15.0+
- A real iPhone device for testing (camera/mic/RTMP)

## Quick Start (Xcode Project)

1. Create a new iOS App project in Xcode
   - Interface: SwiftUI
   - Language: Swift
2. Add permissions to `Info.plist`:
   - `NSCameraUsageDescription` = "This app requires camera access for live streaming."
   - `NSMicrophoneUsageDescription` = "This app requires microphone access for live streaming."
3. Add HaishinKit via Swift Package Manager:
   - File → Add Packages…
   - Enter package URL: `https://github.com/shogo4405/HaishinKit.swift`
   - Add the `HaishinKit` product to your app target.
4. Drag the `App`, `Streaming`, `Settings`, `UI`, and `Utils` folders from this repo into your Xcode project (Use "Copy items if needed").
5. Build and run on a real device.

## How to Use

- Open Settings (gear button) to provide your RTMP URL, select resolution, FPS, and bitrates.
- Tap Start to begin streaming. Tap Stop to end.
- Use the camera switch button to toggle front/back.

### RTMP URL Format

- Preferred: `rtmp://host:1935/app/streamKey`
  - The app splits the URL into `rtmp://host:1935/app` and `streamKey` internally.

## Customization

- `StreamingManager.swift` manages `RTMPConnection` and `RTMPStream`.
- `SettingsViewModel.swift` stores user preferences in `UserDefaults`.
- `CameraPreviewView.swift` wraps HaishinKit's `HKView` for SwiftUI preview.
- `StatsOverlayView.swift` shows a basic status panel (elapsed time, configured fps/bitrate).

## Testing with a Local RTMP Server (Docker)

```bash
# Nginx-RTMP quick start
cat > nginx-rtmp.conf <<'NGINX'
worker_processes  auto;
rtmp_auto_push on;
events {}
rtmp {
    server {
        listen 1935;
        chunk_size 4096;
        application live {
            live on;
            record off;
        }
    }
}
http {
    server { listen 8080; location / { return 200 'OK'; } }
}
NGINX

docker run --rm -p 1935:1935 -p 8080:8080 -v "$PWD/nginx-rtmp.conf":/etc/nginx/nginx.conf:ro alfg/nginx-rtmp
```

- Use `rtmp://<your-computer-ip>:1935/live/test` as your URL in the app.
- View the stream with a player that supports RTMP or restream to HLS using Nginx config as needed.

## Orientation & Haptics

- Haptics are triggered on start/stop and camera switch.
- Orientation lock placeholder is provided; you can tailor it to your app's orientation policy.

## Known Limitations (Starter)

- Minimal stats (elapsed time, configured fps/bitrate). You can extend with HaishinKit stream info callbacks.
- Not a full Xcode project. Add these files to your project per the steps above.

## Roadmap Ideas

- Preset profiles management UI
- ReplayKit Broadcast Upload Extension for screen capture
- Multi-destination streaming
- Filters/beautification pipeline

---

This starter is intended for learning and bootstrapping. Harden and test before production.