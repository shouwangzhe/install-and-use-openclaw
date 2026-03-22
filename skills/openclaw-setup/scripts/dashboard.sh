#!/usr/bin/env bash
# openclaw-setup/scripts/dashboard.sh
# 启动 OpenClaw Web Dashboard
set -euo pipefail

log() { echo "[openclaw-dashboard] $*"; }
ok()  { echo "[openclaw-dashboard] ✓ $*"; }
warn() { echo "[openclaw-dashboard] ⚠ $*"; }

# 检查 Gateway 是否运行
if ! openclaw health >/dev/null 2>&1; then
  warn "Gateway is not running. Start it first:"
  warn "  bash skills/openclaw-setup/scripts/start.sh"
  exit 1
fi

ok "Gateway is running"

# 获取 Dashboard URL
DASHBOARD_URL=$(openclaw dashboard --no-open 2>&1 | grep "Dashboard URL:" | awk '{print $3}')

if [ -z "$DASHBOARD_URL" ]; then
  warn "Failed to get dashboard URL"
  exit 1
fi

echo ""
echo "══════════════════════════════════════════════════"
echo "  OpenClaw Web Dashboard"
echo "══════════════════════════════════════════════════"
echo ""
echo "  Dashboard URL:"
echo "  $DASHBOARD_URL"
echo ""
echo "  Features:"
echo "  - View gateway status and health"
echo "  - Manage sessions and conversations"
echo "  - Monitor browser profiles"
echo "  - View logs in real-time"
echo "  - Control agent settings"
echo ""
echo "  Opening in your browser..."
echo "══════════════════════════════════════════════════"
echo ""

# 在浏览器中打开
if command -v open >/dev/null 2>&1; then
  open "$DASHBOARD_URL"
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$DASHBOARD_URL"
else
  log "Please open this URL in your browser:"
  log "$DASHBOARD_URL"
fi

ok "Dashboard launched"
