"use client";

import { useState } from "react";
import { Check, Copy } from "lucide-react";
import { cn } from "@/lib/utils";

const command = "curl -fsSL https://xagent.icu/r | sh";

export function RescueCommand() {
  const [copied, setCopied] = useState(false);

  const handleCopy = async () => {
    await navigator.clipboard.writeText(command);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div
      id="get-started"
      className="group relative w-full max-w-2xl animate-fade-up"
      style={{ animationDelay: "0.4s" }}
    >
      <div className="absolute -inset-px rounded-xl bg-gradient-to-b from-primary/30 via-primary/10 to-transparent opacity-50 transition-opacity group-hover:opacity-80" />

      <div className="relative flex items-center gap-4 rounded-xl bg-terminal px-5 py-4 font-mono text-sm ring-1 ring-[rgba(255,77,77,0.3)] sm:px-6 sm:py-5 sm:text-base">
        <span className="select-none text-accent/60">$</span>

        <span className="flex-1 overflow-x-auto text-foreground/90">
          <span className="text-primary">curl</span>{" "}
          <span className="text-[#8892b0]">-fsSL</span>{" "}
          <span className="text-accent">https://xagent.icu/r</span>{" "}
          <span className="text-[#8892b0]">|</span>{" "}
          <span className="text-primary">sh</span>
        </span>

        <button
          onClick={handleCopy}
          className={cn(
            "flex h-8 w-8 shrink-0 items-center justify-center rounded-lg transition-all",
            copied
              ? "bg-success/20 text-success"
              : "bg-foreground/5 text-muted-foreground hover:bg-foreground/10 hover:text-foreground"
          )}
          aria-label="Copy command"
        >
          {copied ? (
            <Check className="h-4 w-4" />
          ) : (
            <Copy className="h-4 w-4" />
          )}
        </button>
      </div>
    </div>
  );
}
