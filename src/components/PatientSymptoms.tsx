"use client";
import { FileWarning, Puzzle, Wifi, Cpu, KeyRound, Network } from "lucide-react";
import { IssueCard } from "./IssueCard";
import type { LucideIcon } from "lucide-react";

interface Symptom {
  icon: LucideIcon;
  title: string;
  severity: "critical" | "warning" | "info";
  description: string;
}

const symptoms: Symptom[] = [
  {
    icon: FileWarning,
    title: "Config Corruption",
    severity: "critical",
    description: "Configuration file has invalid JSON5 syntax or is corrupted",
  },
  {
    icon: Puzzle,
    title: "Plugin Failure",
    severity: "warning",
    description: "Plugin manifests broken or plugins failing to load",
  },
  {
    icon: Wifi,
    title: "Gateway Offline",
    severity: "critical",
    description: "Gateway not running on port 18789",
  },
  {
    icon: Cpu,
    title: "Daemon Unresponsive",
    severity: "warning",
    description: "launchd/systemd service not properly installed",
  },
  {
    icon: KeyRound,
    title: "Auth Failure",
    severity: "critical",
    description: "Provider API keys missing or authentication failures",
  },
  {
    icon: Network,
    title: "Port Conflict",
    severity: "warning",
    description: "Port 18789 is occupied by another process",
  },
];

export function PatientSymptoms() {
  return (
    <section className="mx-auto w-full max-w-6xl px-6 py-24">
      <div className="mb-14 text-center">
        <span className="mb-4 inline-block rounded-full bg-primary/10 px-4 py-1.5 font-mono text-xs font-medium uppercase tracking-widest text-primary ring-1 ring-primary/20">
          Patient Symptoms
        </span>
        <h2 className="mt-4 font-heading text-3xl font-bold tracking-tight text-foreground sm:text-4xl">
          Common Diagnoses
        </h2>
        <p className="mx-auto mt-4 max-w-2xl text-base text-muted-foreground">
          When OpenClaw exhibits these symptoms, ClawICU provides the diagnosis and treatment plan.
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {symptoms.map((symptom, i) => (
          <div key={symptom.title} className="reveal" style={{ transitionDelay: `${i * 80}ms` }}>
            <IssueCard
              icon={symptom.icon}
              title={symptom.title}
              description={symptom.description}
              severity={symptom.severity}
              delay={0.6 + i * 0.08}
            />
          </div>
        ))}
      </div>
    </section>
  );
}
