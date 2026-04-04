"use client";
import { Search, Shield, Wrench, RefreshCcw } from "lucide-react";
import { SectionHeader } from "@/components/ui/SectionHeader";

const steps = [
  {
    icon: Search,
    title: "Detect",
    description: "Automatically identifies your OS, installation method, and running processes",
    color: "text-primary",
  },
  {
    icon: Shield,
    title: "Diagnose",
    description: "Runs 17 diagnostic checks to pinpoint configuration, network, and credential issues",
    color: "text-accent",
  },
  {
    icon: Wrench,
    title: "Repair",
    description: "Applies targeted fixes with automatic backup and rollback safety",
    color: "text-primary",
  },
  {
    icon: RefreshCcw,
    title: "Verify",
    description: "Confirms successful repair and ensures OpenClaw is fully operational",
    color: "text-success",
  },
];

export function HowItWorks() {
  return (
    <section className="relative mx-auto w-full max-w-[860px] px-6 py-24">
      <SectionHeader
        badge="How It Works"
        title="Four Steps to Rescue"
        description="From one command to full diagnosis — ClawICU follows a battle-tested process"
      />
      
      <div className="grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
        {steps.map((step, i) => (
          <div
            key={step.title}
            className="reveal group relative rounded-2xl border border-border bg-card backdrop-blur-[12px] p-6 transition-all duration-300 hover:border-primary/30"
            style={{ transitionDelay: `${i * 100}ms` }}
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
            <div className="absolute -top-3 left-6 rounded-full bg-background px-2 font-mono text-xs text-[#8892b0]">
              Step {i + 1}
            </div>
            
            <step.icon className={`h-8 w-8 ${step.color} mb-4`} />
            <h3 className="mb-2 font-heading text-lg font-semibold text-foreground">
              {step.title}
            </h3>
            <p className="text-sm text-muted-foreground leading-relaxed">
              {step.description}
            </p>
          </div>
        ))}
      </div>
    </section>
  );
}
