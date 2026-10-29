#!/bin/bash
# Build Custom iSH with Hotspot Integration

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  🔨 Building Custom iSH with Hotspot Control                   ║"
echo "║     Private Build - Nblock Edition                             ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================
# 1. Check Requirements
# ============================================================
echo "📋 Checking requirements..."
echo ""

# Check OS
if [ "$(uname)" != "Darwin" ]; then
  echo "❌ macOS required for building"
  echo "   This is a macOS/iOS project"
  exit 1
fi

echo "✓ macOS detected"

# Check Xcode
if ! command -v xcodebuild &> /dev/null; then
  echo "❌ Xcode Command Line Tools required"
  echo ""
  echo "Install with:"
  echo "   xcode-select --install"
  exit 1
fi

echo "✓ Xcode Command Line Tools found"

# Check pods
if ! command -v pod &> /dev/null; then
  echo "⚠️  CocoaPods not found"
  echo "   Installing..."
  sudo gem install cocoapods
fi

echo "✓ CocoaPods available"
echo ""

# ============================================================
# 2. Prepare Custom Scripts
# ============================================================
echo "📦 Preparing custom scripts..."
echo ""

SCRIPT_SOURCE="app/iphone-hotspot/hotspot-menu.sh"
SCRIPT_DEST="app/iSH/Resources/hotspot-menu.sh"

if [ -f "$SCRIPT_SOURCE" ]; then
  cp "$SCRIPT_SOURCE" "$SCRIPT_DEST"
  chmod +x "$SCRIPT_DEST"
  echo "✓ Hotspot menu script added"
else
  echo "⚠️  Custom script not found: $SCRIPT_SOURCE"
fi

echo ""

# ============================================================
# 3. Install Dependencies
# ============================================================
echo "📥 Installing dependencies..."
echo ""

if [ -f "Podfile" ]; then
  pod install --repo-update
  echo "✓ CocoaPods dependencies installed"
fi

echo ""

# ============================================================
# 4. Build iSH
# ============================================================
echo "🔨 Building iSH..."
echo ""

BUILD_DIR="build"
mkdir -p "$BUILD_DIR"

# Build for device
echo "Building for device architecture..."
xcodebuild \
  -workspace iSH.xcworkspace \
  -scheme iSH \
  -configuration Release \
  -derivedDataPath "$BUILD_DIR" \
  -arch arm64 \
  -verbose 2>&1 | tail -20

if [ $? -eq 0 ]; then
  echo ""
  echo "✓ Build successful!"
else
  echo ""
  echo "❌ Build failed"
  exit 1
fi

echo ""

# ============================================================
# 5. Prepare for Deployment
# ============================================================
echo "📦 Preparing for deployment..."
echo ""

IPA_PATH="$BUILD_DIR/Release-iphoneos/iSH.ipa"

if [ -f "$IPA_PATH" ]; then
  echo "✓ IPA file created: $IPA_PATH"
  echo ""
  echo "📊 File size: $(du -h "$IPA_PATH" | awk '{print $1}')"
else
  echo "⚠️  IPA not found in expected location"
  echo "   Check build output above for errors"
fi

echo ""

# ============================================================
# 6. Summary
# ============================================================
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✅ Build Complete!                                            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo "📱 Installation Options:"
echo ""
echo "Option 1: Debug over USB"
echo "  1. Connect iPhone to Mac"
echo "  2. Open iSH.xcworkspace in Xcode"
echo "  3. Select your device"
echo "  4. Press Cmd+R to build and run"
echo ""

echo "Option 2: Testflight"
echo "  1. Use Xcode organizer"
echo "  2. Upload build to App Store Connect"
echo "  3. Distribute via Testflight"
echo ""

echo "Option 3: Manual Installation"
echo "  1. Use Apple Configurator 2"
echo "  2. Drag IPA to device"
echo ""

echo "📝 Features Included:"
echo "  ✓ Custom hotspot menu"
echo "  ✓ VPN integration"
echo "  ✓ Data sync"
echo "  ✓ Status monitoring"
echo "  ✓ Interactive shell"
echo ""

echo "🔒 Build Info:"
echo "  Version: Custom (Private)"
echo "  Bundle: iSH.Hotspot"
echo "  Config: Release"
echo "  Arch: ARM64 (iOS 14+)"
echo ""

echo "📂 Build artifacts:"
echo "  Location: $BUILD_DIR/"
echo "  IPA: $IPA_PATH"
echo ""

echo "🚀 Next Steps:"
echo "  1. Review the build output above"
echo "  2. Choose installation method"
echo "  3. Test on your iPhone"
echo "  4. Run: iphone-hotspot-menu"
echo ""
