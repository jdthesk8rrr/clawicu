# check-state-dir.sh - Detect if ~/.openclaw/ is missing or permissions broken

check_state_dir() {
    SEVERITY="fatal"
    
    local state_dir="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
    
    if [ ! -d "$state_dir" ]; then
        MESSAGE="OpenClaw state directory missing: $state_dir"
        return 0
    fi
    
    if [ ! -r "$state_dir" ] || [ ! -w "$state_dir" ]; then
        MESSAGE="OpenClaw state directory has incorrect permissions: $state_dir"
        return 0
    fi
    
    return 1
}
