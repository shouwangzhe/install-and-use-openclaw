# OpenClaw Setup

一键在新机器上安装并启动 OpenClaw（龙虾）完整栈，包含双浏览器 profile 配置。

## 包含内容

```
skills/openclaw-setup/
├── SKILL.md          # Agent skill 指令（自动加载到 OpenClaw agent）
├── README.md         # 本文件
└── scripts/
    ├── install.sh    # 一键安装脚本
    ├── start.sh      # 启动脚本（gateway + 双浏览器）
    └── stop.sh       # 停止脚本
```

## 快速上手（新机器）

```bash
# 第一步：设置环境变量（必需）
export ANTHROPIC_API_KEY="sk-..."  # 你的 CTok.ai API key

# 第二步：安装
bash skills/openclaw-setup/scripts/install.sh

# 第三步：登录 clawhub（可选，提高 rate limit）
clawhub auth login

# 第四步：启动
bash skills/openclaw-setup/scripts/start.sh
```

完成后输出：

```
══════════════════════════════════════════════════
  Stack running:
  Gateway     → ws://127.0.0.1:18789
  Browser fg  → openclaw browser (port 18800)
  Browser bg  → headless (port 18801)
══════════════════════════════════════════════════
```

## 环境变量配置

在运行 `start.sh` 前，需要设置环境变量。有两种方式：

### 方式 1：临时设置（当前 shell 会话）

```bash
export ANTHROPIC_API_KEY="sk-..."
bash skills/openclaw-setup/scripts/start.sh
```

### 方式 2：永久设置（推荐）

编辑 `~/.zshrc` 或 `~/.bashrc`：

```bash
# 添加这一行
export ANTHROPIC_API_KEY="sk-..."

# 保存后重新加载
source ~/.zshrc
```

### 环境变量说明

| 变量 | 必需 | 说明 |
|------|------|------|
| `ANTHROPIC_API_KEY` | 是 | CTok.ai API key（格式：`sk-...`） |
| `ANTHROPIC_BASE_URL` | 否 | API 端点，通过 openclaw.json 配置，默认 `https://api.ctok.ai` |

**注意：** OpenClaw 只识别 `ANTHROPIC_API_KEY`，不识别 `ANTHROPIC_AUTH_TOKEN` 或 `CTOK_API_KEY`。

### 获取 CTok.ai API Key

1. 访问 https://imds.ai/subscriptions
2. 登录你的账户
3. 在订阅页面找到 API key
4. 复制并设置为环境变量

## 双浏览器 Profile

| Profile | 端口 | 是否可见 | 适用场景 |
|---------|------|---------|---------|
| `openclaw` | 18800 | 有界面 | 需要你看到操作过程的任务 |
| `bg` | 18801 | 无头静默 | 后台数据采集、定时任务 |

```bash
# 前台操作（你能看到浏览器）
openclaw browser --browser-profile openclaw open https://example.com

# 后台静默操作
openclaw browser --browser-profile bg open https://example.com
```

## 自然语言交互（TUI）

栈启动后，使用交互式终端界面（Terminal User Interface）进行自然语言交互：

```bash
openclaw tui
```

这是一个在 shell 中运行的交互式命令行界面，可以直接输入自然语言与 Claude 对话，不是网页界面。

## Web 管理界面（Dashboard）

OpenClaw 内置了 Web 管理界面，类似于 Hapi 管理 Claude Code CLI：

```bash
# 方式 1：直接启动
openclaw dashboard

# 方式 2：使用脚本
bash skills/openclaw-setup/scripts/dashboard.sh
```

**Dashboard 功能：**
- 📊 Gateway 状态监控
- 💬 会话和对话管理
- 🌐 浏览器 profiles 监控
- 📝 实时日志查看
- ⚙️ Agent 设置控制
- 🔧 Skills 管理

Dashboard 会自动在浏览器中打开，访问地址：`http://127.0.0.1:18789/#token=<your-token>`

## install.sh 做了什么

1. 检查 Node.js 环境
2. 全局安装 `openclaw`（npm）
3. 全局安装 `clawhub`（npm）
4. 写入 `~/.openclaw/openclaw.json` 初始配置（包含 CTok.ai baseUrl）
5. 配置双 browser profile（openclaw + bg）
6. 安装 `agent-browser-clawdbot` skill（来自 clawhub）

### openclaw.json 配置说明

install.sh 会自动创建 `~/.openclaw/openclaw.json`，包含以下关键配置：

```json
{
  "models": {
    "providers": {
      "anthropic": {
        "baseUrl": "https://api.ctok.ai"
      }
    }
  },
  "agents": {
    "defaults": {
      "model": "anthropic/claude-sonnet-4-6"
    }
  }
}
```

重要：OpenClaw 会使用 `openclaw.json` 中的 `baseUrl` 覆盖 `ANTHROPIC_BASE_URL` 环境变量。必须在 `openclaw.json` 中配置 `models.providers.anthropic.baseUrl`。

## start.sh 做了什么

1. 检测系统 Chrome / Chromium / Brave
2. 启动无头浏览器（port 18801，后台进程）
3. 启动 OpenClaw Gateway（port 18789，后台进程）
4. 启动前台浏览器 openclaw profile（port 18800）

## 依赖

- **Node.js 18+**（推荐通过 [nvm](https://github.com/nvm-sh/nvm) 安装）
- **Chrome / Chromium / Brave**（任意一个即可）
- 网络访问 npmjs.com、clawhub.com

## 停止

```bash
bash skills/openclaw-setup/scripts/stop.sh
```

## 更新 OpenClaw

```bash
npm install -g openclaw@latest clawhub@latest
# 重启
bash skills/openclaw-setup/scripts/stop.sh
bash skills/openclaw-setup/scripts/start.sh
```
