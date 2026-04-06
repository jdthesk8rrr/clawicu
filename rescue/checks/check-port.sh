# check-port.sh - Detect if port 18789 is occupied by another process

check_port() {
    SEVERITY="fatal"
    
    local port="${OPENCLAW_GATEWAY_PORT:-18789}"
    
    case "$(uname -s)" in
        Darwin*)
            local listener listener_pid
            listener="$(lsof -i :"$port" -sTCP:LISTEN 2>/dev/null | tail -1 | awk '{print $1}')"
            listener_pid="$(lsof -ti :"$port" -sTCP:LISTEN 2>/dev/null | head -1)"
            if [ -n "$listener" ]; then
                # Skip if it's openclaw gateway
                local proc_cmd
                proc_cmd="$(ps -p "$listener_pid" -o args= 2>/dev/null)"
                if echo "$proc_cmd" | grep -qi "openclaw"; then
                    return 1
                fi
                MESSAGE="Port $port is occupied by: $listener (PID $listener_pid)"
                return 0
            fi
            ;;
        Linux*)
            if command -v ss >/dev/null 2>&1; then
                if ss -tuln 2>/dev/null | grep -q ":${port}[[:space:]]"; then
                    local proc_pid
                    proc_pid="$(ss -tulnp 2>/dev/null | grep ":${port}[[:space:]]" \
                        | grep -o 'pid=[0-9]*' | head -1 | cut -d= -f2)"
                    if [ -z "$proc_pid" ]; then
                        proc_pid="$(lsof -ti ":$port" 2>/dev/null | head -1)"
                    fi
                    # If the port is used by the openclaw gateway itself, that is
                    # expected and not a conflict - skip reporting.
                    if [ -n "$proc_pid" ]; then
                        local proc_cmd
                        proc_cmd="$(ps -p "$proc_pid" -o args= 2>/dev/null || cat /proc/$proc_pid/cmdline 2>/dev/null | tr '\0' ' ')"
                        if echo "$proc_cmd" | grep -qi "openclaw"; then
                            return 1  # Port is used by openclaw gateway — normal
                        fi
                    fi
                    MESSAGE="Port $port is already in use by another process"
                    DETAILS="${proc_pid:+PID $proc_pid is blocking the port. }Run: ss -tulnp | grep :$port"
                    return 0
                fi
            elif command -v lsof >/dev/null 2>&1; then
                local listener listener_pid
                listener="$(lsof -i ":$port" -sTCP:LISTEN 2>/dev/null | tail -1 | awk '{print $1}')"
                listener_pid="$(lsof -ti ":$port" -sTCP:LISTEN 2>/dev/null | head -1)"
                if [ -n "$listener" ]; then
                    # Skip if it's openclaw
                    local proc_cmd
                    proc_cmd="$(ps -p "$listener_pid" -o args= 2>/dev/null)"
                    if echo "$proc_cmd" | grep -qi "openclaw"; then
                        return 1
                    fi
                    MESSAGE="Port $port is already in use by: $listener"
                    return 0
                fi
            fi
            ;;
    esac
    
    return 1
}
