#!/usr/bin/env bash
# OpenClaw Master Node - Gateway exposed via Tailscale
# Run this on the A machine (master node)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${HOME}/.openclaw/logs"
mkdir -p "$LOG_DIR"

# Check if ANTHROPIC_API_KEY is set
if [ -z "$ANTHROPIC_API_KEY" ]; then
  echo "⚠️  Warning: ANTHROPIC_API_KEY not set"
  echo "   Set it in ~/.zshrc or ~/.bashrc:"
  echo "   export ANTHROPIC_API_KEY='sk-...'"
  exit 1
fi

# Detect Chrome/Chromium/Brave
CHROME_BIN=""
if [ -f "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then
  CHROME_BIN="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
elif [ -f "/Applications/Chromium.app/Contents/MacOS/Chromium" ]; then
  CHROME_BIN="/Applications/Chromium.app/Contents/MacOS/Chromium"
elif [ -f "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" ]; then
  CHROME_BIN="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
else
  echo "❌ Chrome/Chromium/Brave not found"
  exit 1
fi

# Start headless browser (bg profile)
echo "🚀 Starting headless browser on port 18801..."
"$CHROME_BIN" \
  --headless=new \
  --remote-debugging-port=18801 \
  --no-sandbox \
  --disable-gpu \
  --user-data-dir="${HOME}/.openclaw-headless" \
  >> "$LOG_DIR/chrome-headless.log" 2>&1 &

sleep 2

# Start OpenClaw Gateway with Tailscale binding
echo "🌐 Starting OpenClaw Gateway (Tailscale mode)..."
ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY}" \
openclaw gateway --bind tailnet --allow-unconfigured --force \
  >> "$LOG_DIR/gateway-master.log" 2>&1 &

sleep 4

# Get Tailscale IP
TAILSCALE_IP=$(tailscale ip -4)

echo ""
echo "✅ Master node started!"
echo ""
echo "📍 Tailscale IP: $TAILSCALE_IP"
echo "🔗 Gateway: ws://$TAILSCALE_IP:18789"
echo ""
