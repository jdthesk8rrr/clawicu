import type { Metadata } from "next";
import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { RescueSteps } from "@/components/RescueSteps";
import { TerminalBlock } from "@/components/ui/TerminalBlock";
import { GridBackground } from "@/components/effects";
import { HeartPulse, Activity, ShieldCheck, Syringe } from "lucide-react";

export const metadata: Metadata = {
  title: "Rescue Protocol — How ClawICU Fixes OpenClaw",
  description:
    "ClawICU's 6-phase rescue protocol: crash-safe doctor check (30s timeout), 20 diagnostic checks, triage by severity, interactive treatment menu, targeted repairs with auto-backup, and verification.",
  alternates: {
    canonical: "/rescue/",
  },
  openGraph: {
    title: "Rescue Protocol — How ClawICU Fixes OpenClaw",
    description:
      "6 phases from detection to verified repair. Run: curl -fsSL https://xagent.icu/r | sh",
    type: "article",
  },
};

/* Phase status indicator strip */
const phaseIndicators = [
  { label: "Intake",    color: "#8892b0", filled: true },
  { label: "Triage",   color: "#ffb020", filled: true },
  { label: "Scan",     color: "#ff4d4d", filled: true },
  { label: "Assess",   color: "#ff4d4d", filled: true },
  { label: "Treat",    color: "#3b9eff", filled: true },
  { label: "Stable",   color: "#00e87a", filled: true },
];

export default function RescuePage() {
  return (
    <>
      <Header />
      <GridBackground />

      {/* ECG Hero Banner */}
      <div className="relative overflow-hidden border-b border-border/30 bg-[#030609]/80 pt-24 pb-0">
        {/* Background ECG line */}
        <svg
          viewBox="0 0 1200 80"
          className="absolute inset-x-0 bottom-0 opacity-[0.06] pointer-events-none"
          fill="none"
          preserveAspectRatio="none"
        >
          <path
            d="M0,40 L150,40 L175,10 L195,70 L215,5 L235,75 L250,40 L400,40 L425,10 L445,70 L465,5 L485,75 L500,40 L650,40 L675,10 L695,70 L715,5 L735,75 L750,40 L900,40 L925,10 L945,70 L965,5 L985,75 L1000,40 L1200,40"
            stroke="#00e87a"
            strokeWidth="2"
            style={{
              strokeDasharray: 2000,
              strokeDashoffset: 2000,
              animation: "ecg-run 6s linear infinite",
            }}
          />
        </svg>

        <div className="relative z-10 mx-auto max-w-4xl px-6 pb-12">
          {/* Emergency badge */}
          <div className="mb-6 flex items-center gap-3">
            <span className="flex items-center gap-2 rounded-full border border-primary/30 bg-primary/10 px-4 py-1.5 font-mono text-xs font-bold uppercase tracking-widest text-primary">
              <HeartPulse className="h-3.5 w-3.5 animate-heartbeat" />
              6-Phase Rescue Protocol
            </span>
          </div>

          <h1 className="font-heading text-4xl font-extrabold tracking-tight text-foreground sm:text-5xl md:text-6xl">
            How ClawICU{" "}
            <span className="text-primary">Rescues</span>
          </h1>

          <p className="mt-4 max-w-2xl text-base text-muted-foreground leading-relaxed sm:text-lg">
            From one command to full recovery — a battle-tested 6-phase protocol that diagnoses,
            treats, and verifies your OpenClaw installation.
          </p>

          {/* Phase flow indicators */}
          <div className="mt-8 flex flex-wrap items-center gap-2">
            {phaseIndicators.map((p, i) => (
              <div key={p.label} className="flex items-center gap-2">
                <div
                  className="flex items-center gap-1.5 rounded-full px-3 py-1 font-mono text-[11px] font-bold uppercase tracking-wider"
                  style={{
                    background: `${p.color}15`,
                    border: `1px solid ${p.color}35`,
                    color: p.color,
                  }}
                >
                  <span
                    className="h-1.5 w-1.5 rounded-full"
                    style={{ background: p.color }}
                  />
                  {p.label}
                </div>
                {i < phaseIndicators.length - 1 && (
                  <span className="text-muted-foreground/30 text-xs">→</span>
                )}
              </div>
            ))}
          </div>

          {/* Quick stats */}
          <div className="mt-8 flex flex-wrap gap-6">
            {[
              { icon: Activity,    label: "20 Diagnostic Checks", color: "#ff4d4d" },
              { icon: Syringe,     label: "12 Repair Modules",    color: "#ffb020" },
              { icon: ShieldCheck, label: "Auto Backup Safety",   color: "#00e87a" },
            ].map((stat) => (
              <div key={stat.label} className="flex items-center gap-2 text-sm text-muted-foreground">
                <stat.icon className="h-4 w-4" style={{ color: stat.color }} />
                <span>{stat.label}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      <main className="relative z-10 min-h-screen pb-16">
        <div className="mx-auto max-w-4xl px-6 pt-12">
          <RescueSteps />

          <div className="mt-16 text-center">
            <p className="text-muted-foreground mb-6 text-sm">
              Ready to run the rescue?
            </p>
            <div className="mx-auto max-w-xl">
              <TerminalBlock command="curl -fsSL https://xagent.icu/r | sh" />
            </div>
          </div>
        </div>
      </main>

      <Footer />
    </>
  );
}
