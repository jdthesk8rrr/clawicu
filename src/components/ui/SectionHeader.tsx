interface SectionHeaderProps {
  badge?: string;
  title: string;
  description?: string;
  centered?: boolean;
}

export function SectionHeader({ badge, title, description, centered = true }: SectionHeaderProps) {
  return (
    <div className={`mb-14 text-center ${centered ? '' : 'text-left'}`}>
      {badge && (
        <span className="mb-4 inline-flex items-center gap-2 rounded-full bg-primary/10 px-4 py-1.5 font-mono text-xs font-medium uppercase tracking-widest text-primary ring-1 ring-primary/20">
          {badge}
        </span>
      )}
      <h2 className="mt-4 font-heading text-3xl font-bold tracking-tight text-[#f0f4ff] sm:text-4xl">
        {title}
      </h2>
      {description && (
        <p className="mx-auto mt-4 max-w-2xl text-base text-[#8892b0]">
          {description}
        </p>
      )}
    </div>
  );
}
