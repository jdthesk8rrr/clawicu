#!/bin/sh
# repair-gateway.sh - Restart the OpenCode gateway process

set -e

. "$(dirname "$0")/../lib/bootstrap.sh"
. "$(dirname "$0")/../lib/backup.sh"
. "$(dirname "$0")/../lib/state.sh"
. "$(dirname "$0")/../lib/log.sh"

repair_gateway() {
    _gateway_port="${OPENCODE_GATEWAY_PORT:-18789}"

    describe() {
        echo "Restart the OpenCode gateway, auto-detecting install method"
    }

    dry_run() {
        echo "What would happen:"
        echo "  - Detect install method (npm global / Docker / Podman)"
        echo "  - Record current gateway PID for rollback"
        echo "  - Kill existing gateway process"
        echo "  - Restart gateway via detected method"
        echo "  - Wait for gateway to respond on port $_gateway_port"
        echo "  - Roll back to original process if restart fails"
    }

    _detect_install_method() {
        if command -v opencode >/dev/null 2>&1; then
            echo "npm"
            return 0
        fi
        if command -v docker >/dev/null 2>&1 && docker ps --format '{{.Names}}' 2>/dev/null | grep -q opencode; then
            echo "docker"
            return 0
        fi
        if command -v podman >/dev/null 2>&1 && podman ps --format '{{.Names}}' 2>/dev/null | grep -q opencode; then
            echo "podman"
            return 0
        fi
        return 1
    }

    _find_gateway_pid() {
        local pid
        pid=$(lsof -ti :"$_gateway_port" 2>/dev/null | head -1)
        if [ -n "$pid" ]; then
            echo "$pid"
            return 0
        fi
        pid=$(pgrep -f "opencode.*gateway" 2>/dev/null | head -1)
        echo "$pid"
        [ -n "$pid" ]
    }

    _kill_gateway() {
        local pid="$1"
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            log_info "Sending SIGTERM to gateway PID $pid"
            kill "$pid" 2>/dev/null || true
            local retries=0
            while [ $retries -lt 10 ] && kill -0 "$pid" 2>/dev/null; do
                sleep 1
                retries=$((retries + 1))
            done
            if kill -0 "$pid" 2>/dev/null; then
                log_warn "Gateway did not stop gracefully, sending SIGKILL"
                kill -9 "$pid" 2>/dev/null || true
                sleep 1
            fi
        fi
    }

    _start_gateway_npm() {
        log_info "Starting gateway via npm..."
        nohup opencode gateway start --port "$_gateway_port" >/dev/null 2>&1 &
    }

    _start_gateway_docker() {
        log_info "Starting gateway via Docker..."
        docker start opencode-gateway 2>/dev/null && return 0
        docker run -d --name opencode-gateway \
            -p "$_gateway_port:18789" \
            opencode/gateway:latest 2>/dev/null
    }

    _start_gateway_podman() {
        log_info "Starting gateway via Podman..."
        podman start opencode-gateway 2>/dev/null && return 0
        podman run -d --name opencode-gateway \
            -p "$_gateway_port:18789" \
            opencode/gateway:latest 2>/dev/null
    }

    _wait_for_gateway() {
        local max_wait="${OPENCODE_GATEWAY_TIMEOUT:-30}"
        local elapsed=0
        log_info "Waiting for gateway to respond on port $_gateway_port (timeout: ${max_wait}s)..."
        while [ $elapsed -lt $max_wait ]; do
            if curl -sf "http://127.0.0.1:$_gateway_port/health" >/dev/null 2>&1; then
                return 0
            fi
            if nc -z 127.0.0.1 "$_gateway_port" 2>/dev/null; then
                return 0
            fi
            sleep 1
            elapsed=$((elapsed + 1))
        done
        return 1
    }

    execute() {
        log_info "Starting gateway restart repair..."

        local method
        if ! method=$(_detect_install_method); then
            log_fatal "Cannot detect gateway install method. Install via npm, Docker, or Podman."
            return 1
        fi
        log_info "Detected install method: $method"

        local old_pid
        old_pid=$(_find_gateway_pid || echo "")
        if [ -n "$old_pid" ]; then
            log_info "Found existing gateway PID: $old_pid"
        else
            log_warn "No running gateway process detected"
        fi

        state_push "repair-gateway"
        local backup_path
        backup_path="$(backup_create "repair-gateway")"

        if [ -n "$old_pid" ]; then
            _kill_gateway "$old_pid"
            log_info "Previous gateway process stopped"
        fi

        case "$method" in
            npm)    _start_gateway_npm ;;
            docker) _start_gateway_docker ;;
            podman) _start_gateway_podman ;;
        esac

        if _wait_for_gateway; then
            log_info "Gateway restart completed successfully on port $_gateway_port"
            return 0
        else
            log_error "Gateway did not come up within timeout, rolling back..."
            if [ -n "$old_pid" ]; then
                log_info "Attempting to restart original gateway process..."
                case "$method" in
                    npm)    _start_gateway_npm ;;
                    docker) _start_gateway_docker ;;
                    podman) _start_gateway_podman ;;
                esac
                sleep 3
            fi
            state_rollback
            log_error "Gateway restart failed, rollback attempted"
            return 1
        fi
    }
}
