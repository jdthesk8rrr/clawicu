interface SectionHeaderProps {
  badge?: string;
  title: string;
  description?: string;
  centered?: boolean;
  accentColor?: "primary" | "accent" | "green";
}

const accentMap = {
  primary: {
    badge: "border-primary/30 bg-primary/10 text-primary",
    line: "via-primary/50",
  },
  accent: {
    badge: "border-accent/30 bg-accent/10 text-accent",
    line: "via-accent/50",
  },
  green: {
    badge: "border-[rgba(0,232,122,0.3)] bg-[rgba(0,232,122,0.08)] text-[#00e87a]",
    line: "via-[rgba(0,232,122,0.4)]",
  },
};

export function SectionHeader({
  badge,
  title,
  description,
  centered = true,
  accentColor = "primary",
}: SectionHeaderProps) {
  const ac = accentMap[accentColor];

  return (
    <div className={`mb-14 ${centered ? "text-center" : "text-left"}`}>
      {badge && (
        <div className={`mb-5 ${centered ? "flex items-center justify-center gap-3" : "flex items-center gap-3"}`}>
          <div className={`h-px w-12 bg-gradient-to-r from-transparent ${ac.line}`} />
          <span className={`rounded-md border px-4 py-1.5 font-mono text-xs font-bold uppercase tracking-widest ${ac.badge}`}>
            {badge}
          </span>
          <div className={`h-px w-12 bg-gradient-to-l from-transparent ${ac.line}`} />
        </div>
      )}
      <h2 className="mt-2 font-heading text-3xl font-bold tracking-tight text-foreground sm:text-4xl">
        {title}
      </h2>
      {description && (
        <p className="mx-auto mt-4 max-w-2xl text-base text-muted-foreground">
          {description}
        </p>
      )}
    </div>
  );
}
