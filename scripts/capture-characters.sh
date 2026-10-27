#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/characters/Payload/NightOwl.app
python3 scripts/character-capture.py
SDK="$(xcrun --sdk iphonesimulator --show-sdk-path)"
APP=build/characters/Payload/NightOwl.app
CAPTURE_SOURCES=()
for SOURCE in NightOwl/*.swift; do
  if [ "$SOURCE" != "NightOwl/NightOwl.swift" ]; then CAPTURE_SOURCES+=("$SOURCE"); fi
done
xcrun swiftc "${CAPTURE_SOURCES[@]}" build/CharacterCapture.swift -o "$APP/NightOwl" -sdk "$SDK" -target "$(uname -m)-apple-ios16.0-simulator" -swift-version 5 -framework SwiftUI -framework UIKit -framework AVFoundation
cp NightOwl/Info.plist "$APP/Info.plist"
DEVICE=$(xcrun simctl list devices available -j | python3 -c 'import sys,json; d=json.load(sys.stdin); print(next(x["udid"] for a in d["devices"].values() for x in a if x["name"].startswith("iPhone")))')
xcrun simctl boot "$DEVICE"
xcrun simctl bootstatus "$DEVICE" -b
python3 -c 'import subprocess,sys; subprocess.run(["xcrun","simctl","install",sys.argv[1],sys.argv[2]],check=True,timeout=180)' "$DEVICE" "$APP"
for MODE in portrait menu world library notebook equipment covers neighborhood chores slots tutorial options styles summary story newcharacters; do
  echo "Capturing $MODE"
  xcrun simctl launch "$DEVICE" com.nightowl.videostore "--$MODE"
  sleep 5
  xcrun simctl io "$DEVICE" screenshot "build/$MODE.png"
  xcrun simctl terminate "$DEVICE" com.nightowl.videostore
done
xcrun simctl launch "$DEVICE" com.nightowl.videostore --motion
xcrun simctl io "$DEVICE" recordVideo --codec=h264 build/store-animation.mp4 &
VIDEO_PID=$!
sleep 4.4
xcrun simctl io "$DEVICE" screenshot build/barcode-scan.png
sleep 2.3
xcrun simctl io "$DEVICE" screenshot build/cash-register.png
sleep 2.7
xcrun simctl io "$DEVICE" screenshot build/rental-receipt.png
sleep 2.6
kill -INT "$VIDEO_PID" || true
wait "$VIDEO_PID" || true
xcrun simctl io "$DEVICE" screenshot build/characters-in-store.png
xcrun simctl terminate "$DEVICE" com.nightowl.videostore
test -s build/store-animation.mp4
