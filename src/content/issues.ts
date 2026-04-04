import type { Issue } from "@/types";

export const ISSUES: Issue[] = [
  {
    id: "config-corruption",
    slug: "config-corruption",
    title: "Config File Corruption",
    description:
      "The config.json5 file contains invalid JSON5 syntax, preventing OpenClaw from starting. This is the most common fatal error and can be caused by manual edits, failed upgrades, or truncated writes.",
    icon: "FileWarning",
    severity: "fatal",
    diagnosis:
      "Run `openclaw doctor` and look for JSON parse errors, or manually inspect ~/.openclaw/config.json5 for trailing commas, unclosed braces, or commented-out fields that break the parser.",
    steps: [
      "Back up the current config: `cp ~/.openclaw/config.json5 ~/.openclaw/config.json5.bak`",
      "Validate JSON5 syntax using an online JSON5 linter or `node -e \"require('json5').parse(require('fs').readFileSync('~/.openclaw/config.json5','utf8'))\"`",
      "If a backup exists at config.json5.bak, compare and restore the last known good version",
      "Fix specific syntax errors \u2014 look for trailing commas, missing quotes, or invalid escape sequences",
      "Run `openclaw doctor` to verify the config loads correctly after the fix",
    ],
    relatedChecks: ["check-config", "check-config-schema"],
    relatedRepairs: ["repair-config", "repair-config-field"],
  },
  {
    id: "plugin-failures",
    slug: "plugin-failures",
    title: "Plugin Manifest Errors",
    description:
      "One or more installed plugins have broken manifests or fail to load, causing runtime errors or preventing OpenClaw from starting. Often occurs after upgrading OpenClaw without updating plugins.",
    icon: "Puzzle",
    severity: "warn",
    diagnosis:
      "Check OpenClaw logs for plugin load errors, or run `openclaw plugins list` to see which plugins fail to enumerate. Look for missing manifest.json files or schema mismatches in ~/.openclaw/plugins/.",
    steps: [
      "List all plugins: `openclaw plugins list` and note any that show errors",
      "Check each plugin directory under ~/.openclaw/plugins/ for a valid manifest.json",
      "Disable problematic plugins by renaming their directory with a `.disabled` suffix",
      "Re-enable plugins one at a time, testing with `openclaw doctor` after each",
      "Update or reinstall plugins that are incompatible with your current OpenClaw version",
    ],
    relatedChecks: ["check-plugins"],
    relatedRepairs: ["repair-plugins"],
  },
  {
    id: "gateway-crash",
    slug: "gateway-crash",
    title: "Gateway Not Running",
    description:
      "The OpenClaw gateway process has crashed or failed to start on port 18789. This makes all agent channels unreachable even though the rest of the system may be healthy.",
    icon: "WifiOff",
    severity: "fatal",
    diagnosis:
      "Check if the gateway is listening: `curl -s http://localhost:18789/health` or `lsof -i :18789`. Inspect gateway logs in ~/.openclaw/logs/ for crash traces or OOM kills.",
    steps: [
      "Check if the process exists: `ps aux | grep openclaw` or `pgrep -f openclaw-gateway`",
      "Review recent gateway logs in ~/.openclaw/logs/ for the crash reason",
      "Kill any zombie gateway processes: `pkill -f openclaw-gateway`",
      "Restart the gateway: `openclaw gateway start` or the appropriate install-method command",
      "Verify it is running: `curl -s http://localhost:18789/health` should return 200",
    ],
    relatedChecks: ["check-gateway"],
    relatedRepairs: ["repair-gateway"],
  },
  {
    id: "daemon-issues",
    slug: "daemon-issues",
    title: "Daemon Service Not Installed",
    description:
      "The OpenClaw daemon (launchd on macOS, systemd on Linux) is not registered as a system service. This means OpenClaw will not auto-start on boot and background operations may fail.",
    icon: "ShieldAlert",
    severity: "warn",
    diagnosis:
      "On macOS: `launchctl list | grep openclaw`. On Linux: `systemctl --user status openclaw`. If neither shows the service, it is not installed.",
    steps: [
      "Verify the service is missing: `launchctl list | grep openclaw` (macOS) or `systemctl --user status openclaw` (Linux)",
      "Check for an existing plist/unit file that was not loaded",
      "Run `openclaw daemon install` to register the service with your system's service manager",
      "Start the daemon immediately: `openclaw daemon start`",
      "Verify auto-start works: reboot (optional) or `openclaw daemon status`",
    ],
    relatedChecks: ["check-daemon"],
    relatedRepairs: ["repair-daemon"],
  },
  {
    id: "credential-problems",
    slug: "credential-problems",
    title: "Missing API Credentials",
    description:
      "Provider API keys are missing or empty in the credentials store. OpenClaw cannot connect to any AI provider without valid credentials, making all agent requests fail.",
    icon: "KeyRound",
    severity: "warn",
    diagnosis:
      "Check ~/.openclaw/credentials/ for empty or missing key files. Run `openclaw doctor` \u2014 it will report which providers have no configured credentials.",
    steps: [
      "Run `openclaw doctor` to see which providers are missing credentials",
      "Locate your API keys from each provider's dashboard (OpenAI, Anthropic, Google, etc.)",
      "Set credentials: `openclaw onboard` for interactive setup, or set environment variables like `OPENAI_API_KEY`",
      "Verify credentials are stored: check that files in ~/.openclaw/credentials/ are non-empty",
      "Test connectivity: run a simple prompt through the provider to confirm the key works",
    ],
    relatedChecks: ["check-credentials"],
    relatedRepairs: ["repair-credentials"],
  },
  {
    id: "port-conflicts",
    slug: "port-conflicts",
    title: "Port 18789 Occupied",
    description:
      "Another process is already using port 18789, preventing the OpenClaw gateway from binding. This commonly happens when a previous OpenClaw instance did not shut down cleanly or another service claims the same port.",
    icon: "Network",
    severity: "fatal",
    diagnosis:
      "Run `lsof -i :18789` or `ss -tlnp | grep 18789` to see which process holds the port. Compare the PID with `pgrep -f openclaw` to determine if it is a stale OpenClaw process or a foreign service.",
    steps: [
      "Identify the process: `lsof -i :18789` (macOS) or `ss -tlnp | grep 18789` (Linux)",
      "If it is a stale OpenClaw process, kill it: `kill <PID>` (or `kill -9` if unresponsive)",
      "If it is another service, decide whether to stop that service or reconfigure OpenClaw's port",
      "To change OpenClaw's port, edit the `port` field in ~/.openclaw/config.json5",
      "Restart the gateway and verify: `curl -s http://localhost:<port>/health`",
    ],
    relatedChecks: ["check-port"],
    relatedRepairs: ["repair-port"],
  },
  {
    id: "network-timeout",
    slug: "network-timeout",
    title: "Network Timeout",
    description:
      "OpenClaw agent cannot connect to the gateway due to network timeout or firewall rules blocking communication between components.",
    icon: "Network",
    severity: "warn",
    diagnosis:
      "Check connectivity with `curl -s --connect-timeout 5 http://localhost:18789/health`. If using a remote gateway, verify firewall rules allow traffic on port 18789. DNS issues can be diagnosed with `nslookup` or `dig`.",
    steps: [
      "Test local connectivity: `curl -s http://localhost:18789/health`",
      "Check firewall rules: `sudo iptables -L -n` (Linux) or System Preferences > Security (macOS)",
      "If using DNS, verify resolution: `nslookup your-gateway-host`",
      "Check for network latency: `ping -c 5 your-gateway-host`",
      "For remote deployments, verify security group rules allow inbound traffic on the gateway port",
    ],
    relatedChecks: ["check-gateway", "check-port"],
    relatedRepairs: ["repair-gateway", "repair-port"],
  },
  {
    id: "memory-leak",
    slug: "memory-leak",
    title: "Memory Leak",
    description:
      "OpenClaw daemon memory usage grows continuously until the process is killed by the OOM killer. This degrades performance over time and causes unexpected crashes.",
    icon: "Cpu",
    severity: "fatal",
    diagnosis:
      "Monitor memory with `top -pid $(pgrep -f openclaw)` or `ps aux | grep openclaw`. If RSS grows steadily over hours, a memory leak is likely. Check ~/.openclaw/logs/ for OOM kill messages.",
    steps: [
      "Check current memory usage: `ps -o rss,vsz,pid,comm -p $(pgrep -f openclaw)`",
      "Review logs for OOM messages: `grep -i 'oom\\|killed' ~/.openclaw/logs/*`",
      "Disable all plugins and restart to isolate: `openclaw plugins disable-all`",
      "Re-enable plugins one at a time while monitoring memory to find the culprit",
      "If leak persists with no plugins, upgrade OpenClaw to the latest version",
    ],
    relatedChecks: ["check-gateway", "check-plugins"],
    relatedRepairs: ["repair-plugins", "repair-gateway"],
  },
  {
    id: "disk-space-full",
    slug: "disk-space-full",
    title: "Disk Space Full",
    description:
      "OpenClaw cannot write logs, session data, or state files due to insufficient disk space on the volume hosting ~/.openclaw/.",
    icon: "HardDrive",
    severity: "fatal",
    diagnosis:
      "Check available space: `df -h ~/.openclaw/`. Check log sizes: `du -sh ~/.openclaw/logs/`. Large session histories can also consume significant space.",
    steps: [
      "Check disk usage: `df -h` and `du -sh ~/.openclaw/*`",
      "Clear old logs: `find ~/.openclaw/logs/ -mtime +30 -delete`",
      "Clear old sessions: `find ~/.openclaw/sessions/ -mtime +7 -delete`",
      "Set up log rotation in config.json5: add `logRotation: { maxFiles: 7, maxSize: '50mb' }`",
      "If still low on space, consider moving ~/.openclaw/ to a larger volume",
    ],
    relatedChecks: ["check-disk"],
    relatedRepairs: ["repair-config"],
  },
  {
    id: "permission-denied",
    slug: "permission-denied",
    title: "Permission Denied",
    description:
      "OpenClaw cannot access configuration files, state directories, or credentials due to incorrect file permissions or SELinux/AppArmor restrictions.",
    icon: "Lock",
    severity: "warn",
    diagnosis:
      "Check ownership: `ls -la ~/.openclaw/`. If files are owned by root or another user, OpenClaw cannot write to them. On Linux, check SELinux: `getenforce` and AppArmor: `aa-status`.",
    steps: [
      "Check file ownership: `ls -laR ~/.openclaw/ | head -50`",
      "Fix ownership: `sudo chown -R $(whoami) ~/.openclaw/`",
      "Fix permissions: `chmod -R u+rwX ~/.openclaw/`",
      "On Linux with SELinux: `sudo restorecon -Rv ~/.openclaw/`",
      "If running as a dedicated user, ensure the user owns all files: `sudo -u openclaw openclaw doctor`",
    ],
    relatedChecks: ["check-state-dir", "check-config"],
    relatedRepairs: ["repair-config"],
  },
  {
    id: "database-locked",
    slug: "database-locked",
    title: "Database Locked",
    description:
      "OpenClaw's SQLite database is locked by another process, preventing writes to session state, plugin data, or configuration cache.",
    icon: "Database",
    severity: "warn",
    diagnosis:
      "Check for lock files: `ls -la ~/.openclaw/*.db-journal ~/.openclaw/*.db-wal`. Multiple OpenClaw processes or a previous crash can leave locks behind.",
    steps: [
      "Check for multiple processes: `ps aux | grep openclaw`",
      "Stop all OpenClaw processes: `pkill -f openclaw`",
      "Remove stale lock files: `rm -f ~/.openclaw/*.db-journal ~/.openclaw/*.db-wal ~/.openclaw/*.db-shm`",
      "Restart OpenClaw: `openclaw gateway start`",
      "If the database is corrupted, restore from backup: `cp ~/.openclaw/state.db.bak ~/.openclaw/state.db`",
    ],
    relatedChecks: ["check-gateway", "check-sessions"],
    relatedRepairs: ["repair-gateway"],
  },
  {
    id: "ssl-certificate-expired",
    slug: "ssl-certificate-expired",
    title: "SSL Certificate Expired",
    description:
      "The OpenClaw gateway's SSL/TLS certificate has expired, causing HTTPS connections to be rejected by clients and browsers.",
    icon: "ShieldAlert",
    severity: "fatal",
    diagnosis:
      "Check certificate expiry: `openssl x509 -enddate -noout -in ~/.openclaw/certs/server.crt`. Also verify system time is correct: `date` \u2014 incorrect clocks can cause false expiry.",
    steps: [
      "Check certificate expiry date: `openssl x509 -enddate -noout -in ~/.openclaw/certs/server.crt`",
      "Verify system time is correct: `date` and `ntpdate -q pool.ntp.org`",
      "If using Let's Encrypt, renew: `certbot renew --cert-name openclaw`",
      "For self-signed certs, regenerate: `openclaw gateway cert regenerate`",
      "Restart the gateway after certificate renewal",
    ],
    relatedChecks: ["check-gateway", "check-config"],
    relatedRepairs: ["repair-gateway"],
  },
  {
    id: "api-rate-limit",
    slug: "api-rate-limit",
    title: "API Rate Limit Exceeded",
    description:
      "OpenClaw is sending too many requests to AI provider APIs within a short time window, causing 429 responses and failed agent interactions.",
    icon: "Gauge",
    severity: "info",
    diagnosis:
      "Check logs for 429 responses: `grep -i '429\\|rate limit' ~/.openclaw/logs/*`. The `openclaw doctor` command also reports rate limit warnings.",
    steps: [
      "Check recent 429 errors: `grep '429' ~/.openclaw/logs/gateway.log | tail -20`",
      "Add request delays in config.json5: `apiThrottle: { minInterval: 500 }`",
      "Enable response caching to reduce redundant API calls",
      "If using a provider with usage tiers, consider upgrading your plan",
      "Distribute load across multiple API keys or providers",
    ],
    relatedChecks: ["check-credentials", "check-gateway"],
    relatedRepairs: ["repair-config-field"],
  },
  {
    id: "version-mismatch",
    slug: "version-mismatch",
    title: "Version Mismatch",
    description:
      "OpenClaw agent, gateway, and CLI are running different versions, causing protocol incompatibility and communication errors between components.",
    icon: "RefreshCcw",
    severity: "warn",
    diagnosis:
      "Check versions: `openclaw --version`, `openclaw gateway version`, and compare with `cat ~/.openclaw/VERSION`. Mismatches after partial upgrades are the most common cause.",
    steps: [
      "Check all component versions: `openclaw --version` and `openclaw gateway version`",
      "Compare with the expected version from the release notes",
      "Update all components together: `npm update -g openclaw && openclaw gateway restart`",
      "For Docker: pull the latest image and recreate the container",
      "Verify compatibility after upgrade: `openclaw doctor`",
    ],
    relatedChecks: ["check-version", "check-binary"],
    relatedRepairs: ["repair-downgrade"],
  },
  {
    id: "startup-failure",
    slug: "startup-failure",
    title: "Startup Failure",
    description:
      "OpenClaw daemon fails to start on system boot or after a manual restart. The service enters a failed state with a non-zero exit code.",
    icon: "Power",
    severity: "fatal",
    diagnosis:
      "Check service logs: `journalctl --user -u openclaw` (Linux) or `log show --predicate 'process == \"openclaw\"'` (macOS). Common causes include missing dependencies, port conflicts, and configuration errors.",
    steps: [
      "Check service status: `systemctl --user status openclaw` (Linux) or `launchctl list | grep openclaw` (macOS)",
      "Review detailed logs: `journalctl --user -u openclaw -n 50` or check ~/.openclaw/logs/",
      "Verify all dependencies are met: Node.js >= 22.12, disk space, network access",
      "Check for port conflicts: `lsof -i :18789`",
      "Try manual start to see the error: `openclaw gateway start --foreground`",
    ],
    relatedChecks: ["check-binary", "check-node", "check-gateway", "check-port"],
    relatedRepairs: ["repair-gateway", "repair-daemon"],
  },
];

export function getIssueBySlug(slug: string): Issue | undefined {
  return ISSUES.find((issue) => issue.slug === slug);
}

export function getIssueById(id: string): Issue | undefined {
  return ISSUES.find((issue) => issue.id === id);
}
