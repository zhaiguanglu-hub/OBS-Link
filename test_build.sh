#!/bin/bash

# Test script to verify iOS project structure
echo "Testing OBS Live iOS Project Structure..."

# Check if Xcode project exists
if [ -f "OBSLiveiOS.xcodeproj/project.pbxproj" ]; then
    echo "✅ Xcode project file found"
else
    echo "❌ Xcode project file missing"
    exit 1
fi

# Check if all Swift files exist
swift_files=(
    "OBSLiveiOS/OBSLiveiOSApp.swift"
    "OBSLiveiOS/ContentView.swift"
    "OBSLiveiOS/Models/StreamingModels.swift"
    "OBSLiveiOS/Models/SettingsViewModel.swift"
    "OBSLiveiOS/Managers/StreamingManager.swift"
    "OBSLiveiOS/Views/StreamingView.swift"
    "OBSLiveiOS/Views/SettingsView.swift"
    "OBSLiveiOS/Views/CameraPreviewView.swift"
    "OBSLiveiOS/Views/StatsOverlayView.swift"
)

for file in "${swift_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
    fi
done

# Check if Info.plist exists
if [ -f "OBSLiveiOS/Info.plist" ]; then
    echo "✅ Info.plist found"
else
    echo "❌ Info.plist missing"
fi

# Check if Assets exist
if [ -d "OBSLiveiOS/Assets.xcassets" ]; then
    echo "✅ Assets.xcassets found"
else
    echo "❌ Assets.xcassets missing"
fi

echo ""
echo "Project structure verification complete!"
echo ""
echo "To build and run the project:"
echo "1. Open OBSLiveiOS.xcodeproj in Xcode"
echo "2. Select your target device"
echo "3. Build and run (⌘+R)"
echo ""
echo "Note: Make sure to add HaishinKit dependency in Xcode:"
echo "File -> Add Package Dependencies -> https://github.com/shogo4405/HaishinKit.swift.git"