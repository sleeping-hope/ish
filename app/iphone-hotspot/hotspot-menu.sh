#!/bin/bash
# Interactive iPhone Hotspot Control Menu (Custom iSH Build)

show_menu() {
  clear
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║  📱 iPhone Hotspot Control (Custom iSH)                        ║"
  echo "║     Nblock Network Management System                           ║"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""
  echo "1. 🔧 Setup Hotspot"
  echo "2. 📊 Check Status"
  echo "3. 🔗 Connect to Hotspot"
  echo "4. 📤 Sync Data to Server"
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
    7)
      echo ""
      echo "Goodbye! 👋"
      exit 0
      ;;
    *)
      echo "❌ Invalid choice"
      sleep 1
      show_menu
      ;;
  esac

  echo ""
  read -p "Press ENTER to continue..."
  show_menu
}

setup_hotspot() {
  clear
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║  🔧 Setup iPhone Hotspot                                       ║"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""

  read -p "📱 Enter Hotspot Name: " NAME
  read -sp "🔐 Enter Password (8+ chars): " PASS
  echo ""
  echo ""

  if [ -z "$NAME" ] || [ -z "$PASS" ]; then
    echo "❌ Both name and password required"
    return
  fi

  mkdir -p ~/.iphone-hotspot
  cat > ~/.iphone-hotspot/config.sh << EOF
export IPHONE_HOTSPOT_NAME="$NAME"
export IPHONE_HOTSPOT_PASS="$PASS"
export IPHONE_HOTSPOT_CONFIGURED="true"
EOF

  chmod 600 ~/.iphone-hotspot/config.sh

  echo "✅ Configuration Saved!"
  echo ""
  echo "📝 Next Steps:"
  echo "   1. Go to iPhone Settings"
  echo "   2. Personal Hotspot"
  echo "   3. Set Name: $NAME"
  echo "   4. Set Password: $PASS"
  echo "   5. Toggle ON"
}

check_status() {
  clear
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║  📊 Hotspot Status                                             ║"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""

  if [ -f ~/.iphone-hotspot/config.sh ]; then
    source ~/.iphone-hotspot/config.sh
    echo "✓ Hotspot Name: $IPHONE_HOTSPOT_NAME"
    echo "✓ Configured: YES"
    echo ""
  else
    echo "❌ Not configured yet"
    echo "   Run option 1 to setup"
    return
  fi

  echo "Testing internet..."
  if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
    MYIP=$(curl -s https://httpbin.org/ip 2>/dev/null | grep -o '"origin":"[^"]*"' | cut -d'"' -f4 || echo "unknown")
    echo "✓ Internet: OK"
    echo "✓ Current IP: $MYIP"
  else
    echo "⚠️  Internet: Not connected"
    echo "   Enable hotspot on iPhone"
  fi

  echo ""
  echo "System Info:"
  echo "  Device: $(uname -m)"
  echo "  Memory: $(free -h 2>/dev/null | awk 'NR==2 {print $2}' || echo 'N/A')"
  echo "  Uptime: $(uptime -p 2>/dev/null || echo 'N/A')"
}

connect_hotspot() {
  clear
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║  🔗 Connect to iPhone Hotspot                                  ║"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""

  if [ ! -f ~/.iphone-hotspot/config.sh ]; then
    echo "❌ Not configured yet. Run option 1 first."
    return
  fi

  source ~/.iphone-hotspot/config.sh

  echo "Attempting to connect to: $IPHONE_HOTSPOT_NAME"
  echo ""
  echo "⚠️  Manual Steps:"
  echo "   1. Go to iPhone Settings > Personal Hotspot"
  echo "   2. Toggle ON"
  echo "   3. Check 'Allow Others to Join' is ON"
  echo ""
  echo "✓ iSH is ready for connection"
  echo "  (iPhone controls the hotspot)"
}

sync_data() {
  clear
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║  📤 Sync Data to Server                                        ║"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""

  if [ ! -f ~/.iphone-hotspot/config.sh ]; then
    echo "❌ Not configured yet"
    return
  fi

  echo "Preparing data sync..."
  echo ""

  if [ -f ~/bin/iphone-daily-sync.sh ]; then
    echo "✓ Running sync script..."
    bash ~/bin/iphone-daily-sync.sh
  else
    echo "⚠️  Sync script not found"
    echo "   Create: ~/bin/iphone-daily-sync.sh"
    echo ""
    echo "Quick sync to CoD:"
    echo "   scp -r ~/data developer@cod.nblock.com:/data/"
  fi
}

start_vpn() {
  clear
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║  🌐 Start VPN Connection                                       ║"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""

  if [ ! -f ~/.iphone-hotspot/config.sh ]; then
    echo "❌ Not configured yet"
    return
  fi

  source ~/.iphone-hotspot/config.sh

  echo "Starting VPN..."
  echo ""

  if [ -f ~/bin/vpn-start.sh ]; then
    echo "✓ Launching VPN tunnel..."
    bash ~/bin/vpn-start.sh
  else
    echo "⚠️  VPN script not found"
    echo "   Create: ~/bin/vpn-start.sh"
    echo ""
    echo "Manual VPN (SSH tunnel):"
    echo "   ssh -D 1080 developer@cod.nblock.com"
  fi
}

# Main loop
while true; do
  show_menu
done
