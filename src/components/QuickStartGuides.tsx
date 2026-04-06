"use client";
import { ArrowRight, Terminal, FileText, Wrench, Zap } from "lucide-react";

const guides = [
  {
    icon: Terminal,
    dept: "ER",
    title: "Quick Start",
    description: "Run the rescue command in under 5 minutes",
    href: "/rescue",
    color: "#ff4d4d",
    bg: "rgba(255,77,77,0.08)",
    border: "rgba(255,77,77,0.2)",
    borderHover: "rgba(255,77,77,0.45)",
    room: "Room 01",
  },
  {
    icon: FileText,
    dept: "ICU",
    title: "Documentation",
    description: "Full API reference and configuration guide",
    href: "/docs",
    color: "#00e87a",
    bg: "rgba(0,232,122,0.08)",
    border: "rgba(0,232,122,0.18)",
    borderHover: "rgba(0,232,122,0.4)",
    room: "Room 02",
  },
  {
    icon: Wrench,
    dept: "OT",
    title: "Troubleshooting",
    description: "Common issues and how to resolve them",
    href: "/docs/config-corruption",
    color: "#ffb020",
    bg: "rgba(255,176,32,0.08)",
    border: "rgba(255,176,32,0.2)",
    borderHover: "rgba(255,176,32,0.4)",
    room: "Room 03",
  },
  {
    icon: Zap,
    dept: "ADM",
    title: "Installation",
    description: "npm, Docker, Podman, and source options",
    href: "/download",
    color: "#3b9eff",
    bg: "rgba(59,158,255,0.08)",
    border: "rgba(59,158,255,0.18)",
    borderHover: "rgba(59,158,255,0.4)",
    room: "Room 04",
  },
];

export function QuickStartGuides() {
  return (
    <section className="mx-auto w-full max-w-6xl px-6 py-24">
      {/* Section header */}
      <div className="mb-14 text-center">
        <div className="inline-flex items-center gap-3 mb-5">
          <div className="h-px w-16 bg-gradient-to-r from-transparent to-accent/50" />
          <span className="rounded-md border border-accent/30 bg-accent/10 px-4 py-1.5 font-mono text-xs font-bold uppercase tracking-widest text-accent">
            🏥 Department Directory
          </span>
          <div className="h-px w-16 bg-gradient-to-l from-transparent to-accent/50" />
        </div>
        <h2 className="font-heading text-3xl font-bold tracking-tight text-foreground sm:text-4xl">
          Where do you need to go?
        </h2>
        <p className="mx-auto mt-4 max-w-2xl text-base text-muted-foreground">
          Everything you need to diagnose and fix issues quickly
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-2">
        {guides.map((guide) => {
          const Icon = guide.icon;
          return (
            <a
              key={guide.title}
              href={guide.href}
              className="group relative flex items-center gap-4 overflow-hidden rounded-xl p-5 transition-all duration-300"
              style={{
                background: guide.bg,
                border: `1px solid ${guide.border}`,
              }}
              onMouseEnter={(e) => {
                const el = e.currentTarget as HTMLElement;
                el.style.borderColor = guide.borderHover;
                el.style.boxShadow = `0 0 20px ${guide.bg}`;
                el.style.transform = "translateX(4px)";
              }}
              onMouseLeave={(e) => {
                const el = e.currentTarget as HTMLElement;
                el.style.borderColor = guide.border;
                el.style.boxShadow = "";
                el.style.transform = "";
              }}
            >
              {/* Department code placard */}
              <div
                className="flex h-12 w-12 shrink-0 flex-col items-center justify-center rounded-lg"
                style={{ background: `${guide.color}14`, border: `1px solid ${guide.color}25` }}
              >
                <Icon className="h-5 w-5" style={{ color: guide.color }} />
                <span className="font-mono text-[9px] font-bold uppercase tracking-wider mt-0.5" style={{ color: guide.color }}>
                  {guide.dept}
                </span>
              </div>

              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-0.5">
                  <h3 className="font-heading text-base font-semibold text-foreground">
                    {guide.title}
                  </h3>
                  <span className="font-mono text-[10px] text-muted-foreground/50">{guide.room}</span>
                </div>
                <p className="text-sm text-muted-foreground">
                  {guide.description}
                </p>
              </div>

              <ArrowRight
                className="h-5 w-5 shrink-0 text-muted-foreground/40 transition-all group-hover:translate-x-1 group-hover:opacity-100"
                style={{ color: guide.color }}
              />

              {/* Left accent strip */}
              <div
                className="absolute left-0 top-0 bottom-0 w-0.5 rounded-l-xl opacity-0 group-hover:opacity-100 transition-opacity"
                style={{ background: `linear-gradient(180deg, transparent, ${guide.color}, transparent)` }}
              />
            </a>
          );
        })}
      </div>
    </section>
  );
}
