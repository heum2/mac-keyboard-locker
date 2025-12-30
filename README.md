# ⌨️ KeyboardLocker

A macOS menu bar app that blocks keyboard input while cleaning your MacBook keyboard.

![macOS](https://img.shields.io/badge/macOS-12.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.0+-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

- 🔒 Blocks all keyboard input (mouse/trackpad still works)
- ⌨️ Quick lock with `⌘L` shortcut
- 🖱️ Unlock only via mouse click (prevents accidental unlock while cleaning)
- 📍 Menu bar icon shows lock status

## 📦 Installation

### Requirements
- macOS 12.0 or later
- Xcode Command Line Tools (`xcode-select --install`)

### Build

```bash
git clone https://github.com/heum2/mac-keyboard-locker.git
cd mac-keyboard-locker

swiftc -o KeyboardLocker -framework Cocoa -framework Carbon KeyboardLocker.swift
```

### Create .app Bundle (Run without Terminal)

```bash
# Create app bundle structure
mkdir -p KeyboardLocker.app/Contents/MacOS
cp KeyboardLocker KeyboardLocker.app/Contents/MacOS/

# Create Info.plist
cat > KeyboardLocker.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>KeyboardLocker</string>
    <key>CFBundleIdentifier</key>
    <string>com.local.keyboardlocker</string>
    <key>CFBundleName</key>
    <string>KeyboardLocker</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

# Ad-hoc signing
codesign --force --deep --sign - KeyboardLocker.app

# Run
open KeyboardLocker.app
```

> 💡 Copy the app to `/Applications` to make it searchable via Spotlight.

### Permissions

**Accessibility permission** is required before running the app:

1. System Settings → Privacy & Security → Accessibility
2. Enable KeyboardLocker (or Terminal)

## 🚀 Usage

| Action | Method |
|--------|--------|
| Lock | `⌘L` or click menu bar icon |
| Unlock | Click 🔒 in menu bar → "Unlock Keyboard" |
| Quit | Menu bar → "Quit" |

## ⚠️ Notes

- F1, F2, F7-F12 (brightness/media/volume) keys are handled at the macOS system level and cannot be blocked
- On notched MacBooks, the menu bar icon may be hidden if too many icons are present

## 📄 License

MIT License
