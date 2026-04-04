import { BookOpen, ArrowRight, Terminal, FileText, Wrench, Zap } from "lucide-react";
import { SectionHeader } from "@/components/ui/SectionHeader";

const guides = [
  {
    icon: Terminal,
    title: "Quick Start",
    description: "Run the rescue command in under 5 minutes",
    href: "/rescue",
  },
  {
    icon: FileText,
    title: "Documentation",
    description: "Full API reference and configuration guide",
    href: "/docs",
  },
  {
    icon: Wrench,
    title: "Troubleshooting",
    description: "Common issues and how to resolve them",
    href: "/docs/config-corruption",
  },
  {
    icon: Zap,
    title: "Installation",
    description: "npm, Docker, Podman, and source options",
    href: "/download",
  },
];

export function QuickStartGuides() {
  return (
    <section className="mx-auto w-full max-w-6xl px-6 py-24">
      <SectionHeader
        badge="Get Started"
        title="Ready to Rescue Your OpenClaw?"
        description="Everything you need to diagnose and fix issues quickly"
      />
      
      <div className="grid gap-4 sm:grid-cols-2">
        {guides.map((guide) => (
          <a
            key={guide.title}
            href={guide.href}
            className="group flex items-start gap-4 rounded-2xl border border-border bg-card/40 p-5 backdrop-blur-[8px] transition-all hover:border-primary/30 hover:bg-card/60"
          >
            <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary ring-1 ring-primary/20">
              <guide.icon className="h-5 w-5" />
            </div>
            <div className="flex-1">
              <h3 className="font-heading text-base font-semibold text-foreground group-hover:text-primary transition-colors">
                {guide.title}
              </h3>
              <p className="mt-1 text-sm text-muted-foreground">
                {guide.description}
              </p>
            </div>
            <ArrowRight className="h-5 w-5 shrink-0 text-muted-foreground opacity-0 transition-opacity group-hover:opacity-100" />
          </a>
        ))}
      </div>
    </section>
  );
}
