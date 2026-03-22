#!/usr/bin/env bash
# openclaw-setup/scripts/start.sh
# 启动 OpenClaw Gateway + 无头浏览器后台进程
set -euo pipefail

HEADLESS_PORT=18801
HEADLESS_DATA_DIR="${HOME}/.openclaw-headless"
GATEWAY_PORT=18789
LOG_DIR="${HOME}/.openclaw/logs"

log()  { echo "[openclaw-start] $*"; }
ok()   { echo "[openclaw-start] ✓ $*"; }
warn() { echo "[openclaw-start] ⚠ $*"; }

mkdir -p "$LOG_DIR" "$HEADLESS_DATA_DIR"

# ── 1. 检测 Chromium 浏览器 ───────────────────────────────────────
detect_browser() {
  for p in \
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    "/Applications/Chromium.app/Contents/MacOS/Chromium" \
    "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" \
    "/usr/bin/google-chrome" \
    "/usr/bin/chromium-browser" \
    "/usr/bin/chromium"; do
    [ -x "$p" ] && echo "$p" && return
  done
  echo ""
}
BROWSER_PATH=$(detect_browser)

# ── 2. 启动无头浏览器（bg profile，port 18801）──────────────────
start_headless_browser() {
  if curl -s "http://127.0.0.1:${HEADLESS_PORT}/json/version" >/dev/null 2>&1; then
    ok "Headless browser already running on port ${HEADLESS_PORT}"
    return
  fi
  if [ -z "$BROWSER_PATH" ]; then
    warn "No browser found, skipping headless browser start"
    return
  fi
  log "Starting headless browser on port ${HEADLESS_PORT}..."
  "$BROWSER_PATH" \
    --headless=new \
    --remote-debugging-port="${HEADLESS_PORT}" \
    --no-sandbox \
    --disable-gpu \
    --disable-dev-shm-usage \
    --user-data-dir="${HEADLESS_DATA_DIR}" \
    >> "${LOG_DIR}/headless-browser.log" 2>&1 &
  echo $! > /tmp/openclaw-headless-browser.pid
  sleep 2
  if curl -s "http://127.0.0.1:${HEADLESS_PORT}/json/version" >/dev/null 2>&1; then
    ok "Headless browser started (pid=$(cat /tmp/openclaw-headless-browser.pid))"
  else
    warn "Headless browser may have failed to start. Check ${LOG_DIR}/headless-browser.log"
  fi
}

# ── 3. 启动 OpenClaw Gateway ──────────────────────────────────────
start_gateway() {
  if openclaw health >/dev/null 2>&1; then
    ok "Gateway already running on port ${GATEWAY_PORT}"
    return
  fi
  # 从环境变量读取 Anthropic API key (OpenClaw 识别 ANTHROPIC_API_KEY)
  local api_key="${ANTHROPIC_API_KEY:-}"
  if [ -z "$api_key" ]; then
    warn "ANTHROPIC_API_KEY not set. Agent may fail."
  fi
  log "Starting OpenClaw Gateway..."
  ANTHROPIC_API_KEY="${api_key}" \
  openclaw gateway --allow-unconfigured --force \
    >> "${LOG_DIR}/gateway.log" 2>&1 &
  sleep 3
  if openclaw health >/dev/null 2>&1; then
    ok "Gateway started on ws://127.0.0.1:${GATEWAY_PORT}"
  else
    warn "Gateway may have failed. Check ${LOG_DIR}/gateway.log"
  fi
}

# ── 4. 启动前台浏览器（openclaw profile）─────────────────────────
start_foreground_browser() {
  local status
  status=$(openclaw browser --browser-profile openclaw status 2>/dev/null | grep "running:" || echo "running: false")
  if echo "$status" | grep -q "true"; then
    ok "Foreground browser (openclaw profile) already running"
  else
    log "Starting foreground browser (openclaw profile)..."
    openclaw browser --browser-profile openclaw start 2>/dev/null \
      && ok "Foreground browser started" \
      || warn "Foreground browser start failed (may need manual start)"
  fi
}

# ── 执行 ──────────────────────────────────────────────────────────
start_headless_browser
start_gateway
start_foreground_browser

echo ""
echo "══════════════════════════════════════════════════"
echo "  OpenClaw Stack Running:"
echo "  Gateway     → ws://127.0.0.1:${GATEWAY_PORT}"
echo "  Browser fg  → openclaw browser (port 18800)"
echo "  Browser bg  → headless (port ${HEADLESS_PORT})"
echo ""
echo "  Usage:"
echo "    openclaw tui                                    # 自然语言交互"
echo "    openclaw browser --browser-profile openclaw <cmd>  # 前台浏览器"
echo "    openclaw browser --browser-profile bg <cmd>        # 无头后台"
echo ""
echo "  Environment:"
echo "    ANTHROPIC_API_KEY → CTok.ai token"
echo "    ANTHROPIC_BASE_URL → https://api.ctok.ai"
echo "══════════════════════════════════════════════════"
