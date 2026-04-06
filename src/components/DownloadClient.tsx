"use client";

import { useState } from "react";
import {
  Download, Copy, Check, Terminal, Github,
  Syringe, ShieldCheck, HeartPulse,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useOSDetector, type OS } from "@/components/OSDetector";

const VERSION = "v0.2.0";
const RELEASE_DATE = "2026-04-06";

const downloadData: Record<OS, { label: string; file: string; size: string }> = {
  macos: { label: "macOS",  file: "rescue.sh", size: "~15 KB" },
  linux: { label: "Linux",  file: "rescue.sh", size: "~15 KB" },
};

const installCommand = "curl -fsSL https://xagent.icu/r | sh";

function CopyButton({ text, invert = false }: { text: string; invert?: boolean }) {
  const [copied, setCopied] = useState(false);
  const copy = async () => {
    await navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };
  return (
    <button
      onClick={copy}
      className={cn(
        "flex h-8 w-8 shrink-0 items-center justify-center rounded-lg transition-all",
        invert
          ? copied
            ? "bg-[rgba(0,232,122,0.2)] text-[#00e87a]"
            : "bg-[rgba(0,232,122,0.05)] text-[#00e87a]/50 hover:bg-[rgba(0,232,122,0.12)] hover:text-[#00e87a]"
          : copied
            ? "bg-success/20 text-success"
            : "bg-foreground/5 text-muted-foreground hover:bg-foreground/10 hover:text-foreground"
      )}
      aria-label="Copy to clipboard"
    >
      {copied ? <Check className="h-4 w-4" /> : <Copy className="h-4 w-4" />}
    </button>
  );
}

/* ICU-styled terminal command block */
function ICUTerminal({ command }: { command: string }) {
  return (
    <div className="relative overflow-hidden rounded-xl border border-[rgba(0,232,122,0.2)] bg-[#020a06]">
      <div className="flex h-9 items-center justify-between border-b border-[rgba(0,232,122,0.15)] bg-[rgba(0,232,122,0.04)] px-4">
        <div className="flex items-center gap-2">
          <span className="h-2 w-2 rounded-full bg-[#00e87a] animate-vital-blink" />
          <span className="font-mono text-[10px] font-bold uppercase tracking-widest text-[#00e87a]/70">
            ICU Terminal
          </span>
        </div>
      </div>
      <div className="flex items-center gap-3 px-5 py-4">
        <span className="select-none font-mono text-sm text-[#00e87a]/50">$</span>
        <code className="flex-1 overflow-x-auto font-mono text-sm text-[#c8ffd4]">{command}</code>
        <CopyButton text={command} invert />
      </div>
    </div>
  );
}

export function DownloadClient() {
  const detectedOs = useOSDetector();
  const [selectedOs, setSelectedOs] = useState<OS>(detectedOs);
  const data = downloadData[selectedOs];

  return (
    <>
      {/* Hero — Prescription Pad Style */}
      <section className="relative flex flex-col items-center px-6 pb-8 pt-32 overflow-hidden">
        <div className="pointer-events-none absolute inset-0">
          <div className="absolute left-1/2 top-0 h-[500px] w-[800px] -translate-x-1/2 -translate-y-1/3 rounded-full bg-primary/[0.07] blur-[140px]" />
          <div className="absolute right-0 top-1/4 h-[300px] w-[400px] rounded-full bg-[rgba(0,232,122,0.04)] blur-[100px]" />
        </div>

        <div className="relative z-10 flex max-w-4xl flex-col items-center text-center">
          {/* Rx symbol badge */}
          <div className="animate-fade-up mb-6 flex items-center gap-3">
            <span className="rounded-full border border-primary/30 bg-primary/10 px-5 py-2 font-mono text-sm font-bold tracking-widest text-primary">
              ℞ PRESCRIPTION
            </span>
          </div>

          <h1 className="animate-fade-up font-heading text-5xl font-extrabold tracking-tighter text-foreground sm:text-6xl md:text-7xl">
            Get{" "}
            <span className="bg-gradient-to-r from-primary via-accent to-[#00e87a] bg-clip-text text-transparent">
              ClawICU
            </span>
          </h1>

          <p className="animate-fade-up mt-4 max-w-xl text-base leading-relaxed text-muted-foreground sm:text-lg">
            Prescribed dose: one command. No dependencies beyond curl and sh.
          </p>

          <div className="animate-fade-up mt-3 flex items-center gap-3">
            <span className="font-mono text-xs text-muted-foreground/50">
              {VERSION} — {RELEASE_DATE}
            </span>
            <span className="h-1 w-1 rounded-full bg-muted-foreground/30" />
            <span className="flex items-center gap-1.5 font-mono text-xs text-[#00e87a]/70">
              <HeartPulse className="h-3 w-3 animate-heartbeat" />
              Stable Release
            </span>
          </div>

          {/* Trust badges */}
          <div className="animate-fade-up mt-8 flex flex-wrap items-center justify-center gap-3" style={{ animationDelay: "0.2s" }}>
            {[
              { icon: ShieldCheck, label: "MIT Licensed",    color: "#00e87a" },
              { icon: Syringe,     label: "Zero Tracking",   color: "#ff4d4d" },
              { icon: Terminal,    label: "POSIX sh · curl",  color: "#3b9eff" },
            ].map((b) => (
              <div
                key={b.label}
                className="flex items-center gap-1.5 rounded-full px-3 py-1.5 font-mono text-xs"
                style={{ background: `${b.color}10`, border: `1px solid ${b.color}25`, color: b.color }}
              >
                <b.icon className="h-3 w-3" />
                {b.label}
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Download cards */}
      <section className="mx-auto w-full max-w-5xl px-6 pb-8">
        {/* OS selector */}
        <div className="animate-fade-up mb-8 flex items-center gap-1.5 rounded-2xl border border-border bg-card backdrop-blur-[12px] p-1.5">
          {(Object.keys(downloadData) as OS[]).map((os) => {
            const isActive = os === selectedOs;
            return (
              <button
                key={os}
                onClick={() => setSelectedOs(os)}
                className={cn(
                  "flex flex-1 items-center justify-center gap-2 rounded-xl px-6 py-3 text-sm font-semibold transition-all duration-200",
                  isActive
                    ? "bg-primary/15 text-foreground ring-1 ring-primary/30"
                    : "text-muted-foreground hover:text-foreground hover:bg-foreground/5"
                )}
              >
                {downloadData[os].label}
                {os === detectedOs && (
                  <span className="ml-1 rounded-full bg-primary/10 px-2 py-0.5 font-mono text-[10px] uppercase tracking-wider text-primary">
                    detected
                  </span>
                )}
              </button>
            );
          })}
        </div>

        <div className="grid gap-6 lg:grid-cols-2">
          {/* Direct download card — prescription pad style */}
          <div className="relative overflow-hidden rounded-2xl border border-border/60 bg-card backdrop-blur-[12px] transition-all duration-300 hover:border-primary/40 hover:-translate-y-1 hover:shadow-[0_0_30px_rgba(255,77,77,0.1)]">
            {/* Rx corner watermark */}
            <div className="absolute right-4 top-3 font-heading text-4xl font-black text-primary/5 select-none">
              Rx
            </div>

            {/* Prescription header stripe */}
            <div className="border-b border-border/40 bg-primary/5 px-6 py-3 flex items-center gap-2">
              <Download className="h-4 w-4 text-primary" />
              <span className="font-mono text-xs font-bold uppercase tracking-wider text-primary/80">
                Direct Download
              </span>
              <span className="ml-auto font-mono text-xs text-muted-foreground/50">
                {data.size} · {data.label} · {VERSION}
              </span>
            </div>

            <div className="p-6">
              <a
                href="https://xagent.icu/rescue.sh"
                className="flex w-full items-center justify-center gap-2.5 rounded-xl bg-primary px-6 py-3.5 text-sm font-semibold text-primary-foreground transition-all hover:bg-primary/90 hover:shadow-[0_0_24px_rgba(255,77,77,0.3)] hover:-translate-y-0.5"
              >
                <Download className="h-4 w-4" />
                Download {data.file}
              </a>

              <div className="mt-4 rounded-lg border border-border/40 bg-surface/40 p-4">
                <p className="font-mono text-[10px] font-bold uppercase tracking-wider text-muted-foreground mb-2">
                  Checksum Verification
                </p>
                <div className="flex items-center gap-2">
                  <code className="flex-1 break-all font-mono text-xs text-muted-foreground">
                    shasum -a 256 rescue.sh
                  </code>
                  <CopyButton text="shasum -a 256 rescue.sh" />
                </div>
              </div>
            </div>
          </div>

          {/* Quick install — ICU terminal card */}
          <div className="relative overflow-hidden rounded-2xl border border-[rgba(0,232,122,0.2)] bg-card backdrop-blur-[12px] transition-all duration-300 hover:border-[rgba(0,232,122,0.4)] hover:-translate-y-1 hover:shadow-[0_0_30px_rgba(0,232,122,0.08)]">
            <div className="border-b border-[rgba(0,232,122,0.15)] bg-[rgba(0,232,122,0.04)] px-6 py-3 flex items-center gap-2">
              <Terminal className="h-4 w-4 text-[#00e87a]" />
              <span className="font-mono text-xs font-bold uppercase tracking-wider text-[#00e87a]/80">
                Quick Install
              </span>
              <span className="ml-auto font-mono text-xs text-muted-foreground/50">
                via curl
              </span>
            </div>

            <div className="p-6">
              <ICUTerminal command={installCommand} />
              <p className="mt-4 text-xs text-muted-foreground leading-relaxed">
                Downloads and executes the rescue script in a single step.
                Script is verified open-source — always review before running.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Build from Source */}
      <section className="mx-auto w-full max-w-5xl px-6 py-16">
        <div className="mb-10 text-center">
          <div className="inline-flex items-center gap-3 mb-5">
            <div className="h-px w-12 bg-gradient-to-r from-transparent to-accent/50" />
            <span className="rounded-md border border-accent/30 bg-accent/10 px-4 py-1.5 font-mono text-xs font-bold uppercase tracking-widest text-accent">
              Source
            </span>
            <div className="h-px w-12 bg-gradient-to-l from-transparent to-accent/50" />
          </div>
          <h2 className="font-heading text-3xl font-bold tracking-tight text-foreground sm:text-4xl">
            Build from Source
          </h2>
          <p className="mx-auto mt-4 max-w-2xl text-base text-muted-foreground">
            Clone the repository and run the rescue script directly.
          </p>
        </div>

        <div className="flex items-center justify-center">
          <div className="group relative overflow-hidden rounded-2xl border border-border bg-card backdrop-blur-[12px] p-6 transition-all duration-300 hover:border-accent/40 hover:shadow-[0_0_30px_rgba(0,229,204,0.1)]">
            <div className="relative flex items-center gap-4">
              <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-accent/10 text-accent ring-1 ring-accent/20">
                <Github className="h-6 w-6" />
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-2">
                  <code className="rounded-lg border border-border/50 bg-terminal px-3 py-2 font-mono text-sm text-foreground/80">
                    git clone https://github.com/SonicBotMan/clawicu.git
                  </code>
                  <CopyButton text="git clone https://github.com/SonicBotMan/clawicu.git" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </>
  );
}
