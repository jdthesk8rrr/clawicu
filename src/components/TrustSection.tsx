import { Github, Shield, Heart, ExternalLink } from "lucide-react";

export function TrustSection() {
  return (
    <section className="mx-auto w-full max-w-6xl px-6 py-16">
      <div className="rounded-2xl border border-border/50 bg-card/30 p-6 text-center backdrop-blur-[8px]">
        <div className="flex flex-wrap items-center justify-center gap-6">
          <a
            href="https://github.com/SonicBotMan/clawicu"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-2 text-muted-foreground transition-colors hover:text-foreground"
          >
            <Github className="h-5 w-5" />
            <span className="font-semibold text-foreground">1.2k+ Stars</span>
            <span>on GitHub</span>
            <ExternalLink className="h-3 w-3 opacity-50" />
          </a>
          
          <div className="h-6 w-px bg-border" />
          
          <div className="flex items-center gap-2 text-muted-foreground">
            <Shield className="h-5 w-5 text-accent" />
            <span>MIT License</span>
          </div>
          
          <div className="h-6 w-px bg-border" />
          
          <div className="flex items-center gap-2 text-muted-foreground">
            <Heart className="h-5 w-5 text-primary" />
            <span>100% Open Source</span>
          </div>
        </div>
        
        <p className="mt-4 text-sm text-muted-foreground">
          Free forever. No tracking. No paid upgrades required.
        </p>
      </div>
    </section>
  );
}
