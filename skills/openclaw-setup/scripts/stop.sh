#!/usr/bin/env bash
# openclaw-setup/scripts/stop.sh
# 停止 OpenClaw Gateway + 无头浏览器
set -euo pipefail

log() { echo "[openclaw-stop] $*"; }
ok()  { echo "[openclaw-stop] ✓ $*"; }

# 停止无头浏览器
if [ -f /tmp/openclaw-headless-browser.pid ]; then
  PID=$(cat /tmp/openclaw-headless-browser.pid)
  if kill -0 "$PID" 2>/dev/null; then
    kill "$PID" && ok "Headless browser stopped (pid=$PID)"
  fi
  rm -f /tmp/openclaw-headless-browser.pid
else
  pkill -f "headless.*18801" 2>/dev/null && ok "Headless browser stopped" || true
fi

# 停止 Gateway
pkill -f "openclaw gateway" 2>/dev/null && ok "Gateway stopped" || log "Gateway was not running"

ok "Stack stopped"
