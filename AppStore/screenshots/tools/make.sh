#!/bin/zsh
# Regenerates the App Store screenshots in AppStore/screenshots/.
# Needs Xcode, Google Chrome and Python 3 with Pillow.
set -euo pipefail

TOOLS=${0:A:h}
SHOTS=${TOOLS:h}
SOURCES=${SHOTS:h:h}/GridGuide
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

APP="$WORK/ShotHarness.app"
mkdir -p "$APP/Contents/MacOS" "$WORK/out" "$WORK/pages"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>render</string>
<key>CFBundleIdentifier</key><string>local.gridguide.shotharness</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>LSUIElement</key><true/>
</dict></plist>
PLIST

# Top-level code is only allowed in a file named main.swift.
cp "$TOOLS/harness.swift" "$WORK/main.swift"
swiftc -O -target arm64-apple-macos14 -o "$APP/Contents/MacOS/render" "$WORK/main.swift" \
  "$SOURCES"/{GridModel,GridSettings,GridGuideView,SettingsView,ShortcutManager,ShortcutRecorder,GlobalHotKey}.swift
codesign -s - --force "$APP"
# Launched through LaunchServices so the settings window gets a real window server backing.
open -W -n "$APP" --args "$WORK/out"

cp "$TOOLS"/pages/* "$WORK/out"/sym-*.png "$WORK/pages/"
for name in columns dashboard article; do
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --disable-gpu --hide-scrollbars \
    --user-data-dir="$WORK/chrome" --force-device-scale-factor=2 --window-size=1440,900 \
    --screenshot="$WORK/out/bg-$name.png" "file://$WORK/pages/$name.html" 2>/dev/null
done

python3 "$TOOLS/compose.py" "$WORK" "$SHOTS"
