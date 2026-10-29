#!/bin/bash
# Auto-install custom hotspot scripts in iSH

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  📦 Installing Hotspot Control Tools                           ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Create tools directory
mkdir -p ~/.iphone-tools
mkdir -p ~/.iphone-hotspot

# Copy hotspot menu
if [ -f "/var/containers/Bundle/Application/*/iSH.app/hotspot-menu.sh" ]; then
  cp /var/containers/Bundle/Application/*/iSH.app/hotspot-menu.sh ~/.iphone-tools/
  chmod +x ~/.iphone-tools/hotspot-menu.sh
  echo "✓ Hotspot menu installed"
elif [ -f "$(dirname "$0")/../app/iphone-hotspot/hotspot-menu.sh" ]; then
  cp "$(dirname "$0")/../app/iphone-hotspot/hotspot-menu.sh" ~/.iphone-tools/
  chmod +x ~/.iphone-tools/hotspot-menu.sh
  echo "✓ Hotspot menu installed"
else
  echo "⚠️  Hotspot menu script not found"
fi

echo ""
echo "Setting up aliases..."

# Add to profile
if ! grep -q "iphone-hotspot-menu" ~/.profile 2>/dev/null; then
  cat >> ~/.profile << 'EOF'

# ============================================================
# Custom Hotspot Control (iSH)
# ============================================================
alias iphone-hotspot-menu='bash ~/.iphone-tools/hotspot-menu.sh'
alias iphone-hotspot-setup='echo "Run: iphone-hotspot-menu then select option 1"'
alias iphone-hotspot-status='echo "Run: iphone-hotspot-menu then select option 2"'
alias iphone-hotspot-sync='bash ~/bin/iphone-daily-sync.sh 2>/dev/null || echo "Sync script not found"'
alias iphone-hotspot-vpn='bash ~/bin/vpn-start.sh 2>/dev/null || echo "VPN script not found"'
EOF

  echo "✓ Aliases created"
else
  echo "✓ Aliases already exist"
fi

echo ""
echo "Loading profile..."
source ~/.profile

echo "✓ Profile loaded"
echo ""

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✅ Installation Complete!                                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo "🚀 Available Commands:"
echo ""
echo "  iphone-hotspot-menu      ← Main control panel"
echo "  iphone-hotspot-setup     ← Configure hotspot"
echo "  iphone-hotspot-status    ← Check status"
echo "  iphone-hotspot-sync      ← Sync data"
echo "  iphone-hotspot-vpn       ← Start VPN"
echo ""

echo "📝 Quick Start:"
echo "  1. Type: iphone-hotspot-menu"
echo "  2. Select: 1 (Setup)"
echo "  3. Enter hotspot name and password"
echo "  4. Configure iPhone Settings > Personal Hotspot"
echo "  5. Return to menu and select 2 (Status)"
echo ""

echo "✨ Ready to use!"
echo ""
