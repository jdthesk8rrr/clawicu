"use client";
import { useState } from "react";
import { ChevronDown, CheckCircle2, Search, Shield, BarChart3, Zap, Wrench, RefreshCcw } from "lucide-react";
import { cn } from "@/lib/utils";

/* Each phase has its own clinical color scheme */
const phases = [
  {
    number: 0,
    title: "Bootstrap",
    description: "Detect OS, architecture, and installation method",
    icon: Search,
    status: "INTAKE",
    accentColor: "#8892b0",
    statusClass: "badge-warning" as const,
    details: [
      "Identify macOS vs Linux",
      "Detect npm, Docker, Podman, or source install",
      "Create temporary working directory",
      "Initialize logging",
    ],
  },
  {
    number: 1,
    title: "Doctor Delegation",
    description: "Run openclaw doctor with crash-safe 30s timeout",
    icon: Shield,
    status: "TRIAGE",
    accentColor: "#ffb020",
    statusClass: "badge-warning" as const,
    details: [
      "Run openclaw doctor with 30-second timeout",
      "Auto-kills if a broken plugin causes a hang",
      "Capture full diagnostic output to temp file",
      "Detects TypeError, unhandled rejections, API errors",
    ],
  },
  {
    number: 2,
    title: "Standalone Checks",
    description: "Run 20 independent diagnostic check modules",
    icon: BarChart3,
    status: "SCAN",
    accentColor: "#ff4d4d",
    statusClass: "badge-critical" as const,
    details: [
      "Config file JSON5 syntax validation",
      "Gateway health check on port 18789",
      "Plugin runtime & SDK API compatibility",
      "Credential presence for all AI providers",
      "Daemon service (launchd / systemd) status",
      "CLI vs Gateway version mismatch detection",
      "Port conflict check (skips openclaw itself)",
      "Node.js version, disk space, state directory",
      "Channel policy, env vars, exec-approvals",
    ],
  },
  {
    number: 3,
    title: "Merge & Triage",
    description: "Classify severity, display vital signs monitor",
    icon: Zap,
    status: "ASSESS",
    accentColor: "#ff4d4d",
    statusClass: "badge-critical" as const,
    details: [
      "Aggregate all diagnostic findings",
      "Classify by severity: fatal / warn / info",
      "Vital signs monitor: CRITICAL / WARNING / STABLE",
      "Generate prioritized issue list for repair",
    ],
  },
  {
    number: 4,
    title: "Guided Repair Menu",
    description: "Interactive menu — works even via curl | sh",
    icon: Wrench,
    status: "TREAT",
    accentColor: "#3b9eff",
    statusClass: "badge-stable" as const,
    details: [
      "Interactive menu: Auto / Quick / Full / Nuclear / Export / Quit",
      "Fully interactive even when piped from curl",
      "Auto mode: handles all detected issues automatically",
      "Quick mode: safe, low-risk repairs only",
    ],
  },
  {
    number: 5,
    title: "Execute & Verify",
    description: "Perform targeted repairs with rollback safety",
    icon: RefreshCcw,
    status: "STABLE",
    accentColor: "#00e87a",
    statusClass: "badge-stable" as const,
    details: [
      "Automatic backup before any changes",
      "Disable broken / incompatible plugins (non-destructive)",
      "Restart gateway to fix version mismatch",
      "Populate plugins.allow to remove security risk",
      "Post-repair openclaw doctor verification",
    ],
  },
];

export function RescueSteps() {
  const [openPhase, setOpenPhase] = useState<number | null>(null);

  return (
    <div className="space-y-3">
      {phases.map((phase) => {
        const isOpen = openPhase === phase.number;
        const Icon = phase.icon;
        const ac = phase.accentColor;

        return (
          <div
            key={phase.number}
            className={cn(
              "group relative overflow-hidden rounded-xl border backdrop-blur-[12px] transition-all duration-300",
              isOpen
                ? "bg-card/80"
                : "border-border/50 bg-card/40 hover:bg-card/60"
            )}
            style={{
              borderColor: isOpen ? `${ac}40` : undefined,
              boxShadow: isOpen ? `0 0 20px ${ac}18` : undefined,
            }}
          >
            {/* Left accent bar */}
            <div
              className="absolute left-0 top-0 bottom-0 w-0.5 transition-opacity duration-300"
              style={{
                background: `linear-gradient(180deg, transparent, ${ac}, transparent)`,
                opacity: isOpen ? 1 : 0,
              }}
            />

            {isOpen && (
              <div
                className="absolute inset-0 pointer-events-none"
                style={{ background: `linear-gradient(135deg, ${ac}06, transparent 60%)` }}
              />
            )}

            <button
              onClick={() => setOpenPhase(isOpen ? null : phase.number)}
              className="w-full flex items-center justify-between p-5 text-left"
            >
              <div className="flex items-center gap-4">
                {/* Phase number — hospital chart entry */}
                <div
                  className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg ring-1 transition-all"
                  style={{
                    background: `${ac}12`,
                    borderColor: `${ac}25`,
                    border: `1px solid ${ac}25`,
                  }}
                >
                  <Icon className="h-5 w-5 transition-all" style={{ color: ac }} />
                </div>

                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2.5 flex-wrap">
                    <span className="font-mono text-[10px] text-muted-foreground/60">
                      PHASE {String(phase.number).padStart(2, "0")}
                    </span>
                    <span
                      className={cn(
                        "rounded-full px-2 py-0.5 font-mono text-[10px] font-bold uppercase tracking-wider",
                        phase.statusClass
                      )}
                    >
                      {phase.status}
                    </span>
                    <h3 className="font-heading font-semibold text-foreground">
                      {phase.title}
                    </h3>
                  </div>
                  <p className="mt-0.5 text-sm text-muted-foreground">
                    {phase.description}
                  </p>
                </div>
              </div>

              <ChevronDown
                className={cn(
                  "ml-4 h-4 w-4 shrink-0 text-muted-foreground transition-transform duration-300",
                  isOpen && "rotate-180"
                )}
              />
            </button>

            {/* Expanded treatment notes */}
            <div
              className={cn(
                "overflow-hidden transition-all duration-300",
                isOpen ? "max-h-96 opacity-100" : "max-h-0 opacity-0"
              )}
            >
              <div className="px-5 pb-5">
                <div
                  className="rounded-lg p-4"
                  style={{ background: `${ac}08`, border: `1px solid ${ac}18` }}
                >
                  <p className="mb-3 font-mono text-[10px] uppercase tracking-widest" style={{ color: ac }}>
                    Treatment Notes
                  </p>
                  <ul className="space-y-2">
                    {phase.details.map((detail, i) => (
                      <li key={i} className="flex items-start gap-2.5 text-sm text-muted-foreground">
                        <CheckCircle2
                          className="mt-0.5 h-3.5 w-3.5 shrink-0 transition-colors"
                          style={{ color: ac }}
                        />
                        {detail}
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}
