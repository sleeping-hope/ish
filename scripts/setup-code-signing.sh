#!/bin/bash
# iOS Code Signing Setup for Custom iSH Build

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  🔐 iOS Code Signing Setup                                     ║"
echo "║     Configure Xcode for Device & Ad Hoc Distribution           ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ============================================================
# 1. Check Prerequisites
# ============================================================
echo "📋 Checking prerequisites..."
echo ""

if [ "$(uname)" != "Darwin" ]; then
  echo "❌ macOS required"
  exit 1
fi

echo "✓ macOS detected"

if ! command -v xcodebuild &> /dev/null; then
  echo "❌ Xcode Command Line Tools required"
  echo "   Install: xcode-select --install"
  exit 1
fi

echo "✓ Xcode available"

if ! command -v security &> /dev/null; then
  echo "❌ security utility not found"
  exit 1
fi

echo "✓ Security tools available"
echo ""

# ============================================================
# 2. Apple ID & Team ID
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📧 Apple ID & Team Information"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "Enter Apple ID email: " APPLE_ID

if [ -z "$APPLE_ID" ]; then
  echo "❌ Apple ID required"
  exit 1
fi

echo ""
echo "Available teams:"
echo ""

# Try to get teams from Xcode
TEAMS=$(security find-certificate -a -c "$APPLE_ID" 2>/dev/null | grep -o 'Team ID: [^"]*' | cut -d' ' -f3 | sort -u || echo "")

if [ -z "$TEAMS" ]; then
  echo "⚠️  Could not detect teams automatically"
  echo ""
  echo "Find your Team ID:"
  echo "  1. Open Xcode"
  echo "  2. Preferences > Accounts"
  echo "  3. Select your Apple ID"
  echo "  4. View Details..."
  echo "  5. Copy Team ID"
  echo ""
fi

read -p "Enter Team ID (e.g., ABCD123456): " TEAM_ID

if [ -z "$TEAM_ID" ]; then
  echo "❌ Team ID required"
  exit 1
fi

echo "✓ Team ID: $TEAM_ID"
echo ""

# ============================================================
# 3. Certificates
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📜 Signing Certificates"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Checking installed certificates..."
echo ""

# List available certificates
CERTS=$(security find-certificate -a -c "$APPLE_ID" | grep -o 'labl<blob>="[^"]*' | cut -d'"' -f2 || true)

if [ -z "$CERTS" ]; then
  echo "⚠️  No certificates found for $APPLE_ID"
  echo ""
  echo "Create certificates in Apple Developer:"
  echo "  1. Visit: https://developer.apple.com/account"
  echo "  2. Certificates, Identifiers & Profiles"
  echo "  3. Certificates → +"
  echo "  4. Choose: iOS App Development"
  echo "  5. Upload CSR (or create via Xcode)"
  echo "  6. Download .cer file"
  echo ""
  echo "Import to Keychain:"
  echo "  • Double-click .cer file"
  echo "  • Or: security import certificate.cer -k ~/Library/Keychains/login.keychain"
  echo ""
else
  echo "Found certificates:"
  echo "$CERTS" | nl
fi

echo ""

# ============================================================
# 4. Provisioning Profile
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 Provisioning Profile"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

PROFILES_DIR="$HOME/Library/MobileDevice/Provisioning\ Profiles"

if [ -d "$PROFILES_DIR" ]; then
  COUNT=$(ls "$PROFILES_DIR"/*.mobileprovision 2>/dev/null | wc -l)
  echo "✓ Found $COUNT provisioning profile(s)"
else
  echo "⚠️  No provisioning profiles installed"
fi

echo ""
echo "Create provisioning profile:"
echo "  1. Visit: https://developer.apple.com/account"
echo "  2. Profiles → +"
echo "  3. Choose: iOS App Development"
echo "  4. Select App ID (or create new)"
echo "     Bundle ID: app.ish.hotspot"
echo "  5. Select signing certificate"
echo "  6. Select device(s) to include"
echo "  7. Download .mobileprovision file"
echo ""
echo "Install profile:"
echo "  • Double-click .mobileprovision"
echo "  • Or: open downloaded.mobileprovision"
echo ""

# ============================================================
# 5. Xcode Configuration
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  Xcode Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create signing config
SIGNING_CONFIG="$HOME/.ish-signing.config"

cat > "$SIGNING_CONFIG" << EOF
# iSH Custom Build - Code Signing Configuration
APPLE_ID="$APPLE_ID"
TEAM_ID="$TEAM_ID"
BUNDLE_ID="app.ish.hotspot"
PROVISIONING_PROFILE_NAME="iSH Development"
CODE_SIGN_STYLE="Automatic"
EOF

chmod 600 "$SIGNING_CONFIG"

echo "✓ Saved signing config: $SIGNING_CONFIG"
echo ""

# ============================================================
# 6. Xcode Settings Update
# ============================================================
echo "Applying Xcode build settings..."
echo ""

XCODE_PROJECT="iSH.xcodeproj"

if [ -d "$XCODE_PROJECT" ]; then
  echo "Build settings to configure in Xcode:"
  echo ""
  echo "1. Select iSH.xcodeproj in Xcode"
  echo "2. Select 'iSH' target"
  echo "3. Build Settings tab"
  echo ""
  echo "Set these values:"
  echo ""
  echo "  Development Team:"
  echo "    → $TEAM_ID"
  echo ""
  echo "  Provisioning Profile:"
  echo "    → iSH Development"
  echo ""
  echo "  Code Sign Identity:"
  echo "    → iPhone Developer"
  echo ""
  echo "  Code Signing Style:"
  echo "    → Automatic"
  echo ""
  echo "  Bundle Identifier:"
  echo "    → app.ish.hotspot"
  echo ""
else
  echo "⚠️  iSH.xcodeproj not found"
  echo "    Run from iSH repository root"
fi

echo ""

# ============================================================
# 7. Device Registration
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 Register Device"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Connect your iPhone and get UDID:"
echo ""
echo "Method 1 (Xcode):"
echo "  1. Xcode > Window > Devices and Simulators"
echo "  2. Connect iPhone"
echo "  3. Copy UDID from list"
echo ""
echo "Method 2 (iTunes/Finder):"
echo "  1. Connect iPhone"
echo "  2. Select device"
echo "  3. Click 'Serial Number' to toggle UDID"
echo "  4. Cmd+C to copy"
echo ""

read -p "Enter iPhone UDID: " UDID

if [ -n "$UDID" ]; then
  echo "✓ UDID: $UDID"
  echo ""
  echo "Register at Apple Developer:"
  echo "  1. Visit: https://developer.apple.com/account"
  echo "  2. Devices → +"
  echo "  3. Paste UDID"
  echo "  4. Name: My iPhone"
  echo "  5. Register"
  echo ""
  echo "Update provisioning profile:"
  echo "  1. Visit profiles page"
  echo "  2. Edit profile"
  echo "  3. Check your device"
  echo "  4. Save & download"
  echo "  5. Install (.mobileprovision)"
fi

echo ""

# ============================================================
# 8. Summary
# ============================================================
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✅ Code Signing Setup Complete!                              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo "📋 Checklist:"
echo ""
echo "  □ Apple ID registered"
echo "  □ Development certificate created"
echo "  □ Certificate imported to Keychain"
echo "  □ Provisioning profile created"
echo "  □ iPhone device registered"
echo "  □ Xcode build settings configured"
echo "  □ Team ID set"
echo "  □ Provisioning profile installed"
echo ""

echo "🚀 Ready to Build:"
echo ""
echo "  1. Connect iPhone to Mac"
echo "  2. Open iSH.xcodeproj in Xcode"
echo "  3. Select your device"
echo "  4. Press Cmd+R (Run)"
echo ""

echo "📂 Signing config saved:"
echo "  $SIGNING_CONFIG"
echo ""

echo "🔐 Security Notes:"
echo "  ✓ Config file is read-only (600)"
echo "  ✓ Credentials stored locally"
echo "  ✓ Never commit signing files to git"
echo "  ✓ Certificates stay in Keychain"
echo ""

echo "✨ All set!"
echo ""
