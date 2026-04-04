"use client";
import { FileWarning, Puzzle, Wifi, Cpu, KeyRound, Network } from "lucide-react";
import { IssueCard } from "./IssueCard";
import type { LucideIcon } from "lucide-react";

interface Issue {
  icon: LucideIcon;
  title: string;
  description: string;
}

const issues: Issue[] = [
  {
    icon: FileWarning,
    title: "Config Corruption",
    description:
      "Configuration file has invalid JSON5 syntax or is corrupted",
  },
  {
    icon: Puzzle,
    title: "Plugin Failures",
    description:
      "Plugin manifests broken or plugins failing to load",
  },
  {
    icon: Wifi,
    title: "Gateway Crash",
    description:
      "Gateway not running on port 18789",
  },
  {
    icon: Cpu,
    title: "Daemon Issues",
    description:
      "launchd/systemd service not properly installed",
  },
  {
    icon: KeyRound,
    title: "Credential Problems",
    description:
      "Provider API keys missing or authentication failures",
  },
  {
    icon: Network,
    title: "Port Conflicts",
    description:
      "Port 18789 is occupied by another process",
  },
];

export function IssueGrid() {
  return (
    <section className="mx-auto w-full max-w-6xl px-6 py-24">
      <div className="mb-14 text-center">
        <span className="mb-4 inline-block rounded-full bg-primary/10 px-4 py-1.5 font-mono text-xs font-medium uppercase tracking-widest text-primary ring-1 ring-primary/20">
          Common Issues
        </span>
        <h2 className="mt-4 font-heading text-3xl font-bold tracking-tight text-foreground sm:text-4xl">
          When OpenClaw Breaks
        </h2>
        <p className="mx-auto mt-4 max-w-2xl text-base text-muted-foreground">
          From config corruption to gateway crashes — ClawICU diagnoses and repairs every OpenClaw emergency.
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {issues.map((issue, i) => (
          <div key={issue.title} className="reveal" style={{ transitionDelay: `${i * 80}ms` }}>
            <IssueCard
              icon={issue.icon}
              title={issue.title}
              description={issue.description}
              delay={0.6 + i * 0.08}
            />
          </div>
        ))}
      </div>
    </section>
  );
}
