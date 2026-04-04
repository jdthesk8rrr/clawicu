# ClawICU — OpenClaw Emergency Rescue System

## Project Plan v1.0

**Date**: 2026-04-03
**Status**: Planning Complete — Ready for Implementation
**Repository**: `/Users/a523034406/Documents/OpenCode/AIICU/`

---

## 1. Problem Statement

OpenClaw frequently becomes unusable due to:
- Configuration corruption or invalid settings
- Plugin installation failures or compatibility issues
- Version upgrades breaking existing setups
- Daemon/gateway crashes
- Credential problems
- Channel connectivity failures

When users have only one OpenClaw instance and it breaks, they cannot use another agent to fix it — resulting in a helpless situation. **ClawICU** solves this by providing a self-contained emergency rescue system.

---

## 2. Solution Overview

ClawICU provides two rescue mechanisms:

1. **One-line rescue**: `curl -fsSL https://clawicu.ai/r | sh`
   - Interactive, guided terminal script
   - Downloads and runs on the broken machine
   - No dependencies beyond basic UNIX tools

2. **Offline package**: `clawicu-rescue-v1.0.0.tar.gz`
   - Downloadable complete rescue bundle
   - Works on machines with limited connectivity
   - Transfer via USB/scp when needed

**Supports all installation methods**: npm global, Docker, Podman, source build

---

## 3. Architecture

```
┌──────────────────────────────────────────────────────────────────────────┐
│                          ClawICU System                                  │
│                                                                          │
│  ┌─────────────────────┐  ┌────────────────────┐  ┌──────────────────┐│
│  │  Cloudflare Pages    │  │  Cloudflare Workers │  │  Cloudflare R2   ││
│  │  (Next.js SSG)       │  │  (Edge Functions)   │  │  (Asset Storage) ││
│  │  clawicu.ai          │  │  /api/v1/           │  │  rescue.sh       ││
│  │                      │  │    rescue-script    │  │  checksums.txt   ││
│  │                      │  │    check-version    │  │  *.tar.gz        ││
│  └─────────────────────┘  └────────────────────┘  └──────────────────┘│
└──────────────────────────────────────────────────────────────────────────┘

User's Broken Machine:
    curl -fsSL https://clawicu.ai/r | sh
         │
         ▼
    ┌─────────────────────────────────────────────────────┐
    │  rescue.sh (POSIX sh, self-contained)               │
    │                                                      │
    │  Phase 1: Doctor Delegation (try openclaw doctor)   │
    │  Phase 2: Standalone Checks (17 check modules)      │
    │  Phase 3: Merge & Triage (FATAL/WARN/INFO)        │
    │  Phase 4: Interactive Repair Menu                   │
    │  Phase 5: Execute Repairs (with rollback safety)    │
    │  Phase 6: Verify & Report                          │
    └─────────────────────────────────────────────────────┘
```

---

## 4. Rescue Flow (6 Phases)

### Phase 0: Bootstrap
- Detect OS (macOS/Linux), architecture (x86_64/arm64)
- Detect shell capabilities (POSIX sh / bash 3.x / bash 4+)
- **Detect install method** (npm global / Docker / Podman / source build)
- **Detect Docker/Podman context** (is OpenClaw running inside a container?)
- Create temp working directory with trap cleanup
- Initialize logging
- Download modules from CDN (or use bundled if offline)

### Phase 1: Doctor Delegation
- Try `openclaw doctor` — if binary works, parse its output
- Try `openclaw --version` — record version for version-aware checks
- On success: capture issues from doctor output
- On failure: record error, proceed to Phase 2

### Phase 2: Standalone Checks
Run 17 independent check modules:

| Check | Severity | Detects |
|-------|----------|---------|
| `check-binary` | 🔴 Fatal | Binary missing or not executable |
| `check-node` | 🔴 Fatal | Node.js < 22.12 |
| `check-install-method` | 🟡 Warn | Installation type (npm/Docker/Podman/source) |
| `check-docker` | 🟡 Warn | Docker/Podman container issues (if applicable) |
| `check-state-dir` | 🔴 Fatal | `~/.openclaw/` missing or permissions broken |
| `check-config` | 🔴 Fatal | config.json5 invalid JSON5 (must handle JSON5, not plain JSON) |
| `check-config-schema` | 🟡 Warn | Config fields invalid (port, auth, etc.) |
| `check-credentials` | 🟡 Warn | Provider API keys missing or empty |
| `check-gateway` | 🔴 Fatal | Gateway not running on port 18789 |
| `check-daemon` | 🟡 Warn | launchd/systemd service not installed |
| `check-plugins` | 🟡 Warn | Plugin manifests broken or load errors |
| `check-port` | 🔴 Fatal | Port 18789 occupied by another process |
| `check-disk` | 🟡 Warn | < 100MB free disk |
| `check-sessions` | 🔵 Info | Session files corrupted |
| `check-version` | 🟡 Warn | OpenClaw version unsupported |
| `check-envvars` | 🔵 Info | Conflicting `OPENCLAW_*` env vars |
| `check-exec-approvals` | 🔵 Info | exec-approvals.json unparseable |

### Phase 3: Merge & Triage
- Combine doctor output + standalone check results
- Deduplicate overlapping issues
- Cross-validate conflicting results
- Classify severity: 🔴 FATAL / 🟡 WARN / 🔵 INFO
- Prioritize: fatal first, then warnings

### Phase 4: Guided Repair Menu
Interactive menu with repair options:

```
┌─────────────────────────────────────────────────────┐
│  ClawICU — Issues Found: 3                         │
│                                                      │
│  🔴 FATAL: Config file has invalid JSON5           │
│  🟡 WARN:  Gateway not running                     │
│  🟡 WARN:  Daemon service not installed            │
│                                                      │
│  [a] Fix all automatically (recommended)            │
│  [1] Fix: Config file                              │
│  [2] Fix: Gateway (restart)                        │
│  [3] Fix: Daemon service (reinstall)               │
│  [s] Safe mode (disable all plugins)               │
│  [r] Full state reset (preserve credentials)       │
│  [R] Clean reinstall                               │
│  [e] Export diagnostic report                       │
│  [q] Quit                                          │
└─────────────────────────────────────────────────────┘
```

### Phase 5: Execute Repairs
For each selected repair:
1. Describe what will happen (dry-run output)
2. Prompt for confirmation
3. Create timestamped backup (tar.gz)
4. Execute repair
5. Verify repair succeeded
6. On failure: auto-rollback to previous state

### Phase 6: Verify & Report
- Re-run Phase 2 checks to confirm fix
- Generate summary report:
  - What was broken
  - What was fixed
  - What still needs attention
  - Backup location
  - Rollback instructions
- Write report to `~/.openclaw/clawicu-report.*`

---

## 5. Repair Modules (11 Modules)

| Repair | Risk | Preserves Data |
|--------|------|----------------|
| `repair-config` | 🟢 Low | Yes — restores from `.bak` |
| `repair-config-field` | 🟢 Low | Yes — resets individual fields |
| `repair-gateway` | 🟡 Medium | Yes — restart only |
| `repair-daemon` | 🟡 Medium | Yes — reinstalls service |
| `repair-credentials` | 🟢 Low | Yes — only prompts for missing |
| `repair-plugins` | 🟢 Low | Yes — disables, records disabled |
| `repair-sessions` | 🟡 Medium | Partial — removes corrupted only |
| `repair-downgrade` | 🟡 Medium | Yes — reinstalls older version |
| `repair-nuclear` | 🔴 High | Partial — preserves credentials |
| `repair-reinstall` | 🔴 High | No — full backup first |
| `repair-port` | 🟢 Low | Yes |
| `repair-docker` | 🟡 Medium | Yes — restart container, recreate volumes |

---

## 6. Website Structure

| Route | Purpose |
|-------|---------|
| `/` | Hero: one-click rescue command + common issues |
| `/rescue` | Interactive step-by-step rescue guide |
| `/docs` | Issue encyclopedia index |
| `/docs/[slug]` | Individual issue diagnosis + fix guide |
| `/download` | Offline package download |
| `/api/v1/rescue-script` | Edge: dynamic personalized script generation |
| `/api/v1/check-version` | Edge: version compatibility check |

---

## 7. File Structure

```
AIICU/
├── CLAWICU_PLAN.md                    # This document
│
├── src/                              # Next.js 15 website (Tailwind + shadcn/ui)
│   ├── app/
│   │   ├── page.tsx                  # Landing page
│   │   ├── rescue/page.tsx           # Guided rescue
│   │   ├── docs/[slug]/page.tsx      # Issue guides (MDX)
│   │   ├── download/page.tsx         # Offline package
│   │   └── api/v1/
│   │       ├── rescue-script/route.ts
│   │       └── check-version/route.ts
│   ├── components/
│   │   ├── Hero.tsx
│   │   ├── RescueCommand.tsx
│   │   ├── OSDetector.tsx
│   │   └── ...
│   └── content/issues/               # 15 MDX docs
│
├── rescue/                           # Rescue script source
│   ├── rescue.sh                     # Main entry point
│   ├── lib/
│   │   ├── bootstrap.sh              # OS/shell detection
│   │   ├── log.sh                   # Structured logging
│   │   ├── ui.sh                    # Menu/prompt/spinner
│   │   ├── backup.sh                # tar.gz backup engine
│   │   ├── state.sh                 # Rollback state machine
│   │   └── verify.sh                # SHA256 verification
│   ├── checks/                       # 17 check-*.sh modules
│   └── repairs/                      # 12 repair-*.sh modules
│
├── scripts/
│   ├── build-rescue.sh               # Bundle into single .sh
│   ├── package-offline.sh            # Create .tar.gz
│   └── generate-checksums.sh         # SHA256 checksums
│
└── tests/
    ├── unit/                         # Per-module tests
    ├── integration/                   # Multi-module flows
    └── e2e/                          # Docker-based scenarios
```

---

## 8. Security Design

| Layer | Implementation |
|-------|---------------|
| **Transport** | TLS 1.2+ enforced; `curl --proto '=https' --tlsv1.2` |
| **Integrity** | SHA256 checksums published alongside every deliverable |
| **Two-step pattern** | Download → Verify checksum → Run |
| **Backup before repair** | Every destructive action creates timestamped tar.gz backup; **leverage existing `openclaw backup` command** when available |
| **Install-method awareness** | Rescue flow adapts based on npm/Docker/Podman/source install |
| **Rollback on failure** | State machine auto-rolls back if verification fails |
| **Dry-run mode** | `--dry-run` shows what would happen without executing |
| **Credential protection** | API keys never logged or reported |
| **Minimal telemetry** | Opt-in only, anonymous, no personal data |

---

## 9. Testing Strategy (TDD)

| Level | Coverage | Approach |
|-------|----------|----------|
| **Unit** | 80% | Per-module tests; POSIX shell assert helpers |
| **Integration** | 15% | Multi-module flows (diagnose → repair → verify) |
| **E2E** | 5% | Docker containers with intentionally broken setups |

### E2E Test Scenarios

| Scenario | What's Broken | Expected Fix |
|----------|--------------|--------------|
| `test-broken-config` | Invalid JSON config | Restore from backup |
| `test-broken-plugin` | Malformed plugin manifest | Disable plugin |
| `test-no-gateway` | Gateway not started | Start gateway |
| `test-no-daemon` | No launchd/systemd plist | Install daemon |
| `test-port-conflict` | Port 18789 occupied | Resolve conflict |
| `test-clean-install` | Nothing broken | All checks pass |

---

## 10. Infrastructure

```
Cloudflare Pages     → clawicu.ai (Next.js SSG)
Cloudflare Workers   → /api/v1/* edge functions
Cloudflare R2        → rescue.sh, checksums.txt, *.tar.gz

GitHub Actions
  ├── Push → CI (shellcheck + tests + build)
  ├── Tag  → Release (publish to R2 + Pages)
  └── Weekly → Test against latest OpenClaw version
```

---

## 11. Implementation Roadmap (25 Commits)

### Phase A: Foundation (Commits 1-4)
1. Scaffold Next.js project with Tailwind + shadcn/ui
2. Landing page hero with copy-paste command
3. Test framework and fixtures
4. Bootstrap, logging, and UI modules

### Phase B: Core Engine (Commits 5-6)
5. Backup engine with create/restore/verify
6. State machine for rollback tracking

### Phase C: Check Modules (Commits 7-10)
7. `check-binary` + `check-node`
8. `check-config` + `check-config-schema`
9. `check-gateway` + `check-port` + `check-daemon`
10. All remaining checks (credentials, plugins, disk, sessions, version, envvars, exec-approvals)

### Phase D: Repair Modules (Commits 11-14)
11. `repair-config` (restore from backup)
12. `repair-gateway` + `repair-daemon`
13. `repair-plugins` + `repair-credentials`
14. `repair-nuclear` + `repair-reinstall` + remaining repairs

### Phase E: Integration (Commits 15-17)
15. Doctor delegation pipeline
16. Full diagnostic engine with interactive menu
17. Repair execution with rollback and verification

### Phase F: Build & Package (Commits 18-19)
18. Build scripts for bundling and checksums
19. Offline package builder

### Phase G: Website (Commits 20-22)
20. Docs pages with issue encyclopedia (MDX)
21. Download page with OS detection
22. Guided rescue page

### Phase H: API & CI/CD (Commits 23-25)
23. API routes for dynamic script and version check
24. CI pipeline (lint, test, build)
25. Release workflow and scheduled tests

---

## 12. Key Technical Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Script language | POSIX sh + bash fallback | macOS has bash 3.2; strict POSIX = max compatibility |
| Hosting | Cloudflare Pages + Workers + R2 | Edge functions for dynamic script; free tier sufficient |
| Config validation | Embedded simplified JSON5 parser | OpenClaw uses JSON5 (not plain JSON); must handle trailing commas, comments, unquoted keys |
| Backup format | tar.gz + manifest | Standard, verifiable, restorable |
| Test framework | Custom POSIX assert helpers | No bats/shunit2 — fully self-contained |
| Install method detection | Early bootstrap check | Rescue flow must adapt (npm vs Docker vs Podman vs source) |
| Leverage `openclaw backup` | When binary works | Use existing backup command before custom backup logic |

---

## 13. Shell Compatibility

```
detect_shell_capabilities()
    │
    ├── bash >= 4.x → arrays, [[ ]], local, enhanced progress bars
    ├── bash 3.x → basic arrays, [[ ]], no mapfile (macOS default)
    ├── dash/POSIX sh → no arrays, [ ] test only, minimal UI
    └── Unknown → treat as POSIX sh (safest fallback)
```

---

## 14. Doctor Delegation Priority

1. If `openclaw doctor` succeeds → Use its diagnostics (most accurate)
2. If `openclaw doctor` fails → Capture error, run standalone checks
3. If `openclaw` binary missing → Standalone checks only
4. Merge results into unified triage view

---

## 15. Offline Package Contents

```
clawicu-rescue-v1.0.0.tar.gz
├── rescue.sh                 # Main script (works offline)
├── lib/                      # All utility modules
├── checks/                   # All check modules
├── repairs/                  # All repair modules
├── VERSION                   # Package version
└── SHA256SUMS               # Self-integrity check
```

---

## 16. OpenClaw Knowledge Applied

| Component | Path/Command | Key Details |
|-----------|--------------|-------------|
| State directory | `~/.openclaw/` | Configurable via `OPENCLAW_STATE_DIR` |
| Config file | `config.json5` | JSON5 format with Zod schema validation |
| Credentials | `~/.openclaw/credentials/` + secrets subsystem | Provider API keys via OpenClaw's secret resolution pipeline |
| Gateway | Port 18789 | Health check endpoint |
| Daemon (macOS) | `~/Library/LaunchAgents/` | launchd plist |
| Daemon (Linux) | `~/.config/systemd/user/` | systemd unit |
| CLI commands | `openclaw doctor`, `onboard`, `gateway`, `plugins` | Diagnostic tools |
| Node requirement | >= 22.12 | OpenClaw minimum |

---

## 17. Next Steps

To begin implementation:

1. **User confirms plan** — approve or request modifications
2. **Phase A begins** — scaffold Next.js project, create landing page
3. **Parallel workstreams** — shell scripts + website developed simultaneously
4. **Continuous testing** — TDD approach throughout

---

*Plan created through deep analysis of OpenClaw source code (github.com/openclaw/openclaw) and official documentation (docs.openclaw.ai).*
