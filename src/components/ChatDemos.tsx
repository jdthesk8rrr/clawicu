"use client";
import { Bot, User, Zap, Settings, Database } from "lucide-react";
import type { ReactNode } from "react";

interface ChatMessage {
  type: "user" | "bot";
  text: string;
}

interface ChatDemo {
  title: string;
  icon: typeof Zap;
  gradient: string;
  messages: ChatMessage[];
}

const demos: ChatDemo[] = [
  {
    title: "Gateway Crash",
    icon: Zap,
    gradient: "from-[#ff4d4d]/20 to-transparent",
    messages: [
      { type: "user", text: "ClawICU\uFF0C\u6211\u7684 OpenClaw \u7F51\u5173\u5D29\u6E83\u4E86" },
      { type: "bot", text: "\u68C0\u6D4B\u5230\u8FDB\u7A0B\u5F02\u5E38\u9000\u51FA\u3002\u6B63\u5728\u5206\u6790\u6838\u5FC3\u8F6C\u50A8..." },
      { type: "user", text: "\u5E2E\u6211\u4FEE\u590D" },
      { type: "bot", text: "\u5DF2\u81EA\u52A8\u4FEE\u590D\u3002\u7F51\u5173\u5DF2\u91CD\u542F\uFF0C\u541E\u5410\u91CF\u6062\u590D\u6B63\u5E38\u3002" },
    ],
  },
  {
    title: "Plugin Failures",
    icon: Settings,
    gradient: "from-[#00e5cc]/20 to-transparent",
    messages: [
      { type: "user", text: "\u63D2\u4EF6\u52A0\u8F7D\u5931\u8D25\u4E86" },
      { type: "bot", text: "\u53D1\u73B0 3 \u4E2A\u63D2\u4EF6\u4F9D\u8D56\u51B2\u7A81\u3002\u6B63\u5728\u89E3\u51B3..." },
      { type: "user", text: "\u641E\u5B9A\u4E86\u5417" },
      { type: "bot", text: "\u5DF2\u89E3\u51B3\u30022 \u4E2A\u63D2\u4EF6\u5DF2\u91CD\u65B0\u52A0\u8F7D\uFF0C1 \u4E2A\u9700\u8981\u624B\u52A8\u542F\u7528\u3002" },
    ],
  },
  {
    title: "Config Corruption",
    icon: Database,
    gradient: "from-[#8892b0]/20 to-transparent",
    messages: [
      { type: "user", text: "\u914D\u7F6E\u6587\u4EF6\u597D\u50CF\u574F\u4E86" },
      { type: "bot", text: "\u68C0\u6D4B\u5230 JSON5 \u8BED\u6CD5\u9519\u8BEF\u5728\u7B2C 47 \u884C\u3002" },
      { type: "user", text: "\u6062\u590D\u9ED8\u8BA4\u914D\u7F6E" },
      { type: "bot", text: "\u5DF2\u4ECE\u5907\u4EFD\u6062\u590D\u3002\u4FEE\u6539\u5DF2\u4FDD\u5B58\u5230\u65B0\u6587\u4EF6\u3002" },
    ],
  },
];

export function ChatDemos() {
  return (
    <section className="mx-auto w-full max-w-[860px] px-6 py-24">
      <div className="mb-12 text-center">
        <p className="mb-4 font-mono text-xs uppercase tracking-widest text-primary">Use Cases</p>
        <h2 className="font-heading text-3xl font-bold text-[#f0f4ff]">
          AI-Powered Diagnostics
        </h2>
        <p className="mt-4 text-[#8892b0]">
          Describe your problem in natural language. ClawICU diagnoses and fixes automatically.
        </p>
      </div>
      <div className="grid gap-6 sm:grid-cols-3">
        {demos.map((demo) => {
          const Icon = demo.icon;
          return (
            <div
              key={demo.title}
              className="reveal group relative overflow-hidden rounded-2xl border border-border bg-card backdrop-blur-[12px] transition-all duration-300 hover:border-primary/30"
            >
              <div className={"absolute inset-0 bg-gradient-to-br " + demo.gradient + " opacity-0 transition-opacity duration-300 group-hover:opacity-100"} />
              
              <div className="relative flex items-center gap-3 border-b border-border/50 p-4">
                <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10">
                  <Icon className="h-4 w-4 text-primary" />
                </div>
                <span className="font-semibold text-[#f0f4ff]">{demo.title}</span>
              </div>
              
              <div className="relative flex flex-col gap-2 p-4">
                {demo.messages.map((msg, i) => (
                  <div
                    key={i}
                    className={"flex gap-2 " + (msg.type === "user" ? "justify-end" : "justify-start")}
                  >
                    {msg.type === "bot" && (
                      <div className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-primary/20">
                        <Bot className="h-3 w-3 text-primary" />
                      </div>
                    )}
                    <div
                      className={"max-w-[75%] rounded-2xl px-3 py-2 text-xs leading-relaxed " + (msg.type === "user" ? "bg-primary/10 border border-primary/20 text-[#f0f4ff]" : "bg-[#111827] text-[#8892b0]")}
                    >
                      {msg.text}
                    </div>
                    {msg.type === "user" && (
                      <div className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-[#111827]">
                        <User className="h-3 w-3 text-[#5a6480]" />
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </div>
          );
        })}
      </div>
    </section>
  );
}
