# check-sessions.sh - Detect corrupted session files

check_sessions() {
    SEVERITY="info"
    
    local sessions_dir="${OPENCLAW_SESSIONS_DIR:-$HOME/.openclaw/sessions}"
    
    if [ ! -d "$sessions_dir" ]; then
        return 1
    fi
    
    local corrupted=""
    for session in "$sessions_dir"/*.json; do
        [ -e "$session" ] || continue
        if ! node -e "JSON.parse(require('fs').readFileSync('$session', 'utf8'))" 2>/dev/null; then
            corrupted="$corrupted $(basename "$session")"
        fi
    done
    
    if [ -n "$corrupted" ]; then
        MESSAGE="Session files corrupted:$corrupted"
        return 0
    fi
    
    return 1
}
