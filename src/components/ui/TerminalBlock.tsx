"use client";
import { useState } from "react";
import { Check, Copy } from "lucide-react";

interface TerminalBlockProps {
  command: string;
  language?: string;
  showLineNumbers?: boolean;
}

export function TerminalBlock({ command, showLineNumbers = false }: TerminalBlockProps) {
  const [copied, setCopied] = useState(false);

  const copy = async () => {
    await navigator.clipboard.writeText(command);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="relative rounded-xl border border-[rgba(255,77,77,0.3)] bg-terminal p-4 font-mono text-sm overflow-hidden">
      <div className="absolute left-0 right-0 top-0 flex h-8 items-center gap-2 border-b border-[rgba(255,77,77,0.15)] bg-terminal/80 px-4">
        <div className="h-3 w-3 rounded-full bg-red-500/80" />
        <div className="h-3 w-3 rounded-full bg-yellow-500/80" />
        <div className="h-3 w-3 rounded-full bg-green-500/80" />
        <span className="ml-2 text-xs text-muted-foreground">terminal</span>
      </div>
      <div className="pt-8">
        <button
          onClick={copy}
          className="absolute right-3 top-3 rounded-md p-1.5 text-muted-foreground hover:bg-white/5 hover:text-foreground transition-colors"
          aria-label="Copy command"
        >
          {copied ? <Check className="h-4 w-4 text-success" /> : <Copy className="h-4 w-4" />}
        </button>
        <code className="text-accent">$ </code>
        <span className="text-foreground">{command}</span>
      </div>
    </div>
  );
}
