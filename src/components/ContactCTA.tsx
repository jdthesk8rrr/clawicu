import { Github, MessageCircle } from "lucide-react";

export function ContactCTA() {
  return (
    <section className="mx-auto w-full max-w-6xl px-6 py-16">
      <div className="relative overflow-hidden rounded-3xl border border-border/50 bg-gradient-to-br from-card/80 to-card/40 p-8 text-center backdrop-blur-[12px] sm:p-12">
        <div className="relative z-10">
          <h2 className="font-heading text-3xl font-bold text-foreground sm:text-4xl">
            Need Help?
          </h2>
          <p className="mx-auto mt-4 max-w-xl text-base text-muted-foreground">
            ClawICU is open source. Check the documentation or open an issue on GitHub.
          </p>
          <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
            <a
              href="https://github.com/SonicBotMan/clawicu/issues"
              className="flex items-center gap-2.5 rounded-xl bg-primary px-7 py-3.5 text-sm font-semibold text-primary-foreground shadow-lg shadow-primary/20 transition-all hover:bg-primary/90 hover:shadow-xl hover:shadow-primary/30"
              target="_blank"
              rel="noopener noreferrer"
            >
              <Github className="h-4 w-4" />
              Open an Issue
            </a>
            <a
              href="/docs"
              className="flex items-center gap-2.5 rounded-xl border border-border/50 bg-card/60 px-7 py-3.5 text-sm font-semibold text-foreground backdrop-blur-sm transition-all hover:border-accent/30 hover:bg-card/80"
            >
              <MessageCircle className="h-4 w-4 text-accent" />
              Read Docs
            </a>
          </div>
        </div>
        
        <div className="pointer-events-none absolute -right-20 -top-20 h-64 w-64 rounded-full bg-primary/5 blur-3xl" />
        <div className="pointer-events-none absolute -bottom-20 -left-20 h-64 w-64 rounded-full bg-accent/5 blur-3xl" />
      </div>
    </section>
  );
}
