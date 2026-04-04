# check-port.sh - Detect if port 18789 is occupied by another process

check_port() {
    SEVERITY="fatal"
    
    local port="${OPENCLAW_GATEWAY_PORT:-18789}"
    
    case "$(uname -s)" in
        Darwin*)
            local listener="$(lsof -i :"$port" -sTCP:LISTEN 2>/dev/null | tail -1 | awk '{print $1}')"
            if [ -n "$listener" ]; then
                MESSAGE="Port $port is occupied by process: $listener"
                return 0
            fi
            ;;
        Linux*)
            if command -v ss >/dev/null 2>&1; then
                if ss -tuln 2>/dev/null | grep -q ":$port "; then
                    local pid="$(ss -tuln 2>/dev/null | grep ":$port " | awk '{print $6}' | head -1)"
                    MESSAGE="Port $port is already in use"
                    DETAILS="Process: $pid"
                    return 0
                fi
            fi
            ;;
    esac
    
    return 1
}
