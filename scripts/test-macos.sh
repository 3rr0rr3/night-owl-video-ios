#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
swiftc -swift-version 5 NightOwl/Store.swift NightOwl/Story.swift NightOwl/WorldRules.swift Tests/StoreTests.swift -o build/store-tests
build/store-tests
SDK="$(xcrun --sdk iphonesimulator --show-sdk-path)"
ARCH="$(uname -m)"
APP=build/simulator/NightOwl.app
mkdir -p "$APP"
xcrun swiftc NightOwl/*.swift -o "$APP/NightOwl" -sdk "$SDK" -target "$ARCH-apple-ios16.0-simulator" -swift-version 5 -framework SwiftUI -framework UIKit -framework SceneKit
cp NightOwl/Info.plist "$APP/Info.plist"
DEVICE=$(xcrun simctl list devices available -j | python3 -c 'import sys,json; d=json.load(sys.stdin); print(next(x["udid"] for a in d["devices"].values() for x in a if x["name"].startswith("iPhone")))')
xcrun simctl boot "$DEVICE"
xcrun simctl bootstatus "$DEVICE" -b
xcrun simctl install "$DEVICE" "$APP"
xcrun simctl launch "$DEVICE" com.nightowl.videostore
sleep 3
xcrun simctl io "$DEVICE" screenshot build/iPhone-launch.png
xcrun simctl terminate "$DEVICE" com.nightowl.videostore

xcrun simctl launch "$DEVICE" com.nightowl.videostore --smoke-world
sleep 6
xcrun simctl io "$DEVICE" screenshot build/iPhone-3D.png
xcrun simctl terminate "$DEVICE" com.nightowl.videostore
