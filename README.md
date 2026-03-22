# Install and Use OpenClaw

一键在新机器上安装并启动 OpenClaw（龙虾）完整栈，包含双浏览器 profile 配置和 CTok.ai API 集成。

## 项目简介

OpenClaw 是一个强大的 AI 代理工具，支持：
- 🤖 自然语言交互（TUI）
- 🌐 浏览器自动化（前台 + 无头后台）
- 🔧 技能系统（Skills）
- 🚀 WebSocket Gateway

本项目提供了完整的安装、配置和使用脚本，让你可以快速在新机器上部署 OpenClaw。

## 快速开始

### 1. 设置环境变量

```bash
# 添加到 ~/.zshrc 或 ~/.bashrc
export ANTHROPIC_API_KEY="sk-..."  # 你的 CTok.ai API key
```

### 2. 安装

```bash
bash skills/openclaw-setup/scripts/install.sh
```

### 3. 登录 ClawHub（可选，提高 rate limit）

```bash
clawhub auth login
```

### 4. 启动

```bash
bash skills/openclaw-setup/scripts/start.sh
```

## 功能特性

### 双浏览器 Profile

| Profile | 端口 | 模式 | 适用场景 |
|---------|------|------|---------|
| `openclaw` | 18800 | 有头（前台可见） | 需要看到操作过程的任务 |
| `bg` | 18801 | 无头（静默后台） | 后台数据采集、定时任务 |

```bash
# 前台操作（你能看到浏览器）
openclaw browser --browser-profile openclaw open https://example.com

# 后台静默操作
openclaw browser --browser-profile bg open https://example.com
```

### 自然语言交互（TUI）

```bash
openclaw tui
```

启动一个交互式的终端界面（Terminal User Interface），可以直接在 shell 中用自然语言与 Claude 对话，所有请求通过 CTok.ai API 处理。这是一个命令行交互界面，不是网页。

### Web 管理界面（Dashboard）

```bash
# 启动 Web Dashboard
openclaw dashboard

# 或使用脚本
bash skills/openclaw-setup/scripts/dashboard.sh
```

OpenClaw 内置了一个 Web 管理界面，类似于 Hapi 管理 Claude Code CLI。功能包括：
- 📊 查看 Gateway 状态和健康信息
- 💬 管理会话和对话历史
- 🌐 监控浏览器 profiles 状态
- 📝 实时查看日志
- ⚙️ 控制 Agent 设置
- 🔧 管理技能（Skills）

Dashboard 会在浏览器中打开，URL 格式：`http://127.0.0.1:18789/#token=<your-token>`

### 浏览器自动化

```bash
# 导航
openclaw browser --browser-profile bg open https://example.com

# 获取页面快照（AI 可解析的可访问性树）
openclaw browser --browser-profile bg snapshot

# 交互（使用 snapshot 输出中的 ref）
openclaw browser --browser-profile bg click <ref>
openclaw browser --browser-profile bg type <ref> "text"

# 截图
openclaw browser --browser-profile bg screenshot
```

## 环境变量配置

### 必需的环境变量

- `ANTHROPIC_API_KEY`: CTok.ai API key（OpenClaw 只识别这个名称）

### 可选的环境变量

- `ANTHROPIC_BASE_URL`: API endpoint（默认会被 `openclaw.json` 覆盖）

### 配置方式

**临时设置（当前 shell）：**
```bash
export ANTHROPIC_API_KEY="sk-..."
```

**永久设置（推荐）：**
```bash
# 添加到 ~/.zshrc 或 ~/.bashrc
echo 'export ANTHROPIC_API_KEY="sk-..."' >> ~/.zshrc
source ~/.zshrc
```

## 配置文件

### openclaw.json

位置：`~/.openclaw/openclaw.json`

关键配置：
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

**重要提示**：OpenClaw 会覆盖 `ANTHROPIC_BASE_URL` 环境变量，实际使用 `openclaw.json` 中的 `baseUrl`。

## 常用命令

```bash
# 检查状态
openclaw health

# 启动 TUI（终端交互）
openclaw tui

# 启动 Web Dashboard（浏览器管理界面）
openclaw dashboard

# 查看浏览器状态
openclaw browser --browser-profile openclaw status
openclaw browser --browser-profile bg status

# 查看打开的标签页
openclaw browser --browser-profile openclaw tabs
openclaw browser --browser-profile bg tabs

# 查看日志
openclaw logs --follow

# 停止所有服务
bash skills/openclaw-setup/scripts/stop.sh

# 重启
pkill -f "openclaw gateway"
bash skills/openclaw-setup/scripts/start.sh
```

## 项目结构

```
clawbot/
├── README.md                    # 本文件
├── skills/
│   └── openclaw-setup/
│       ├── SKILL.md            # Agent skill 指令
│       ├── README.md           # 详细文档
│       └── scripts/
│           ├── install.sh      # 一键安装脚本
│           ├── start.sh        # 启动脚本
│           ├── stop.sh         # 停止脚本
│           └── dashboard.sh    # Web 管理界面启动脚本
```

## 依赖要求

- **Node.js 18+**（推荐通过 [nvm](https://github.com/nvm-sh/nvm) 安装）
- **Chrome / Chromium / Brave**（任意一个即可）
- 网络访问 npmjs.com、clawhub.com

## 故障排除

### 问题：No API key found for provider "anthropic"

**原因**：环境变量名称错误或未设置

**解决方案**：
```bash
# 确保使用正确的变量名
export ANTHROPIC_API_KEY="sk-..."  # 不是 ANTHROPIC_AUTH_TOKEN

# 重启 gateway
pkill -f "openclaw gateway"
bash skills/openclaw-setup/scripts/start.sh
```

### 问题：HTTP 403 forbidden

**原因**：API key 无效或额度用完

**解决方案**：
1. 检查 API key 是否正确
2. 登录 [CTok.ai](https://imds.ai/subscriptions) 查看额度
3. 更换新的 API key

### 问题：Gateway 启动失败

**解决方案**：
```bash
# 查看日志
tail -50 ~/.openclaw/logs/gateway.log

# 或使用 openclaw 命令
openclaw logs --follow
```

## 更新 OpenClaw

```bash
npm install -g openclaw@latest clawhub@latest

# 重启服务
bash skills/openclaw-setup/scripts/stop.sh
bash skills/openclaw-setup/scripts/start.sh
```

## 关键发现

1. **环境变量名称**：OpenClaw 只识别 `ANTHROPIC_API_KEY`，不识别 `ANTHROPIC_AUTH_TOKEN` 或 `CTOK_API_KEY`
2. **Base URL 配置**：必须在 `openclaw.json` 中配置 `models.providers.anthropic.baseUrl`，环境变量 `ANTHROPIC_BASE_URL` 会被覆盖
3. **Session 清理**：如果 TUI 显示历史错误，运行 `rm -f ~/.openclaw/agents/main/sessions/*.jsonl` 清理

## 许可证

MIT

## 贡献

欢迎提交 Issue 和 Pull Request！

## 相关链接

- [OpenClaw 官方文档](https://docs.openclaw.ai/)
- [ClawHub](https://clawhub.com/)
- [CTok.ai](https://imds.ai/)
