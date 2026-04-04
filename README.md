# ClawICU

### OpenClaw Emergency Rescue System

<p align="center">

![Version](https://img.shields.io/badge/version-0.3.0-2564eb?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-22c55e?style=for-the-badge)
![OpenClaw](https://img.shields.io/badge/OpenClaw-v2026.4-8b5cf6?style=for-the-badge)
![Issues](https://img.shields.io/badge/Issues-24-ef4444?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS-64748b?style=for-the-badge)

</p>

<p align="center">

**[Website](https://xagent.icu)** ·
**[Docs](https://xagent.icu/docs)** ·
**[Rescue Script](https://xagent.icu/rescue.sh)** ·
**[GitHub](https://github.com/SonicBotMan/clawicu)**

</p>

---

<p align="center">

```
██╗    ██╗ █████╗ ███████╗███████╗██╗     ██╗███╗   ██╗███████╗
██║    ██║██╔══██╗██╔════╝██╔════╝██║     ██║████╗  ██║██╔════╝
██║ █╗ ██║███████║███████╗███████╗██║     ██║██╔██╗ ██║█████╗
██║███╗██║██╔══██║╚════██║╚════██║██║     ██║██║╚██╗██║██╔══╝
╚███╔███╔╝██║  ██║███████║███████║███████╗██║██║ ╚████║███████╗
 ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝╚═╝  ╚═══╝╚══════╝
```

**When OpenClaw breaks, ClawICU rushes in.**

</p>

---

## The Pain

You've been running [OpenClaw](https://github.com/openclaw/openclaw) for weeks. It's become the backbone of your AI workflow — routing requests, managing plugins, executing commands through your custom tools.

Then it happens.

```
[Channel] WhatsApp auth token expired
[Gateway] Connection refused on port 18789
[Exec] Permission denied: tool execution requires approval
[Pairing] Device not approved — waiting for authorization
```

You dig through Discord threads. You grep through config files. You try `openclaw doctor` but it tells you nothing actionable. You reinstall. It breaks again in a different way.

**Sound familiar?**

OpenClaw is powerful — but its failure modes are opaque, its diagnostic tools are scattered, and when something breaks, you're on your own.

---

## What Is ClawICU

ClawICU is a **structured rescue system for OpenClaw** — a 6-phase protocol that diagnoses what's broken, explains why it's broken, and fixes it.

Not a forum post. Not a Discord thread. Not a config file you edit blind.

A systematic emergency room.

| | |
|---|---|
| **One command** | `curl -fsSL https://xagent.icu/rescue.sh \| sh` |
| **Or download** | `curl -fsSL https://xagent.icu/rescue.sh -o rescue.sh && chmod +x rescue.sh` |
| **Live site** | [xagent.icu](https://xagent.icu) — medical-themed docs |
| **Issue guides** | [xagent.icu/docs](https://xagent.icu/docs) — 24 diagnosed failure modes |

---

## User Stories

> "My cron jobs stopped firing for 3 days before I noticed. Turned out the cron store was in a bad state after an unclean shutdown. ClawICU caught it in Phase 2 and auto-repaired it."
> — DevOps lead running 6 OpenClaw instances

> "I spent 6 hours trying to figure out why the browser tool wasn't working. Turns out it wasn't in `tools.allow` after a config migration. One command in the Tool Unlock Panel and it worked."
> — Independent developer, automation enthusiast

> "After a server restart, OpenClaw wouldn't start. Gateway crash. I had no idea if it was a port conflict, corrupted config, or something else. ClawICU's Phase 2 diagnostics found a stale PID file and a port conflict in under 30 seconds."
> — Systems engineer, Linux enthusiast

---

## Why ClawICU Exists

OpenClaw is a sophisticated system — local AI gateway with plugin architecture, multi-channel integration (WhatsApp, Slack, Discord), exec tools, elevated privileges, sandbox isolation. It's the kind of software that **does serious work**.

But sophisticated software fails in sophisticated ways:

| Failure Mode | Why It's Hard |
|---|---|
| Config corruption after unclean shutdown | No validation on restart — silent failures |
| Channel auth token expiry | Tokens stored in nested JSON — hard to locate |
| Plugin dependency conflicts | No automated dependency resolution |
| Exec tool approval loops | Permission model is multi-layered and opaque |
| Gateway connection refused | 6 possible causes — no structured triage |
| Pairing not approved | No clear state machine visualization |

The **community had no standard rescue procedure**. People were reinstalling from scratch, losing sessions and configuration. Or spending hours on Discord/Issues piecing together solutions from fragmented threads.

ClawICU exists to give OpenClaw users a **systematic recovery path** — not another forum post, but an automated diagnostic and repair tool built from real-world failure cases.

---

## How It Works

### 6-Phase Rescue Protocol

```
┌─────────────────────────────────────────────────────────────────┐
│  Phase 1 · Doctor Check                                          │
│  openclaw doctor + openclaw doctor --fix (auto-applied)          │
├─────────────────────────────────────────────────────────────────┤
│  Phase 2 · Diagnostics                                            │
│  Binary · Process · Config · Disk · Network · State            │
├─────────────────────────────────────────────────────────────────┤
│  Phase 3 · Triage                                                 │
│  Critical ████ or Warning ████ or Stable ████                  │
├─────────────────────────────────────────────────────────────────┤
│  Phase 4 · Treatment Plan                                         │
│  [a] Auto · [1] Quick · [2] Full · [3] Nuclear                 │
├─────────────────────────────────────────────────────────────────┤
│  Phase 5 · Tool Unlock Panel                                      │
│  Interactive config editor for exec, browser, elevated, sandbox   │
├─────────────────────────────────────────────────────────────────┤
│  Phase 6 · Report                                                │
│  Summary + restart instructions + change log                       │
└─────────────────────────────────────────────────────────────────┘
```

### Phase 5: Tool Unlock Panel

The panel you wish OpenClaw had built-in — an interactive security configuration editor that modifies `openclaw.json` through the official `openclaw config` commands. No blind file editing.

```
  [1]  Show current tool config status
  [2]  Exec Free Mode  (security=full, ask=off) — DANGEROUS
  [3]  Enable Browser Tool
  [4]  Disable Elevated restrictions
  [5]  Open Sandbox restrictions — DANGEROUS
  [6]  Restore Safe Defaults
  [0]  Done / Skip
```

| Option | Config Key | Effect |
|--------|-----------|--------|
| **Exec Free Mode** | `tools.exec.security=full`<br>`tools.exec.ask=off` | Removes all exec restrictions and approval prompts |
| **Enable Browser** | `tools.allow += "browser"` | Allows browser tool to run |
| **Disable Elevated** | `tools.elevated.enabled=false` | Disables elevated exec mode |
| **Open Sandbox** | `tools.sandbox.tools.allow=[*]` | Allows all sandbox tools |
| **Safe Defaults** | various | Resets all to secure defaults |

> **Security note:** Dangerous options (2, 5) require typing `yes` to confirm.

---

## What `openclaw doctor --fix` Auto-Handles

Phase 1 runs `openclaw doctor --fix` automatically — it resolves real issues OpenClaw has documented:

| Category | Fixes |
|----------|-------|
| **Legacy Migration** | Sessions, agent, WhatsApp auth state |
| **Config Paths** | xAI / Firecrawl config migration |
| **Channel Config** | Compatibility fixes across platforms |
| **Plugins** | Auto-enable + dependency resolution |
| **Gateway** | Auth token generation |
| **Shell** | Bash / Zsh / Fish completion setup |
| **System** | systemd linger, cron store repair |

---

## 24 Diagnosed Failure Modes

Not all issues are equal. We categorize them by severity:

| Severity | Issues |
|----------|---|
| 🔴 **Fatal** | Config corruption · Gateway crash · Disk full |
| 🟠 **Warning** | Pairing not approved · Channel auth failed · Cron not executing |
| 🟡 **Info** | Browser tool not working · Exec requires approval · Heartbeat not sent |

See the full [issue encyclopedia →](https://xagent.icu/docs)

---

## Architecture

```
clawicu/
│
├── rescue.sh                    # Standalone POSIX shell script
│                                 # No dependencies — curl + sh only
│
└── src/
    ├── app/
    │   ├── page.tsx             # Landing page
    │   └── docs/
    │       ├── page.tsx         # 24-issue grid
    │       └── [slug]/          # Issue detail pages
    │
    └── components/
        ├── Hero.tsx             # ICU Specialist banner
        ├── PatientSymptoms.tsx    # Issue grid with severity badges
        ├── TreatmentPlan.tsx      # 6-phase accordion
        ├── ExaminationProcess.tsx # 4-step flow
        └── QuickStartGuides.tsx  # Links to OpenClaw docs
```

---

## Development

```bash
git clone https://github.com/SonicBotMan/clawicu.git
cd clawicu
npm install
npm run dev      # → localhost:3000
npm run build    # Static export → /out
```

---

## Contributing

Found an unlisted issue? **[Open an issue](https://github.com/SonicBotMan/clawicu/issues)** — contributions welcome.

---

<p align="center">

MIT License · [github.com/SonicBotMan/clawicu](https://github.com/SonicBotMan/clawicu)

**ClawICU — OpenClaw's emergency room.**

</p>

---

# 中文版

<p align="center">

```
██╗    ██╗ █████╗ ███████╗███████╗██╗     ██╗███╗   ██╗███████╗
██║    ██║██╔══██╗██╔════╝██╔════╝██║     ██║████╗  ██║██╔════╝
██║ █╗ ██║███████║███████╗███████╗██║     ██║██╔██╗ ██║█████╗
██║███╗██║██╔══██║╚════██║╚════██║██║     ██║██║╚██╗██║██╔══╝
╚███╔███╔╝██║  ██║███████║███████║███████╗██║██║ ╚████║███████╗
 ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝╚═╝  ╚═══╝╚══════╝
```

**当 OpenClaw 遇到问题时，ClawICU 紧急救援。**

</p>

---

## 痛点

你运行 [OpenClaw](https://github.com/openclaw/openclaw) 已经好几周了。它已经成为你 AI 工作流的核心——路由请求、管理插件、通过自定义工具执行命令。

然后，问题来了。

```
[Channel] WhatsApp auth token expired
[Gateway] Connection refused on port 18789
[Exec] Permission denied: tool execution requires approval
[Pairing] Device not approved — waiting for authorization
```

你翻遍 Discord 帖子、grep 配置文件、尝试 `openclaw doctor` 但它给不出任何可操作的信息。你重装了。下次又是另一种方式坏掉。

**似曾相识？**

OpenClaw 很强大——但它的失败模式不透明、诊断工具分散、出问题时你只能靠自己。

---

## ClawICU 是什么

ClawICU 是 **OpenClaw 的结构化救援系统** — 6 阶段协议，诊断问题所在、解释为什么坏掉、修复它。

不是论坛帖子。不是 Discord 讨论帖。不是你盲目编辑的配置文件。

而是一个系统化的急诊室。

| | |
|---|---|
| **一键启动** | `curl -fsSL https://xagent.icu/rescue.sh \| sh` |
| **文档站点** | [xagent.icu/docs](https://xagent.icu/docs) — 24 个故障排查指南 |
| **在线访问** | [xagent.icu](https://xagent.icu) |

---

## 用户故事

> "我的 cron 任务停了 3 天才发现。原因是服务器异常断电后 cron store 进入了坏状态。ClawICU 在第二阶段检测到并自动修复了。"
> — 运行着 6 个 OpenClaw 实例的 DevOps 负责人

> "我花了 6 个小时排查为什么浏览器工具不工作。后来发现是配置迁移后 `tools.allow` 里没有 browser。工具解锁面板里一个命令就好了。"
> — 独立开发者，自动化爱好者

> "服务器重启后 OpenClaw 起不来了。Gateway 崩溃。我不知道是端口冲突、配置损坏还是其他原因。ClawICU 第二阶段诊断在 30 秒内发现了卡死的 PID 文件和端口冲突。"
> — 系统工程师，Linux 爱好者

---

## 为什么需要 ClawICU

OpenClaw 是一个精密的系统——本地 AI 网关，插件架构，多通道集成（WhatsApp、Slack、Discord），exec 工具，权限提升，沙箱隔离。这类软件**做重要的工作**。

但精密的软件有精密的失败方式：

| 失败模式 | 为什么难以排查 |
|---|---|
| 异常断电后的配置损坏 | 重启时无验证 — 静默失败 |
| 通道 auth token 过期 | token 存储在嵌套 JSON 中 — 难以定位 |
| 插件依赖冲突 | 无自动化依赖解析 |
| Exec 工具审批循环 | 权限模型多层且不透明 |
| Gateway 连接被拒绝 | 6 种可能原因 — 无结构化分诊 |
| Pairing 未批准 | 无清晰的状态机可视化 |

**社区没有标准的救援流程。** 人们重装系统，丢失 sessions 和配置。或者在 Discord/Issues 上花数小时从碎片化的帖子中拼凑解决方案。

ClawICU 的存在是为了给 OpenClaw 用户一个**系统化的恢复路径**——不是又一个论坛帖子，而是一个从真实故障案例中构建的自动化诊断和修复工具。

---

## 工作流程

### 6 阶段救援流程

```
阶段 1 · 医生检查   →  openclaw doctor + openclaw doctor --fix
阶段 2 · 诊断检查   →  二进制 · 进程 · 配置 · 磁盘 · 网络
阶段 3 · 分诊评估   →  危险 / 警告 / 稳定
阶段 4 · 治疗方案   →  自动 / 快速 / 完整 / 重置
阶段 5 · 工具解锁面板  →  交互式配置编辑器（exec、浏览器、elevated、沙盒）
阶段 6 · 出院报告   →  变更摘要 + 重启指导
```

### 工具解锁面板（Phase 5）

这是你希望 OpenClaw 内置的面板——交互式安全配置编辑器，通过官方 `openclaw config` 命令修改 `openclaw.json`。无需盲目编辑文件。

| 选项 | 配置键 | 效果 |
|------|--------|------|
| **Exec 自由模式** | `tools.exec.security=full`<br>`tools.exec.ask=off` | 移除所有 exec 限制和审批提示 |
| **启用浏览器** | `tools.allow += "browser"` | 允许运行浏览器工具 |
| **禁用 Elevated** | `tools.elevated.enabled=false` | 禁用 elevated exec 模式 |
| **开放沙盒** | `tools.sandbox.tools.allow=[*]` | 允许所有沙盒工具 |
| **安全默认** | various | 重置为安全默认值 |

> **安全提示：** 危险选项（2、5）需要输入 `yes` 确认。

---

## openclaw doctor --fix 自动处理的问题

阶段 1 自动运行 `openclaw doctor --fix` — 解决 OpenClaw 真实存在的问题：

| 类别 | 修复内容 |
|------|---------|
| **Legacy 迁移** | Sessions、agent、WhatsApp auth state |
| **配置路径** | xAI / Firecrawl 配置迁移 |
| **通道配置** | 跨平台兼容性修复 |
| **插件** | 自动启用 + 依赖解析 |
| **Gateway** | Auth token 生成 |
| **Shell** | Bash / Zsh / Fish 补全设置 |
| **系统** | systemd linger、cron store 修复 |

---

## 24 个已诊断的故障模式

问题有轻有重。按严重程度分类：

| 严重程度 | 问题 |
|----------|------|
| 🔴 **致命** | 配置损坏 · Gateway 崩溃 · 磁盘满 |
| 🟠 **警告** | Pairing 未批准 · 通道认证失败 · Cron 未执行 |
| 🟡 **提示** | 浏览器工具不工作 · Exec 需要审批 · 心跳未发送 |

查看完整 [故障百科 →](https://xagent.icu/docs)

---

## 开发

```bash
git clone https://github.com/SonicBotMan/clawicu.git
cd clawicu
npm install
npm run dev
```

---

## 参与贡献

发现问题？**[提交 Issue](https://github.com/SonicBotMan/clawicu/issues)** — 欢迎贡献。

---

<p align="center">

MIT License · [github.com/SonicBotMan/clawicu](https://github.com/SonicBotMan/clawicu)

**ClawICU — OpenClaw 的急救室。**

</p>
