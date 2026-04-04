"use client";
import { Mail, ArrowRight } from "lucide-react";
import { useState } from "react";

export function NewsletterSection() {
  const [email, setEmail] = useState("");
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (email) {
      setSubmitted(true);
    }
  };

  return (
    <section className="mx-auto w-full max-w-[860px] px-6 py-24">
      <div className="relative overflow-hidden rounded-3xl border border-border bg-card backdrop-blur-[12px] p-8 text-center">
        <div className="pointer-events-none absolute -top-20 left-1/2 h-64 w-64 -translate-x-1/2 rounded-full bg-primary/10 blur-[80px]" />
        
        <div className="relative">
          <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-primary/10">
            <Mail className="h-6 w-6 text-primary" />
          </div>
          
          <h2 className="font-heading text-2xl font-bold text-[#f0f4ff]">
            Stay in the Loop
          </h2>
          <p className="mt-2 text-[#8892b0]">
            Get notified about new features and security updates. No spam, unsubscribe anytime.
          </p>
          
          {submitted ? (
            <div className="mt-6 rounded-xl border border-primary/30 bg-primary/10 p-4">
              <p className="text-sm text-primary">
                Thanks! You&apos;ll receive updates at {email}
              </p>
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="mt-6 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-center">
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="you@example.com"
                required
                className="w-full rounded-xl border border-border bg-[#0a0f1a] px-4 py-3 text-sm text-[#f0f4ff] placeholder-[#5a6480] backdrop-blur-sm sm:w-72 focus:border-primary/50 focus:outline-none focus:ring-1 focus:ring-primary/30"
              />
              <button
                type="submit"
                className="group flex items-center justify-center gap-2 rounded-xl bg-primary px-6 py-3 text-sm font-semibold text-primary-foreground shadow-lg transition-all hover:shadow-[0_0_30px_rgba(255,77,77,0.3)] hover:scale-[1.02]"
              >
                Subscribe
                <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-1" />
              </button>
            </form>
          )}
          
          <p className="mt-4 text-xs text-[#5a6480]">
            By subscribing, you agree to receive product updates. Unsubscribe at any time.
          </p>
        </div>
      </div>
    </section>
  );
}
