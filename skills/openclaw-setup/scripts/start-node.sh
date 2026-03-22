#!/usr/bin/env bash
# OpenClaw Worker Node - Connect to master gateway
# Run this on B/C machines (worker nodes)

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <master-tailscale-ip>"
  echo ""
  echo "Example:"
  echo "  $0 100.120.135.35"
  exit 1
fi

MASTER_IP="$1"
MASTER_PORT="${2:-18789}"
LOG_DIR="${HOME}/.openclaw/logs"
mkdir -p "$LOG_DIR"

# Detect Chrome/Chromium/Brave
CHROME_BIN=""
if [ -f "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then
  CHROME_BIN="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
elif [ -f "/Applications/Chromium.app/Contents/MacOS/Chromium" ]; then
  CHROME_BIN="/Applications/Chromium.app/Contents/MacOS/Chromium"
elif [ -f "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" ]; then
  CHROME_BIN="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
elif command -v google-chrome >/dev/null 2>&1; then
  CHROME_BIN="google-chrome"
elif command -v chromium-browser >/dev/null 2>&1; then
  CHROME_BIN="chromium-browser"
else
  echo "❌ Chrome/Chromium/Brave not found"
  exit 1
fi

# Start headless browser
echo "🚀 Starting headless browser on port 18801..."
"$CHROME_BIN" \
  --headless=new \
  --remote-debugging-port=18801 \
  --no-sandbox \
  --disable-gpu \
  --user-data-dir="${HOME}/.openclaw-headless" \
  >> "$LOG_DIR/chrome-headless.log" 2>&1 &

sleep 2

# Connect to master gateway as a node
echo "🔗 Connecting to master gateway at $MASTER_IP:$MASTER_PORT..."
openclaw node run \
  --host "$MASTER_IP" \
  --port "$MASTER_PORT" \
  >> "$LOG_DIR/node.log" 2>&1 &

sleep 3

# Check if node connected
if pgrep -f "openclaw node run" > /dev/null; then
  echo ""
  echo "✅ Worker node connected!"
  echo ""
  echo "📍 Master gateway: ws://$MASTER_IP:$MASTER_PORT"
  echo "📝 Logs: tail -f $LOG_DIR/node.log"
  echo ""
else
  echo "❌ Failed to connect. Check logs:"
  echo "   tail -20 $LOG_DIR/node.log"
  exit 1
fi
