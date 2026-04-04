# check-gateway.sh - Detect if gateway is running on port 18789

check_gateway() {
    SEVERITY="fatal"
    
    local port="${OPENCLAW_GATEWAY_PORT:-18789}"
    
    case "$(uname -s)" in
        Darwin*)
            if nc -z -w 2 localhost "$port" 2>/dev/null; then
                return 1
            fi
            ;;
        Linux*)
            if command -v ss >/dev/null 2>&1; then
                if ss -tuln 2>/dev/null | grep -q ":$port "; then
                    return 1
                fi
            elif nc -z -w 2 localhost "$port" 2>/dev/null; then
                return 1
            fi
            ;;
    esac
    
    if command -v curl >/dev/null 2>&1; then
        if curl -sf "http://localhost:$port/health" >/dev/null 2>&1; then
            return 1
        fi
    fi
    
    MESSAGE="Gateway not running on port $port"
    DETAILS="OpenClaw gateway should be listening on port $port"
    return 0
}
