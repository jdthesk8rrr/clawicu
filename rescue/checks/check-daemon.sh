# check-daemon.sh - Detect if launchd/systemd service not installed

check_daemon() {
    SEVERITY="warn"
    
    case "$(uname -s)" in
        Darwin*)
            # Check for launchd plist
            local plist="$HOME/Library/LaunchAgents/ai.openclaw.plist"
            if [ ! -f "$plist" ]; then
                MESSAGE="launchd plist not found for OpenClaw daemon"
                DETAILS="Expected at: $plist"
                return 0
            fi
            ;;
        Linux*)
            # OpenClaw installs a user-level service named 'openclaw-gateway'
            local unit_dir="$HOME/.config/systemd/user"
            local unit=""
            # Check both possible unit file names
            if [ -f "$unit_dir/openclaw-gateway.service" ]; then
                unit="$unit_dir/openclaw-gateway.service"
            elif [ -f "$unit_dir/openclaw.service" ]; then
                unit="$unit_dir/openclaw.service"
            fi
            # Also check via systemctl (unit may be installed system-wide)
            if [ -z "$unit" ] && command -v systemctl >/dev/null 2>&1; then
                if systemctl --user list-unit-files "openclaw*.service" 2>/dev/null | grep -q "openclaw"; then
                    return 1  # Unit found via systemctl
                fi
            fi
            if [ -z "$unit" ]; then
                MESSAGE="systemd unit not found for OpenClaw daemon"
                DETAILS="Run: openclaw daemon install"
                return 0
            fi
            ;;
    esac
    
    return 1
}
