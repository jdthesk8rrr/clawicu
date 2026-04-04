# ClawICU — OpenClaw Emergency Rescue System

<p align="center">
  <img src="https://img.shields.io/badge/version-0.2.0-blue.svg" alt="Version">
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License">
  <img src="https://img.shields.io/badge/OpenClaw-v2026.4-blueviolet.svg" alt="OpenClaw">
</p>

<p align="center">
  <strong>English</strong> · <a href="#中文">中文</a>
</p>

---

## What is ClawICU?

ClawICU is a rescue system for [OpenClaw](https://github.com/openclaw/openclaw) — an AI-powered local-first assistant gateway. When OpenClaw has issues (pairing failures, cron not running, channel auth errors), ClawICU helps diagnose and fix them.

**One command to start:**

```bash
curl -fsSL https://xagent.icu/rescue.sh | sh
```

Or download and run manually:

```bash
curl -fsSL https://xagent.icu/rescue.sh -o rescue.sh
chmod +x rescue.sh
./rescue.sh
```

---

## What It Does

### 6-Phase Rescue Flow

```
Phase 1: Doctor Check    → openclaw doctor + openclaw doctor --fix
Phase 2: Diagnostics     → System checks (binary, process, config, disk, network)
Phase 3: Triage          → Assess severity (Critical / Warning / Stable)
Phase 4: Treatment Plan  → Select repair strategy (Auto / Quick / Full / Nuclear)
Phase 5: Execute         → Apply repairs via openclaw doctor --fix
Phase 6: Report          → Summary + restart instructions
```

### What openclaw doctor --fix Handles

Configuration migrations and repairs from OpenClaw's built-in diagnostic tool:

- Legacy state migration (sessions, agent, WhatsApp auth)
- xAI / Firecrawl config path migration
- Channel configuration compatibility fixes
- Plugin auto-enable and dependency resolution
- Gateway auth token generation
- Shell completion setup
- systemd linger configuration
- Legacy cron store repair

### What the Website Covers

The [xagent.icu](https://xagent.icu) static site documents **24 common OpenClaw issues** with diagnosis steps and repair guides:

| Category | Issues |
|----------|--------|
| Config | Config file corruption, missing config |
| Connectivity | Network offline, gateway unreachable, dashboard cannot connect |
| Pairing | Pairing not approved, mention required in group |
| Channels | Channel authentication failed, Telegram/Discord/WhatsApp issues |
| Scheduling | Cron job not executing, heartbeat not sent |
| Execution | Browser tool not working, exec command requires approval |
| System | Disk full, memory high, port conflict |
| Security | DM policy misconfiguration, allowlist issues |

---

## Quick Start

```bash
# Run the rescue script
curl -fsSL https://xagent.icu/rescue.sh | sh

# Or visit the issue encyclopedia
open https://xagent.icu/docs
```

---

## Project Structure

```
clawicu/
├── rescue.sh              # Standalone rescue script (bundled, no dependencies)
├── src/
│   ├── app/
│   │   ├── page.tsx       # Landing page (ICU theme)
│   │   └── docs/
│   │       ├── page.tsx   # 24-issue encyclopedia grid
│   │       └── [slug]/    # Individual issue detail pages
│   └── components/
│       ├── Hero.tsx           # ICU Specialist hero
│       ├── PatientSymptoms.tsx # Common issues grid with severity badges
│       ├── TrustSection.tsx   # GitHub stars, MIT license
│       ├── ExaminationProcess.tsx # 4-phase examination flow
│       ├── TreatmentPlan.tsx   # 6-phase rescue protocol
│       └── QuickStartGuides.tsx # Links to OpenClaw official docs
└── public/                 # Static export deployed to xagent.icu
```

---

## Development

```bash
npm install
npm run dev      # Start dev server at localhost:3000
npm run build    # Static export to /out
```

---

## Contributing

Found an issue not covered? Submit it at [github.com/SonicBotMan/clawicu/issues](https://github.com/SonicBotMan/clawicu/issues).

---

## License

MIT License

---

<p align="center">
  <strong>ClawICU — When OpenClaw has issues, we diagnose it in the ICU.</strong>
</p>

---

# 中文版

<p align="center">
  <strong>English</strong> · <a href="#clawicu--openclaw-emergency-rescue-system">中文</a>
</p>

---

## 什么是 ClawICU？

ClawICU 是 [OpenClaw](https://github.com/openclaw/openclaw) 的急救系统 —— 一个本地优先的 AI 助手网关。当 OpenClaw 出现故障（配对失败、通道认证错误、cron 不执行）时，ClawICU 帮助诊断和修复。

**一行命令启动：**

```bash
curl -fsSL https://xagent.icu/rescue.sh | sh
```

---

## 核心功能

### 6 阶段救援流程

```
阶段 1: 医生检查   → openclaw doctor + openclaw doctor --fix
阶段 2: 诊断检查   → 系统检查（二进制、进程、配置、磁盘、网络）
阶段 3: 分诊评估   → 判断严重程度（危险 / 警告 / 稳定）
阶段 4: 治疗方案   → 选择修复策略（自动 / 快速 / 完整 / 重置）
阶段 5: 执行修复   → 通过 openclaw doctor --fix 应用修复
阶段 6: 出院报告   → 变更摘要 + 重启指导
```

### openclaw doctor --fix 自动处理

- Legacy state 迁移（sessions、agent、WhatsApp auth）
- xAI / Firecrawl 配置路径迁移
- 通道配置兼容性修复
- 插件自动启用和依赖解析
- Gateway 认证令牌生成
- Shell 补全设置
- systemd linger 配置
- Legacy cron store 修复

### 网站文档

[xagent.icu](https://xagent.icu) 静态站点记录了 **24 种常见 OpenClaw 问题**，包含诊断步骤和修复指南。

---

## 快速开始

```bash
curl -fsSL https://xagent.icu/rescue.sh | sh
```

---

## 参与贡献

发现问题？请前往 [github.com/SonicBotMan/clawicu/issues](https://github.com/SonicBotMan/clawicu/issues) 提交。

---

## 许可证

MIT License

---

<p align="center">
  <strong>ClawICU — 当 OpenClaw 遇到问题时，我们是它的急救室。</strong>
</p>