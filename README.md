# ClawICU

### OpenClaw Emergency Rescue System

<p align="center">

![Version](https://img.shields.io/badge/rescue_script-0.2.0-ef4444?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-22c55e?style=for-the-badge)
![OpenClaw](https://img.shields.io/badge/OpenClaw-gateway-8b5cf6?style=for-the-badge)
![Issue guides](https://img.shields.io/badge/issue_guides-25-2563eb?style=for-the-badge)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-64748b?style=for-the-badge)

</p>

<p align="center">

**[Website](https://xagent.icu)** ·
**[Docs](https://xagent.icu/docs)** ·
**[Rescue](https://xagent.icu/rescue)** ·
**[SOS share](https://xagent.icu/sos)** ·
**[Download](https://xagent.icu/download)** ·
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

## Quick start

| | |
|---|---|
| **One-liner (recommended)** | `curl -fsSL https://xagent.icu/r \| sh` |
| **Same script, explicit URL** | `curl -fsSL https://xagent.icu/rescue.sh \| sh` |
| **Save then run** | `curl -fsSL https://xagent.icu/r -o rescue.sh && chmod +x rescue.sh && ./rescue.sh` |

The bundled script is **POSIX `sh`**, works when piped from `curl`, and redirects **stdin from `/dev/tty`** so Phase 4 menus stay interactive.

**Site:** [xagent.icu](https://xagent.icu) — ICU-themed marketing, docs, and SEO. **Issue encyclopedia:** [xagent.icu/docs](https://xagent.icu/docs) — **25** guided failure modes.

---

## What ClawICU does

ClawICU is a **structured rescue system** for [OpenClaw](https://github.com/openclaw/openclaw): detect what broke, triage severity, offer an interactive treatment plan, run targeted repairs (with backup), and re-verify.

Not a forum thread — a **six-phase protocol** plus modular checks and repairs.

### Six-phase protocol (shell rescue)

| Phase | Name | What happens |
|------:|------|----------------|
| **0** | Bootstrap | OS / install method, temp dir, logging |
| **1** | Doctor | `openclaw doctor` with **~30s timeout** (hangs from bad plugins are killed); output captured for later phases |
| **2** | Standalone checks | **20** diagnostic modules (config JSON5, gateway `/healthz`, plugins & SDK, credentials, daemon, version mismatch, port 18789 with openclaw-aware logic, disk, channel policy, env, exec approvals, …) |
| **3** | Merge & triage | Severity labels, “vital signs” summary |
| **4** | Treatment menu | **Interactive** — Auto / Quick / Full / Nuclear / Export / Quit |
| **5** | Execute & verify | Repairs (e.g. disable broken plugins, `plugins.allow`, gateway restart for version skew), then re-check |

Repairs include **automatic backup** before mutating config or extensions where applicable.

### Related docs (not a numbered phase)

- **[Tool Unlock Panel](https://xagent.icu/docs/tool-unlock-panel)** — walkthrough for `tools.exec`, browser, elevated, sandbox flags via `openclaw config`.
- **[SOS landing / X share card](https://xagent.icu/sos)** — share-friendly page + Open Graph image for social previews.

---

## The pain (why this exists)

OpenClaw is powerful: gateway on **18789**, plugins, channels, exec tooling. Failure modes are easy to hit and hard to untangle — corrupt JSON5, gateway down, **plugin SDK / `api.config.get` errors**, **empty `plugins.allow`**, Discord **channel policy**, CLI vs gateway **version mismatch**, missing credentials, systemd/launchd daemon, port conflicts, and more.

ClawICU turns recurring community pain into **check → explain → fix** loops instead of hours of manual grep and reinstall roulette.

---

## Repository layout

```
clawicu/
├── rescue/                    # Modular sources (checks/, repairs/, lib/)
├── scripts/build-rescue.sh    # Bundles modules → dist/rescue.sh
├── public/
│   ├── rescue.sh              # Synced bundle (site + GitHub raw)
│   │                          # Live site: https://xagent.icu/r → same script (server rewrite)
│   ├── sos-card.svg / .png    # OG image for /sos (regenerate: npm run build:share-card)
│   └── sos-card-render.html   # Generated by capture script (inline SVG for Chrome)
├── src/                       # Next.js site (App Router, static export → out/)
└── scripts/capture-sos-card.sh  # Headless Chrome → sos-card.png
```

---

## Development

```bash
git clone https://github.com/SonicBotMan/clawicu.git
cd clawicu
npm install
npm run dev          # http://localhost:3000
npm run build        # Static site → out/

# After editing public/sos-card.svg (share card art)
npm run build:share-card   # needs Google Chrome or Chromium (see script for CHROME_PATH)
```

Rebuild the live bundle after changing `rescue/`:

```bash
sh scripts/build-rescue.sh && cp dist/rescue.sh public/rescue.sh
```

---

## Contributing

Found a gap or a new failure mode? **[Open an issue](https://github.com/SonicBotMan/clawicu/issues)** or send a pull request.

---

<p align="center">

MIT License · [github.com/SonicBotMan/clawicu](https://github.com/SonicBotMan/clawicu)

**ClawICU — OpenClaw’s emergency room.**

</p>

---

# 中文版（摘要）

**ClawICU** 是面向 [OpenClaw](https://github.com/openclaw/openclaw) 的**结构化急救脚本 + 文档站**：一条命令跑完 **6 个阶段**（Bootstrap → 带超时的 doctor → **20** 项独立检查 → 合并分诊 → **可交互**处置菜单 → 执行修复与验证），并配套 [xagent.icu](https://xagent.icu) 上的 **25** 篇故障指南。

| 用法 | 命令 |
|------|------|
| 推荐一键 | `curl -fsSL https://xagent.icu/r \| sh` |
| 显式脚本地址 | `curl -fsSL https://xagent.icu/rescue.sh \| sh` |

脚本版本见仓库内 `CLAWICU_VERSION`（当前 **0.2.0**）。分享求救卡片与 X 预览页：[xagent.icu/sos](https://xagent.icu/sos)。参与贡献请前往 [Issues](https://github.com/SonicBotMan/clawicu/issues)。
