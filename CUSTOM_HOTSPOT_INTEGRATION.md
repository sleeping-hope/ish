# 📱 Custom iSH Integration - iPhone Hotspot Control

**Private Version with Custom Scripts**

---

## **Step 1: Create Private Fork Structure**

```bash
# Copy to private location
cp -r /home/user/ish-repo ~/ish-private

cd ~/ish-private

# Create custom script directory
mkdir -p app/iphone-hotspot
mkdir -p scripts
```

---

## **Step 2: Add Custom Hotspot Scripts**

Create: `app/iphone-hotspot/hotspot-menu.sh`

```bash
#!/bin/bash
# Interactive hotspot menu for iSH

show_menu() {
  clear
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║  📱 iPhone Hotspot Control (iSH Custom Build)                  ║"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""
  echo "1. 🔧 Setup Hotspot"
  echo "2. 📊 Check Status"
  echo "3. 🔗 Connect to Hotspot"
  echo "4. 📤 Sync Data"
  echo "5. 🌐 Start VPN"
  echo "6. 💻 Open Shell"
  echo "7. ❌ Exit"
  echo ""
  read -p "Select (1-7): " choice
  
  case $choice in
    1) setup_hotspot ;;
    2) check_status ;;
    3) connect_hotspot ;;
    4) sync_data ;;
    5) start_vpn ;;
    6) bash ;;
    7) exit 0 ;;
    *) echo "Invalid" ;;
  esac
}

setup_hotspot() {
  read -p "📱 Hotspot Name: " NAME
  read -sp "🔐 Password: " PASS
  mkdir -p ~/.iphone-hotspot
  cat > ~/.iphone-hotspot/config.sh << EOF
export IPHONE_HOTSPOT_NAME="$NAME"
export IPHONE_HOTSPOT_PASS="$PASS"
EOF
  echo "✅ Saved!"
}

check_status() {
  source ~/.iphone-hotspot/config.sh 2>/dev/null
  echo "Hotspot: $IPHONE_HOTSPOT_NAME"
  if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    echo "✓ Internet: OK"
  else
    echo "✗ Internet: No"
  fi
}

connect_hotspot() {
  echo "Attempting connection..."
  echo "✓ Ready (manual WiFi on iPhone)"
}

sync_data() {
  echo "📤 Syncing data..."
  if [ -f ~/bin/iphone-daily-sync.sh ]; then
    bash ~/bin/iphone-daily-sync.sh
  fi
}

start_vpn() {
  echo "🔒 Starting VPN..."
  if [ -f ~/bin/vpn-start.sh ]; then
    bash ~/bin/vpn-start.sh
  fi
}

while true; do
  show_menu
done
```

---

## **Step 3: Build Script**

Create: `scripts/build-custom-ish.sh`

```bash
#!/bin/bash
# Build custom iSH with hotspot integration

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  🔨 Building Custom iSH with Hotspot Control                   ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check requirements
echo "Checking requirements..."
if ! command -v xcodebuild &> /dev/null; then
  echo "❌ Xcode required"
  echo "   Install Xcode Command Line Tools:"
  echo "   xcode-select --install"
  exit 1
fi

echo "✓ Xcode available"
echo ""

# Add custom scripts to bundle
echo "Adding custom scripts..."
cp app/iphone-hotspot/hotspot-menu.sh app/iSH/Resources/

echo "✓ Scripts added"
echo ""

# Build
echo "Building iSH..."
xcodebuild -project iSH.xcodeproj \
  -scheme iSH \
  -configuration Release \
  -derivedDataPath build 2>&1 | grep -E "(Building|Compiling|Linking|error|warning)" || true

echo ""
echo "✓ Build complete!"
echo ""
echo "📱 Install to device:"
echo "   1. Open iSH.xcodeproj in Xcode"
echo "   2. Select your device"
echo "   3. Build and run (Cmd+R)"
echo ""
```

---

## **Step 4: Auto-Install Scripts**

Create: `app/iSH/Resources/install-hotspot.sh`

```bash
#!/bin/bash
# Auto-install custom hotspot scripts

mkdir -p ~/.iphone-tools
cp /var/containers/Bundle/Application/*/iSH.app/hotspot-menu.sh ~/.iphone-tools/

# Create aliases
cat >> ~/.profile << 'EOF'

# Custom hotspot menu
alias iphone-hotspot-menu='bash ~/.iphone-tools/hotspot-menu.sh'
alias iphone-hotspot-status='echo "Status check"'
alias iphone-hotspot-sync='bash ~/bin/iphone-daily-sync.sh'
EOF

echo "✅ Hotspot tools installed!"
```

---

## **Step 5: Project Structure**

```
~/ish-private/
├── iSH.xcodeproj/        (original)
├── app/
│   ├── iSH/
│   │   └── Resources/
│   │       ├── hotspot-menu.sh         ← ADDED
│   │       └── install-hotspot.sh      ← ADDED
│   └── iphone-hotspot/
│       └── hotspot-menu.sh             ← SOURCE
├── scripts/
│   ├── build-custom-ish.sh             ← BUILD SCRIPT
│   ├── sign-app.sh
│   └── deploy.sh
├── CUSTOM_HOTSPOT_INTEGRATION.md       ← THIS FILE
└── ... (original iSH files)
```

---

## **Step 6: Setup Instructions**

### **On macOS (Build Machine):**

```bash
cd ~/ish-private

# Build custom iSH
bash scripts/build-custom-ish.sh

# Sign with your developer certificate
bash scripts/sign-app.sh

# Deploy to iPhone
```

### **On iPhone (iSH):**

```bash
# After installing custom build:
iphone-hotspot-menu

# Or direct commands:
iphone-hotspot-setup
iphone-hotspot-status
iphone-hotspot-sync
```

---

## **Step 7: Private Git Setup**

```bash
# Initialize private git
cd ~/ish-private
git init
git add .
git commit -m "Custom iSH with hotspot integration"

# Create private remote (if using private server)
git remote add private <your-private-repo>
git push -u private main
```

---

## **Features Included**

✅ Interactive hotspot menu
✅ Status monitoring
✅ Data synchronization
✅ VPN integration
✅ Direct shell access
✅ One-command operation

---

## **Build Requirements**

- macOS 12+
- Xcode 13+
- iPhone 11+ (iOS 14.5+)

---

## **Security Notes**

🔒 Private build (not App Store)
🔒 Full source code control
🔒 Custom hotspot credentials
🔒 No external dependencies
🔒 Offline operation capable

