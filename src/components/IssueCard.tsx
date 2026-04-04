"use client";
import { LucideIcon } from "lucide-react";
import { cn } from "@/lib/utils";

interface IssueCardProps {
  icon: LucideIcon;
  title: string;
  description: string;
  severity?: "critical" | "warning" | "info";
  delay?: number;
}

const severityConfig = {
  critical: { color: "text-primary", label: "Critical", bg: "bg-primary/10", ring: "ring-primary/20" },
  warning: { color: "text-yellow-500", label: "Warning", bg: "bg-yellow-500/10", ring: "ring-yellow-500/20" },
  info: { color: "text-accent", label: "Info", bg: "bg-accent/10", ring: "ring-accent/20" },
};

export function IssueCard({ icon: Icon, title, description, severity = "warning", delay = 0 }: IssueCardProps) {
  const config = severityConfig[severity];
  
  return (
    <div
      className={cn(
        "group relative overflow-hidden rounded-xl border border-border bg-card backdrop-blur-[12px] p-5 transition-all duration-500",
        "hover:-translate-y-1 hover:shadow-[0_0_30px_rgba(255,77,77,0.15)]",
        "animate-fade-up"
      )}
      style={{ animationDelay: `${delay}s` }}
      onMouseMove={(e) => {
        const rect = e.currentTarget.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        const centerX = rect.width / 2;
        const centerY = rect.height / 2;
        const rotateX = (y - centerY) / 20;
        const rotateY = (centerX - x) / 20;
        e.currentTarget.style.transform = `perspective(800px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) translateY(-1px)`;
      }}
      onMouseLeave={(e) => {
        e.currentTarget.style.transform = "perspective(800px) rotateX(0) rotateY(0) translateY(0)";
      }}
    >
      <div className="absolute inset-0 bg-gradient-to-br from-primary/[0.05] to-transparent opacity-0 transition-opacity duration-500 group-hover:opacity-100" />
      
      <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-primary/50 to-transparent opacity-0 transition-opacity duration-300 group-hover:opacity-100" />
      
      <div className="relative z-10">
        <div className="mb-3 flex items-start justify-between">
          <div className={cn("flex h-10 w-10 items-center justify-center rounded-lg ring-1 transition-all group-hover:shadow-[0_0_20px_rgba(255,77,77,0.2)]", config.bg, config.ring)}>
            <Icon className={cn("h-5 w-5", config.color)} />
          </div>
          <span className={cn("rounded px-2 py-0.5 font-mono text-xs", config.bg, config.color)}>
            {config.label}
          </span>
        </div>
        <h3 className="mb-1.5 font-heading text-base font-semibold text-[#f0f4ff]">
          {title}
        </h3>
        <p className="text-sm text-[#8892b0] leading-relaxed">
          {description}
        </p>
      </div>
    </div>
  );
}
