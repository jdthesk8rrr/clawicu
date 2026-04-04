# check-envvars.sh - Detect conflicting OPENCLAW_* environment variables

check_envvars() {
    SEVERITY="info"
    
    local conflicts=""
    
    if [ -n "$OPENCLAW_STATE_DIR" ] && [ -n "$CLAWICU_STATE_DIR" ]; then
        conflicts="$conflicts OPENCLAW_STATE_DIR vs CLAWICU_STATE_DIR"
    fi
    
    if [ -n "$OPENCLAW_CONFIG" ] && [ -n "$CLAWICU_CONFIG" ]; then
        conflicts="$conflicts OPENCLAW_CONFIG vs CLAWICU_CONFIG"
    fi
    
    if [ -n "$conflicts" ]; then
        MESSAGE="Conflicting environment variables detected:$conflicts"
        return 0
    fi
    
    return 1
}
