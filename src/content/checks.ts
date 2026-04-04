import type { Check } from "@/types";

export const CHECKS: Check[] = [
  {
    id: "check-binary",
    name: "Binary Check",
    description:
      "Verifies the OpenClaw binary exists in PATH and is executable.",
    severity: "fatal",
  },
  {
    id: "check-node",
    name: "Node.js Version",
    description:
      "Ensures Node.js >= 22.12 is installed and accessible.",
    severity: "fatal",
  },
  {
    id: "check-install-method",
    name: "Install Method Detection",
    description:
      "Detects whether OpenClaw was installed via npm, Docker, Podman, or source build.",
    severity: "warn",
  },
  {
    id: "check-docker",
    name: "Docker/Podman Context",
    description:
      "Checks for Docker or Podman container issues when OpenClaw runs inside a container.",
    severity: "warn",
  },
  {
    id: "check-state-dir",
    name: "State Directory",
    description:
      "Verifies ~/.openclaw/ exists with correct permissions and is writable.",
    severity: "fatal",
  },
  {
    id: "check-config",
    name: "Config Syntax",
    description:
      "Validates that config.json5 contains parseable JSON5 (handles JSON5 syntax, not plain JSON).",
    severity: "fatal",
  },
  {
    id: "check-config-schema",
    name: "Config Schema",
    description:
      "Validates individual config fields (port, auth, channels) against expected types and ranges.",
    severity: "warn",
  },
  {
    id: "check-credentials",
    name: "Provider Credentials",
    description:
      "Checks that provider API keys exist and are non-empty in the credentials store.",
    severity: "warn",
  },
  {
    id: "check-gateway",
    name: "Gateway Status",
    description:
      "Confirms the OpenClaw gateway is running and responding on port 18789.",
    severity: "fatal",
  },
  {
    id: "check-daemon",
    name: "Daemon Service",
    description:
      "Checks if the launchd (macOS) or systemd (Linux) service is installed and loaded.",
    severity: "warn",
  },
  {
    id: "check-plugins",
    name: "Plugin Health",
    description:
      "Scans installed plugins for broken manifests or load errors.",
    severity: "warn",
  },
  {
    id: "check-port",
    name: "Port Availability",
    description:
      "Detects whether port 18789 is occupied by another process.",
    severity: "fatal",
  },
  {
    id: "check-disk",
    name: "Disk Space",
    description:
      "Warns if less than 100MB of free disk space remains in the state directory.",
    severity: "warn",
  },
  {
    id: "check-sessions",
    name: "Session Integrity",
    description:
      "Scans session files for corruption or invalid formatting.",
    severity: "info",
  },
  {
    id: "check-version",
    name: "Version Compatibility",
    description:
      "Checks the installed OpenClaw version against the minimum supported version.",
    severity: "warn",
  },
  {
    id: "check-envvars",
    name: "Environment Variables",
    description:
      "Detects conflicting or deprecated OPENCLAW_* environment variables.",
    severity: "info",
  },
  {
    id: "check-exec-approvals",
    name: "Exec Approvals",
    description:
      "Validates that exec-approvals.json is parseable and well-formed.",
    severity: "info",
  },
];
