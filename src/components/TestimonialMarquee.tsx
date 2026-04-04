const testimonials = [
  { text: "ClawICU saved me hours of debugging when my OpenClaw gateway crashed.", author: "DevOps Lead" },
  { text: "The automated diagnostics caught a config issue I would have missed.", author: "Systems Engineer" },
  { text: "One command to fix everything. Incredible tool.", author: "Backend Developer" },
  { text: "The rescue process is remarkably thorough and fast.", author: "Platform Engineer" },
  { text: "Deployed it across 12 production servers. Every issue was resolved in under 60 seconds.", author: "SRE Manager" },
  { text: "I was skeptical at first, but the guided repair menu is genuinely helpful.", author: "Full-Stack Developer" },
  { text: "The rollback safety gave me confidence to try automated repairs.", author: "Infrastructure Lead" },
  { text: "Replaced three internal scripts with one ClawICU command. Cleaner and more reliable.", author: "Tech Lead" },
];

export function TestimonialMarquee() {
  return (
    <section className="relative w-full overflow-hidden py-12">
      <div className="mx-auto max-w-6xl px-6">
        <p className="mb-8 text-center text-sm font-medium uppercase tracking-widest text-muted-foreground">
          Trusted by developers worldwide
        </p>
      </div>
      
      <div className="relative">
        <div className="absolute left-0 top-0 bottom-0 w-32 bg-gradient-to-r from-[#050810] to-transparent z-10" />
        <div className="absolute right-0 top-0 bottom-0 w-32 bg-gradient-to-l from-[#050810] to-transparent z-10" />
        
        <div 
          className="flex gap-4"
          style={{
            animation: "marquee 80s linear infinite",
          }}
        >
          {[...testimonials, ...testimonials].map((t, i) => (
            <div
              key={i}
              className="flex-shrink-0 rounded-xl border border-border bg-card backdrop-blur-[12px] p-6 w-80 transition-all duration-300 hover:border-primary/30 hover:-translate-y-1"
            >
              <p className="text-sm text-foreground leading-relaxed">"{t.text}"</p>
              <p className="mt-3 text-xs font-medium text-[#8892b0]">{t.author}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
