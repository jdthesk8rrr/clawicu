"use client";
import { LucideIcon } from "lucide-react";
import { cn } from "@/lib/utils";

interface IssueCardProps {
  icon: LucideIcon;
  title: string;
  description: string;
  severity?: "critical" | "warning" | "info";
  delay?: number;
  code?: string;
}

const severityConfig = {
  critical: {
    label: "CRITICAL",
    badgeClass: "badge-critical",
    iconBg: "rgba(255,45,45,0.1)",
    iconBorder: "rgba(255,45,45,0.25)",
    iconColor: "#ff6060",
    glow: "rgba(255,45,45,0.12)",
    borderHover: "rgba(255,45,45,0.4)",
    dotClass: "bg-[#ff2d2d] animate-vital-blink",
    lineColor: "rgba(255,45,45,0.3)",
  },
  warning: {
    label: "WARNING",
    badgeClass: "badge-warning",
    iconBg: "rgba(255,176,32,0.1)",
    iconBorder: "rgba(255,176,32,0.25)",
    iconColor: "#ffb020",
    glow: "rgba(255,176,32,0.1)",
    borderHover: "rgba(255,176,32,0.4)",
    dotClass: "bg-[#ffb020]",
    lineColor: "rgba(255,176,32,0.25)",
  },
  info: {
    label: "INFO",
    badgeClass: "badge-stable",
    iconBg: "rgba(0,232,122,0.1)",
    iconBorder: "rgba(0,232,122,0.2)",
    iconColor: "#00e87a",
    glow: "rgba(0,232,122,0.08)",
    borderHover: "rgba(0,232,122,0.3)",
    dotClass: "bg-[#00e87a]",
    lineColor: "rgba(0,232,122,0.2)",
  },
};

export function IssueCard({ icon: Icon, title, description, severity = "warning", delay = 0, code }: IssueCardProps) {
  const cfg = severityConfig[severity];

  return (
    <div
      className={cn(
        "group relative overflow-hidden rounded-xl border border-border/50 bg-card/50 backdrop-blur-[12px] p-5",
        "transition-all duration-300 cursor-default",
        "animate-fade-up"
      )}
      style={{
        animationDelay: `${delay}s`,
        transition: "all 0.3s ease",
      }}
      onMouseEnter={(e) => {
        const el = e.currentTarget as HTMLElement;
        el.style.borderColor = cfg.borderHover;
        el.style.boxShadow = `0 0 24px ${cfg.glow}`;
        el.style.transform = "translateY(-2px)";
      }}
      onMouseLeave={(e) => {
        const el = e.currentTarget as HTMLElement;
        el.style.borderColor = "";
        el.style.boxShadow = "";
        el.style.transform = "";
      }}
    >
      {/* Top-right: severity badge + optional code */}
      <div className="mb-4 flex items-center justify-between">
        <span className={cn("inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 font-mono text-[10px] font-bold uppercase tracking-wider", cfg.badgeClass)}>
          <span className={cn("h-1.5 w-1.5 rounded-full", cfg.dotClass)} />
          {cfg.label}
        </span>
        {code && (
          <span className="font-mono text-[10px] text-muted-foreground/50">{code}</span>
        )}
      </div>

      {/* Icon */}
      <div
        className="mb-3 flex h-10 w-10 items-center justify-center rounded-lg"
        style={{ background: cfg.iconBg, border: `1px solid ${cfg.iconBorder}` }}
      >
        <Icon className="h-5 w-5" style={{ color: cfg.iconColor }} />
      </div>

      <h3 className="mb-1.5 font-heading text-base font-semibold text-foreground">
        {title}
      </h3>
      <p className="text-sm text-muted-foreground leading-relaxed">
        {description}
      </p>

      {/* Bottom accent line */}
      <div
        className="absolute bottom-0 left-0 right-0 h-px opacity-0 group-hover:opacity-100 transition-opacity"
        style={{ background: `linear-gradient(90deg, transparent, ${cfg.lineColor}, transparent)` }}
      />
    </div>
  );
}
