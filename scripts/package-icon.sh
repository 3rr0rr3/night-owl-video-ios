#!/bin/bash
set -euo pipefail
APP="$1"
PLATFORM="$2"
python3 scripts/generate-icon.py build/Assets.xcassets
xcrun actool build/Assets.xcassets --compile "$APP" --platform "$PLATFORM" --minimum-deployment-target 16.0 --app-icon AppIcon --target-device iphone --target-device ipad --output-partial-info-plist build/icon-info.plist --compress-pngs
python3 - "$APP/Info.plist" <<'PY'
import plistlib,sys
path=sys.argv[1]
with open(path,'rb') as f: info=plistlib.load(f)
with open('build/icon-info.plist','rb') as f: info.update(plistlib.load(f))
with open(path,'wb') as f: plistlib.dump(info,f)
assert info['CFBundleIcons']['CFBundlePrimaryIcon']['CFBundleIconName']=='AppIcon'
print('App icon compiled and registered in the app bundle.')
PY
