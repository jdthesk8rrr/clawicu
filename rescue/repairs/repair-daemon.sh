#!/bin/sh
# repair-daemon.sh - Reinstall launchd (macOS) or systemd (Linux) service

set -e

. "$(dirname "$0")/../lib/bootstrap.sh"
. "$(dirname "$0")/../lib/backup.sh"
. "$(dirname "$0")/../lib/state.sh"
. "$(dirname "$0")/../lib/log.sh"

repair_daemon() {
    _service_name="com.opencode.gateway"
    _gateway_bin=""
    _gateway_port="${OPENCODE_GATEWAY_PORT:-18789}"

    describe() {
        echo "Reinstall the OpenCode gateway as a system service (launchd or systemd)"
    }

    dry_run() {
        echo "What would happen:"
        echo "  - Detect OS (macOS → launchd, Linux → systemd)"
        echo "  - Locate the gateway binary"
        echo "  - Back up any existing service file"
        echo "  - Generate and install service file"
        echo "  - Enable and start the service"
        echo "  - Verify the service is running"
        echo "  - Roll back if service fails to start"
    }

    _detect_os() {
        local uname_out
        uname_out="$(uname -s)"
        case "$uname_out" in
            Darwin) echo "macos" ;;
            Linux)  echo "linux" ;;
            *)      echo "unknown" ;;
        esac
    }

    _find_gateway_binary() {
        if command -v opencode >/dev/null 2>&1; then
            command -v opencode
            return 0
        fi
        local candidate
        for candidate in \
            /usr/local/bin/opencode \
            /opt/homebrew/bin/opencode \
            "$HOME/.local/bin/opencode" \
            /usr/bin/opencode; do
            if [ -x "$candidate" ]; then
                echo "$candidate"
                return 0
            fi
        done
        return 1
    }

    _generate_launchd_plist() {
        local label="$1"
        local bin_path="$2"
        local port="$3"
        local plist_target="$4"

        cat > "$plist_target" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${label}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${bin_path}</string>
        <string>gateway</string>
        <string>start</string>
        <string>--port</string>
        <string>${port}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/opencode-gateway.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/opencode-gateway.err</string>
</dict>
</plist>
PLIST
    }

    _generate_systemd_unit() {
        local name="$1"
        local bin_path="$2"
        local port="$3"
        local unit_target="$4"

        cat > "$unit_target" <<UNIT
[Unit]
Description=OpenCode Gateway
After=network.target

[Service]
Type=simple
ExecStart=${bin_path} gateway start --port ${port}
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
UNIT
    }

    _install_macos() {
        local plist_dir="$HOME/Library/LaunchAgents"
        mkdir -p "$plist_dir"
        local plist_file="$plist_dir/${_service_name}.plist"

        if [ -f "$plist_file" ]; then
            log_info "Unloading existing plist..."
            launchctl unload "$plist_file" 2>/dev/null || true
        fi

        _generate_launchd_plist "$_service_name" "$_gateway_bin" "$_gateway_port" "$plist_file"

        log_info "Loading plist..."
        launchctl load "$plist_file" 2>/dev/null

        sleep 2
        if launchctl list | grep -q "$_service_name"; then
            return 0
        fi
        return 1
    }

    _install_linux() {
        local unit_dir="/etc/systemd/system"
        local unit_file="$unit_dir/opencode-gateway.service"

        if [ ! -d "$unit_dir" ]; then
            log_fatal "systemd unit directory not found: $unit_dir"
            return 1
        fi

        _generate_systemd_unit "opencode-gateway" "$_gateway_bin" "$_gateway_port" "$unit_file"

        log_info "Reloading systemd daemon..."
        systemctl daemon-reload 2>/dev/null || true

        log_info "Enabling service..."
        systemctl enable opencode-gateway 2>/dev/null || true

        log_info "Starting service..."
        systemctl start opencode-gateway 2>/dev/null || true

        sleep 2
        if systemctl is-active --quiet opencode-gateway 2>/dev/null; then
            return 0
        fi
        return 1
    }

    _rollback_macos() {
        local plist_dir="$HOME/Library/LaunchAgents"
        local plist_file="$plist_dir/${_service_name}.plist"
        launchctl unload "$plist_file" 2>/dev/null || true
        if [ -f "${plist_file}.bak" ]; then
            cp "${plist_file}.bak" "$plist_file"
            launchctl load "$plist_file" 2>/dev/null || true
        fi
    }

    _rollback_linux() {
        systemctl stop opencode-gateway 2>/dev/null || true
        if [ -f "/etc/systemd/system/opencode-gateway.service.bak" ]; then
            cp "/etc/systemd/system/opencode-gateway.service.bak" \
               "/etc/systemd/system/opencode-gateway.service"
            systemctl daemon-reload 2>/dev/null || true
            systemctl start opencode-gateway 2>/dev/null || true
        fi
    }

    execute() {
        log_info "Starting daemon reinstall repair..."

        local os
        os=$(_detect_os)
        if [ "$os" = "unknown" ]; then
            log_fatal "Unsupported operating system. Only macOS and Linux are supported."
            return 1
        fi
        log_info "Detected OS: $os"

        if ! _gateway_bin=$(_find_gateway_binary); then
            log_fatal "Cannot locate opencode binary. Ensure it is installed and in PATH."
            return 1
        fi
        log_info "Gateway binary: $_gateway_bin"

        state_push "repair-daemon"
        local backup_path
        backup_path="$(backup_create "repair-daemon")"

        if [ "$os" = "macos" ]; then
            local plist_file="$HOME/Library/LaunchAgents/${_service_name}.plist"
            if [ -f "$plist_file" ]; then
                cp "$plist_file" "${plist_file}.bak"
            fi
        else
            local unit_file="/etc/systemd/system/opencode-gateway.service"
            if [ -f "$unit_file" ]; then
                cp "$unit_file" "${unit_file}.bak" 2>/dev/null || true
            fi
        fi

        local success=false
        case "$os" in
            macos) _install_macos && success=true ;;
            linux) _install_linux && success=true ;;
        esac

        if [ "$success" = "true" ]; then
            log_info "Daemon service installed and started successfully"
            return 0
        else
            log_error "Daemon service failed to start, rolling back..."
            case "$os" in
                macos) _rollback_macos ;;
                linux) _rollback_linux ;;
            esac
            state_rollback
            log_error "Rollback completed"
            return 1
        fi
    }
}
