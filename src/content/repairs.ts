import type { Repair } from "@/types";

export const REPAIRS: Repair[] = [
  {
    id: "repair-config",
    name: "Restore Config from Backup",
    description:
      "Restores config.json5 from the most recent .bak file. Preserves all data — only the file content is replaced.",
    risk: "low",
  },
  {
    id: "repair-config-field",
    name: "Reset Config Fields",
    description:
      "Resets individual config fields (port, auth, channels) to their default values without overwriting the entire file.",
    risk: "low",
  },
  {
    id: "repair-gateway",
    name: "Restart Gateway",
    description:
      "Kills any existing gateway process and starts a fresh instance. Preserves all configuration and state.",
    risk: "medium",
  },
  {
    id: "repair-daemon",
    name: "Reinstall Daemon Service",
    description:
      "Re-registers the OpenClaw daemon with launchd (macOS) or systemd (Linux). Preserves existing configuration.",
    risk: "medium",
  },
  {
    id: "repair-credentials",
    name: "Prompt Missing Credentials",
    description:
      "Interactively prompts for missing provider API keys. Only touches credentials that are currently empty.",
    risk: "low",
  },
  {
    id: "repair-plugins",
    name: "Disable Broken Plugins",
    description:
      "Renames plugin directories with a .disabled suffix and records which plugins were disabled for later re-enablement.",
    risk: "low",
  },
  {
    id: "repair-sessions",
    name: "Remove Corrupted Sessions",
    description:
      "Identifies and removes corrupted session files while preserving healthy ones. Partial data loss possible.",
    risk: "medium",
  },
  {
    id: "repair-downgrade",
    name: "Downgrade Version",
    description:
      "Reinstalls an older, known-working version of OpenClaw. Preserves configuration and credentials.",
    risk: "medium",
  },
  {
    id: "repair-nuclear",
    name: "Full State Reset",
    description:
      "Resets the OpenClaw state directory to defaults while preserving credentials. Creates a full backup first.",
    risk: "high",
  },
  {
    id: "repair-reinstall",
    name: "Clean Reinstall",
    description:
      "Completely removes and reinstalls OpenClaw from scratch. Creates a full backup first. All data is reset.",
    risk: "high",
  },
  {
    id: "repair-port",
    name: "Resolve Port Conflict",
    description:
      "Kills the process occupying port 18789 or reconfigures OpenClaw to use an alternate port. No data loss.",
    risk: "low",
  },
  {
    id: "repair-docker",
    name: "Restart Docker Container",
    description:
      "Restarts the OpenClaw Docker/Podman container and recreates volumes if necessary. Preserves mounted config.",
    risk: "medium",
  },
];
