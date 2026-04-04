export type Severity = "fatal" | "warn" | "info";

export interface Issue {
  id: string;
  slug: string;
  title: string;
  description: string;
  icon: string; // Lucide icon name
  severity: Severity;
  diagnosis: string;
  steps: string[];
  relatedChecks: string[]; // e.g. ["check-config", "check-gateway"]
  relatedRepairs: string[]; // e.g. ["repair-config", "repair-gateway"]
}

export interface Check {
  id: string;
  name: string;
  description: string;
  severity: Severity;
}

export interface Repair {
  id: string;
  name: string;
  description: string;
  risk: "low" | "medium" | "high";
}
