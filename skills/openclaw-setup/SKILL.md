---
name: openclaw-setup
description: Install, configure, and start OpenClaw with dual browser profiles (foreground + headless). Use when setting up OpenClaw on a new machine, starting the gateway stack, or managing browser profiles. Covers install, start, stop, and browser profile switching.
metadata:
  {
    "openclaw": {
      "emoji": "🦞",
      "requires": { "bins": ["node", "npm"] },
      "install": [
        {
          "id": "node",
          "kind": "node",
          "package": "openclaw",
          "bins": ["openclaw"],
          "label": "Install OpenClaw (npm)"
        }
      ]
    }
  }
---

# OpenClaw Setup Skill

Setup and manage the full OpenClaw stack: Gateway + foreground browser + headless browser.

## When to use

- Setting up OpenClaw on a new machine → run `install.sh`
- Starting the stack after reboot → run `start.sh`
- Stopping everything cleanly → run `stop.sh`
- Switching between visible/headless browser → use `--browser-profile` flag
- Installing browser automation skill → handled by `install.sh`

## Quick Start

```bash
# 1. Set environment variables (required)
export ANTHROPIC_API_KEY="sk-..."  # Your CTok.ai API key

# 2. Install everything
bash skills/openclaw-setup/scripts/install.sh

# 3. Login to clawhub (optional, higher rate limits)
clawhub auth login

# 4. Start the stack
bash skills/openclaw-setup/scripts/start.sh
```

## Environment Variables

Before running `start.sh`, set these in your shell or `~/.zshrc`:

```bash
# Required: Your CTok.ai API key
export ANTHROPIC_API_KEY="sk-..."

# Optional: OpenClaw will use https://api.ctok.ai by default (configured in openclaw.json)
# Only override if using a different provider
export ANTHROPIC_BASE_URL="https://api.ctok.ai"
```

To make persistent, add to `~/.zshrc` or `~/.bashrc`:

```bash
echo 'export ANTHROPIC_API_KEY="sk-..."' >> ~/.zshrc
source ~/.zshrc
```

## Browser Profiles

Two profiles are configured after install:

| Profile | Port | Visible | Use for |
|---------|------|---------|---------|
| `openclaw` | 18800 | Yes | Tasks user wants to see |
| `bg` | 18801 | No (headless) | Background / silent tasks |

### Switch profile per command

```bash
# Foreground (visible Chrome window)
openclaw browser --browser-profile openclaw open https://example.com
openclaw browser --browser-profile openclaw snapshot
openclaw browser --browser-profile openclaw screenshot

# Background (headless, no window)
openclaw browser --browser-profile bg open https://example.com
openclaw browser --browser-profile bg snapshot
openclaw browser --browser-profile bg screenshot
```

## Natural Language Interaction (TUI)

Once the stack is running, use the interactive Terminal User Interface (shell-based):

```bash
openclaw tui
```

This launches an interactive command-line interface where you can:
- Chat with Claude using natural language directly in your terminal
- Describe tasks in plain English
- Control both browser profiles
- Execute complex workflows
- See real-time browser snapshots

Note: This is a terminal-based interface running in your shell, not a web page.

## Web Management Dashboard

OpenClaw includes a built-in web dashboard, similar to Hapi for Claude Code CLI:

```bash
# Launch dashboard
openclaw dashboard

# Or use the script
bash skills/openclaw-setup/scripts/dashboard.sh
```

**Dashboard Features:**
- 📊 Gateway status and health monitoring
- 💬 Session and conversation management
- 🌐 Browser profile monitoring
- 📝 Real-time log viewing
- ⚙️ Agent settings control
- 🔧 Skills management

The dashboard opens automatically in your browser at: `http://127.0.0.1:18789/#token=<your-token>`

## Key Commands

```bash
# Check stack status
openclaw health
openclaw browser --browser-profile openclaw status
openclaw browser --browser-profile bg status

# List open tabs per profile
openclaw browser --browser-profile openclaw tabs
openclaw browser --browser-profile bg tabs

# Full browser command reference
openclaw browser --help
```

## Common Browser Operations

```bash
PROFILE="bg"   # or "openclaw" for visible

# Navigate
openclaw browser --browser-profile $PROFILE open https://example.com
openclaw browser --browser-profile $PROFILE navigate https://other.com

# Snapshot (accessibility tree — preferred for AI parsing)
openclaw browser --browser-profile $PROFILE snapshot

# Interact (use refs from snapshot output)
openclaw browser --browser-profile $PROFILE click <ref>
openclaw browser --browser-profile $PROFILE type <ref> "text"
openclaw browser --browser-profile $PROFILE fill --fields '[{"ref":"e5","value":"hello"}]'

# Wait for content
openclaw browser --browser-profile $PROFILE wait --text "Done"

# Screenshot (saves to MEDIA:<path>)
openclaw browser --browser-profile $PROFILE screenshot
```

## Default Profile

When `--browser-profile` is omitted, `openclaw` (foreground) is used.
To change the default, set `browser.defaultProfile` in config:

```bash
openclaw config set browser.defaultProfile bg
```

## Stop Stack

```bash
bash skills/openclaw-setup/scripts/stop.sh
```

## Reinstall / Update

```bash
npm install -g openclaw@latest clawhub@latest
bash skills/openclaw-setup/scripts/install.sh
```
