"use client";
import { useState } from "react";
import { Check, Copy } from "lucide-react";

interface TerminalBlockProps {
  command: string;
  showLineNumbers?: boolean;
}

export function TerminalBlock({ command }: TerminalBlockProps) {
  const [copied, setCopied] = useState(false);

  const copy = async () => {
    await navigator.clipboard.writeText(command);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="relative w-full overflow-hidden rounded-xl border border-[rgba(0,232,122,0.2)] bg-[#020a06] shadow-[0_0_30px_rgba(0,232,122,0.06)]">
      {/* ICU monitor title bar */}
      <div className="flex h-9 items-center justify-between border-b border-[rgba(0,232,122,0.15)] bg-[rgba(0,232,122,0.04)] px-4">
        <div className="flex items-center gap-2">
          {/* Status indicator */}
          <span className="h-2 w-2 rounded-full bg-[#00e87a] animate-vital-blink" />
          <span className="font-mono text-[10px] font-bold uppercase tracking-widest text-[#00e87a]/70">
            ICU Terminal — LIVE
          </span>
        </div>
        <div className="flex items-center gap-1.5">
          <span className="h-1 w-4 rounded-full bg-[rgba(0,232,122,0.2)]" />
          <span className="h-1 w-2 rounded-full bg-[rgba(0,232,122,0.15)]" />
          <span className="h-1 w-3 rounded-full bg-[rgba(0,232,122,0.1)]" />
        </div>
      </div>

      {/* Command content */}
      <div className="relative px-5 py-4">
        {/* Subtle scanline */}
        <div
          className="pointer-events-none absolute inset-0 opacity-[0.04]"
          style={{
            backgroundImage: "repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(0,232,122,1) 2px, rgba(0,232,122,1) 3px)",
          }}
        />

        <div className="relative flex items-center gap-3">
          <span className="select-none font-mono text-sm text-[#00e87a]/50">$</span>
          <code className="flex-1 overflow-x-auto font-mono text-sm leading-relaxed text-[#c8ffd4]">
            {command}
          </code>
          <button
            onClick={copy}
            className="shrink-0 rounded-md p-1.5 text-[#00e87a]/40 transition-colors hover:bg-[rgba(0,232,122,0.1)] hover:text-[#00e87a]"
            aria-label="Copy command"
          >
            {copied
              ? <Check className="h-4 w-4 text-[#00e87a]" />
              : <Copy className="h-4 w-4" />
            }
          </button>
        </div>
      </div>
    </div>
  );
}
