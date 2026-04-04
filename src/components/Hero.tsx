"use client";
import { Apple, Terminal, ChevronDown } from "lucide-react";
import { TerminalBlock } from "@/components/ui/TerminalBlock";
import { ECGLine } from "@/components/effects/ECGLine";
import { GridBackground, StarfieldBackground } from "@/components/effects";
import { useEffect, useState } from "react";

export function Hero() {
  const [mounted, setMounted] = useState(false);
  useEffect(() => setMounted(true), []);

  return (
    <section className="relative flex min-h-screen flex-col items-center justify-center overflow-hidden px-6 pb-12 pt-28">
      <GridBackground />
      <StarfieldBackground />
      
      <div className="pointer-events-none absolute bottom-0 left-0 right-0 h-32 bg-gradient-to-t from-background to-transparent" />
      
      <div className="relative z-10 flex max-w-5xl flex-col items-center text-center">
        <div
          className="animate-fade-up mb-6 inline-flex items-center gap-2 rounded-full border border-border/30 bg-surface/60 px-4 py-1.5 font-mono text-xs text-muted-foreground backdrop-blur-sm"
        >
          <span className="inline-block h-1.5 w-1.5 rounded-full bg-success animate-pulse" />
          Open Source &middot; Free Forever &middot; MIT License
        </div>

        <h1
          className="animate-fade-up font-heading text-6xl font-extrabold tracking-tighter text-foreground sm:text-7xl md:text-8xl lg:text-9xl"
          style={{ animationDelay: "0.1s" }}
        >
          Claw
          <span 
            className="bg-clip-text text-transparent"
            style={{
              backgroundImage: "linear-gradient(90deg, #00e5cc, #ff4d4d, #00e5cc)",
              backgroundSize: "200% 200%",
              animation: "gradient-shift 6s ease-in-out infinite",
            }}
          >
            ICU
          </span>
        </h1>

        <p
          className="animate-fade-up mt-4 font-heading text-xl font-medium tracking-wide text-[#8892b0] sm:text-2xl"
          style={{ animationDelay: "0.2s" }}
        >
          OpenClaw Emergency Rescue System
        </p>

        <div className="animate-fade-up mt-6 w-full max-w-2xl opacity-60" style={{ animationDelay: "0.25s" }}>
          <ECGLine className="h-8" />
        </div>

        <p
          className="animate-fade-up mt-6 max-w-2xl text-base leading-relaxed text-muted-foreground sm:text-lg"
          style={{ animationDelay: "0.3s" }}
        >
          Diagnose failures, stabilize processes, and revive your OpenClaw instance — 
          all from one command. Supports npm, Docker, Podman, and source installations.
        </p>

        <div className="animate-fade-up mt-8 w-full max-w-xl" style={{ animationDelay: "0.4s" }}>
          <TerminalBlock
            command="curl -fsSL https://xagent.icu/r | sh"
          />
        </div>

        <div
          className="animate-fade-up mt-10 flex flex-wrap items-center justify-center gap-4"
          style={{ animationDelay: "0.5s" }}
        >
          <a
            href="#download"
            className="group flex items-center gap-2.5 rounded-xl border border-border/30 bg-surface/80 px-6 py-3 text-sm font-semibold text-foreground backdrop-blur-sm transition-all hover:border-primary/30 hover:bg-surface hover:shadow-[0_0_30px_rgba(255,77,77,0.15)]"
          >
            <Apple className="h-4 w-4 text-muted-foreground transition-colors group-hover:text-foreground" />
            Download for macOS
          </a>
          <a
            href="#download"
            className="group flex items-center gap-2.5 rounded-xl border border-border/30 bg-surface/80 px-6 py-3 text-sm font-semibold text-foreground backdrop-blur-sm transition-all hover:border-accent/30 hover:bg-surface hover:shadow-[0_0_30px_rgba(0,229,204,0.15)]"
          >
            <Terminal className="h-4 w-4 text-muted-foreground transition-colors group-hover:text-foreground" />
            Download for Linux
          </a>
        </div>

        <div
          className="animate-fade-up mt-16 flex items-center gap-12 text-center"
          style={{ animationDelay: "0.6s" }}
        >
          {[
            { value: "17", label: "Diagnostic Checks" },
            { value: "12", label: "Repair Modules" },
            { value: "1", label: "Rescue Command" },
          ].map((stat) => (
            <div key={stat.label} className="flex flex-col">
              <span className="font-heading text-3xl font-bold text-foreground sm:text-4xl">
                {stat.value}
              </span>
              <span className="mt-1 text-xs text-muted-foreground sm:text-sm">
                {stat.label}
              </span>
            </div>
          ))}
        </div>
      </div>

      <div className="absolute bottom-8 left-1/2 -translate-x-1/2 animate-bounce">
        <ChevronDown className="h-5 w-5 text-muted-foreground" />
      </div>
    </section>
  );
}
