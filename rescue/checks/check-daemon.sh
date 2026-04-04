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
            # Check for systemd user unit
            local unit="$HOME/.config/systemd/user/openclaw.service"
            if [ ! -f "$unit" ]; then
                MESSAGE="systemd unit not found for OpenClaw daemon"
                DETAILS="Expected at: $unit"
                return 0
            fi
            ;;
    esac
    
    return 1
}
