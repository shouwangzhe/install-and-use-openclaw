#!/usr/bin/env bash
# openclaw-setup/scripts/install.sh
# 一键安装 OpenClaw + 双浏览器 profile 配置
set -euo pipefail

HEADLESS_PORT=18801
HEADLESS_DATA_DIR="${HOME}/.openclaw-headless"
CONFIG_FILE="${HOME}/.openclaw/openclaw.json"

log()  { echo "[openclaw-setup] $*"; }
ok()   { echo "[openclaw-setup] ✓ $*"; }
warn() { echo "[openclaw-setup] ⚠ $*"; }
die()  { echo "[openclaw-setup] ✗ $*" >&2; exit 1; }

# ── 1. Node 检查 ──────────────────────────────────────────────────
log "Checking Node.js..."
node --version >/dev/null 2>&1 || die "Node.js not found. Install via https://nodejs.org or nvm."
ok "Node $(node --version)"

# ── 2. 安装 openclaw ──────────────────────────────────────────────
log "Installing openclaw..."
if command -v openclaw >/dev/null 2>&1; then
  ok "openclaw already installed: $(openclaw --version 2>&1 | head -1)"
else
  npm install -g openclaw --cache /tmp/npm-cache-openclaw
  ok "openclaw installed: $(openclaw --version 2>&1 | head -1)"
fi

# ── 3. 安装 clawhub ───────────────────────────────────────────────
log "Installing clawhub..."
if command -v clawhub >/dev/null 2>&1; then
  ok "clawhub already installed"
else
  npm install -g clawhub --cache /tmp/npm-cache-openclaw
  ok "clawhub installed"
fi

# ── 4. 写入配置 ───────────────────────────────────────────────────
log "Writing openclaw config..."
mkdir -p "${HOME}/.openclaw"

# 检测系统上的 Chromium 类浏览器
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
[ -z "$BROWSER_PATH" ] && warn "No Chromium-based browser found. Install Chrome/Chromium for browser features."

# 仅在 config 不存在时写入初始配置（避免覆盖已有 token 等）
if [ ! -f "$CONFIG_FILE" ]; then
  cat > "$CONFIG_FILE" <<'JSON'
{
  "agents": {
    "defaults": {
      "model": "anthropic/claude-sonnet-4-6",
      "compaction": { "mode": "safeguard" }
    }
  },
  "commands": {
    "native": "auto",
    "nativeSkills": "auto",
    "restart": true,
    "ownerDisplay": "raw"
  },
  "gateway": {
    "mode": "local",
    "bind": "loopback",
    "controlUi": {
      "dangerouslyAllowHostHeaderOriginFallback": true
    }
  },
  "models": {
    "providers": {
      "anthropic": {
        "baseUrl": "https://api.ctok.ai"
      }
    }
  }
}
JSON
  ok "Config created at $CONFIG_FILE"
else
  ok "Config already exists, skipping overwrite"
fi

# 写入 browser profiles（用 openclaw config set）
openclaw config set browser.profiles.openclaw.cdpPort 18800 2>/dev/null || true
openclaw config set browser.profiles.openclaw.color "#FF4500" 2>/dev/null || true
openclaw config set browser.profiles.bg.cdpPort "${HEADLESS_PORT}" 2>/dev/null || true
openclaw config set browser.profiles.bg.color "#444444" 2>/dev/null || true
ok "Browser profiles configured (openclaw=18800, bg=${HEADLESS_PORT})"

# ── 5. 验证环境变量配置 ──────────────────────────────────────────
log "Checking environment variables..."
API_KEY="${ANTHROPIC_API_KEY:-}"
if [ -z "$API_KEY" ]; then
  warn "ANTHROPIC_API_KEY not set in environment"
  warn "Set it before running start.sh: export ANTHROPIC_API_KEY='sk-...'"
  warn "Or add to ~/.zshrc or ~/.bashrc for persistence"
else
  ok "ANTHROPIC_API_KEY is set"
fi

# ── 6. 安装 browser skill ─────────────────────────────────────────
log "Installing agent-browser skill..."
SKILLS_DIR="${HOME}/.openclaw/skills"
mkdir -p "$SKILLS_DIR"
if [ -d "${SKILLS_DIR}/agent-browser-clawdbot" ]; then
  ok "agent-browser-clawdbot already installed"
else
  (cd "$SKILLS_DIR" && clawhub install agent-browser-clawdbot) \
    && ok "agent-browser-clawdbot installed" \
    || warn "clawhub install failed (rate limit?). Run manually: cd ~/.openclaw && clawhub install agent-browser-clawdbot"
fi

# ── 6. 生成启动脚本 ───────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
START_SCRIPT="${SCRIPT_DIR}/start.sh"

if [ ! -f "$START_SCRIPT" ]; then
  warn "start.sh not found at $START_SCRIPT. Run install from the skill directory."
fi

echo ""
echo "══════════════════════════════════════════════════"
echo "  OpenClaw setup complete!"
echo "  Next: run ./scripts/start.sh to launch the stack"
echo "  Or:   openclaw configure   (interactive wizard)"
echo "══════════════════════════════════════════════════"
