"use client";
import { Github, Shield, HeartPulse, ExternalLink, Star, GitFork } from "lucide-react";
import { useEffect, useRef, useState } from "react";

function Counter({ target, suffix = "" }: { target: number; suffix?: string }) {
  const [count, setCount] = useState(0);
  const ref = useRef<HTMLSpanElement>(null);
  const started = useRef(false);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting && !started.current) {
          started.current = true;
          const duration = 1200;
          const startTime = performance.now();
          const tick = (now: number) => {
            const elapsed = now - startTime;
            const progress = Math.min(elapsed / duration, 1);
            const eased = 1 - Math.pow(1 - progress, 3);
            setCount(Math.floor(eased * target));
            if (progress < 1) requestAnimationFrame(tick);
            else setCount(target);
          };
          requestAnimationFrame(tick);
        }
      },
      { threshold: 0.5 }
    );
    if (ref.current) observer.observe(ref.current);
    return () => observer.disconnect();
  }, [target]);

  return <span ref={ref}>{count}{suffix}</span>;
}

const certifications = [
  {
    icon: Shield,
    label: "MIT Licensed",
    sub: "Certified Open",
    color: "#00e87a",
    bg: "rgba(0,232,122,0.08)",
    border: "rgba(0,232,122,0.2)",
  },
  {
    icon: HeartPulse,
    label: "Zero Tracking",
    sub: "Privacy First",
    color: "#ff4d4d",
    bg: "rgba(255,77,77,0.08)",
    border: "rgba(255,77,77,0.2)",
  },
  {
    icon: Github,
    label: "Open Source",
    sub: "Public Code",
    color: "#3b9eff",
    bg: "rgba(59,158,255,0.08)",
    border: "rgba(59,158,255,0.2)",
  },
];

const stats = [
  { value: 20,  suffix: "",  label: "Diagnostic Checks" },
  { value: 12,  suffix: "",  label: "Repair Modules" },
  { value: 25,  suffix: "",  label: "Issue Guides" },
  { value: 100, suffix: "%", label: "Free Forever" },
];

export function TrustSection() {
  return (
    <section className="mx-auto w-full max-w-6xl px-6 py-16">
      <div className="relative overflow-hidden rounded-2xl border border-border/40 bg-card/40 backdrop-blur-[12px]">

        {/* Subtle top accent line */}
        <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-[#00e87a]/40 to-transparent" />

        <div className="p-8">
          {/* Stats row */}
          <div className="mb-8 grid grid-cols-2 gap-4 sm:grid-cols-4">
            {stats.map((stat) => (
              <div key={stat.label} className="flex flex-col items-center text-center">
                <span className="font-heading text-2xl font-black text-foreground sm:text-3xl">
                  <Counter target={stat.value} suffix={stat.suffix} />
                </span>
                <span className="mt-1 text-xs text-muted-foreground">{stat.label}</span>
              </div>
            ))}
          </div>

          <div className="h-px bg-border/30 mb-6" />

          {/* Certification badges */}
          <div className="flex flex-wrap items-center justify-center gap-3">
            {certifications.map((cert) => {
              const Icon = cert.icon;
              return (
                <div
                  key={cert.label}
                  className="flex items-center gap-2.5 rounded-lg px-4 py-2.5"
                  style={{ background: cert.bg, border: `1px solid ${cert.border}` }}
                >
                  <Icon className="h-4 w-4 shrink-0" style={{ color: cert.color }} />
                  <div className="leading-tight">
                    <div className="text-sm font-semibold text-foreground">{cert.label}</div>
                    <div className="font-mono text-[10px] uppercase tracking-wider" style={{ color: cert.color }}>
                      {cert.sub}
                    </div>
                  </div>
                </div>
              );
            })}

            <div className="mx-2 h-8 w-px bg-border/40 hidden sm:block" />

            <a
              href="https://github.com/SonicBotMan/clawicu"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-2 rounded-lg border border-border/40 bg-card/60 px-4 py-2.5 text-sm text-muted-foreground transition-all hover:border-border hover:text-foreground"
            >
              <Github className="h-4 w-4" />
              <span>View on GitHub</span>
              <ExternalLink className="h-3 w-3 opacity-50" />
            </a>
          </div>
        </div>

        <div className="absolute inset-x-0 bottom-0 h-px bg-gradient-to-r from-transparent via-primary/30 to-transparent" />
      </div>
    </section>
  );
}
