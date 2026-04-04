"use client";
import { SectionHeader } from "@/components/ui/SectionHeader";
import { RescueSteps } from "@/components/RescueSteps";

export function TreatmentPlan() {
  return (
    <section id="treatment" className="mx-auto w-full max-w-6xl px-6 py-24">
      <SectionHeader
        badge="Treatment Plan"
        title="6-Phase Rescue Protocol"
        description="Follow our proven medical rescue process to restore your OpenClaw instance"
      />
      
      <RescueSteps />
    </section>
  );
}
