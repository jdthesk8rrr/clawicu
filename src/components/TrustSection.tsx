import { Shield, Award, CheckCircle, Star } from "lucide-react";

const trustItems = [
  { icon: Shield, label: "SOC 2 Certified", sublabel: "Enterprise Security" },
  { icon: Award, label: "Open Source", sublabel: "MIT License" },
  { icon: CheckCircle, label: "Zero Config", sublabel: "Works Out of Box" },
  { icon: Star, label: "1.2k+ Stars", sublabel: "GitHub" },
];

export function TrustSection() {
  return (
    <section className="mx-auto w-full max-w-[860px] px-6 py-16">
      <p className="mb-8 text-center font-mono text-xs uppercase tracking-widest text-[#5a6480]">
        Trusted by Developers Worldwide
      </p>
      <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
        {trustItems.map((item) => {
          const Icon = item.icon;
          return (
            <div
              key={item.label}
              className="flex flex-col items-center gap-2 rounded-2xl border border-border bg-card p-4 text-center backdrop-blur-[12px] transition-all duration-300 hover:border-primary/30 hover:shadow-[0_0_20px_rgba(255,77,77,0.1)]"
            >
              <Icon className="h-5 w-5 text-primary" />
              <span className="text-sm font-semibold text-[#f0f4ff]">{item.label}</span>
              <span className="text-xs text-[#5a6480]">{item.sublabel}</span>
            </div>
          );
        })}
      </div>
    </section>
  );
}
