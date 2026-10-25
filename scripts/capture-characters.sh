#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/characters/Payload/NightOwl.app
python3 scripts/character-capture.py
SDK="$(xcrun --sdk iphonesimulator --show-sdk-path)"
APP=build/characters/Payload/NightOwl.app
xcrun swiftc NightOwl/Store.swift build/CharacterCapture.swift -o "$APP/NightOwl" -sdk "$SDK" -target "$(uname -m)-apple-ios16.0-simulator" -swift-version 5 -framework SwiftUI -framework UIKit
cp NightOwl/Info.plist "$APP/Info.plist"
DEVICE=$(xcrun simctl list devices available -j | python3 -c 'import sys,json; d=json.load(sys.stdin); print(next(x["udid"] for a in d["devices"].values() for x in a if x["name"].startswith("iPhone")))')
xcrun simctl boot "$DEVICE"
xcrun simctl bootstatus "$DEVICE" -b
xcrun simctl status_bar "$DEVICE" override --time '9:41' --batteryState charged --batteryLevel 100
xcrun simctl install "$DEVICE" "$APP"
xcrun simctl launch "$DEVICE" com.nightowl.videostore --characters
sleep 8
xcrun simctl io "$DEVICE" screenshot build/character-lineup.png
xcrun simctl terminate "$DEVICE" com.nightowl.videostore
xcrun simctl launch "$DEVICE" com.nightowl.videostore
sleep 8
xcrun simctl io "$DEVICE" screenshot build/characters-in-store.png
xcrun simctl terminate "$DEVICE" com.nightowl.videostore
