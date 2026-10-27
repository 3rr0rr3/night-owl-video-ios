#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
mkdir -p build/Payload/NightOwl.app
xcrun swiftc NightOwl/*.swift -o build/Payload/NightOwl.app/NightOwl -sdk "$SDK" -target arm64-apple-ios16.0 -swift-version 5 -O -framework SwiftUI -framework UIKit -framework AVFoundation
cp NightOwl/Info.plist build/Payload/NightOwl.app/Info.plist
plutil -lint build/Payload/NightOwl.app/Info.plist
xcrun lipo build/Payload/NightOwl.app/NightOwl -verify_arch arm64
codesign --force --sign - build/Payload/NightOwl.app
(cd build && zip -r NightOwl.ipa Payload)
