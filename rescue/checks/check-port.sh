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
                if ss -tuln 2>/dev/null | grep -q ":${port}[[:space:]]"; then
                    # ss -tulnp (with -p) shows process names, but requires the process
                    # to belong to the current user. Extract PID with POSIX-safe grep.
                    local proc_info
                    proc_info="$(ss -tulnp 2>/dev/null | grep ":${port}[[:space:]]" \
                        | grep -o 'pid=[0-9]*' | head -1 | cut -d= -f2)"
                    if [ -z "$proc_info" ]; then
                        proc_info="$(lsof -ti ":$port" 2>/dev/null | head -1)"
                    fi
                    MESSAGE="Port $port is already in use"
                    DETAILS="${proc_info:+PID $proc_info is using the port. }Run: ss -tulnp | grep :$port"
                    return 0
                fi
            elif command -v lsof >/dev/null 2>&1; then
                local listener
                listener="$(lsof -i ":$port" -sTCP:LISTEN 2>/dev/null | tail -1 | awk '{print $1}')"
                if [ -n "$listener" ]; then
                    MESSAGE="Port $port is already in use by: $listener"
                    return 0
                fi
            fi
            ;;
    esac
    
    return 1
}
