# check-credentials.sh - Detect missing provider API keys

check_credentials() {
    SEVERITY="warn"
    
    local creds_dir="${OPENCLAW_CREDS_DIR:-$HOME/.openclaw/credentials}"
    
    if [ ! -d "$creds_dir" ]; then
        MESSAGE="Credentials directory not found: $creds_dir"
        return 0
    fi
    
    local missing=""
    
    for provider in openai anthropic; do
        local provider_file="$creds_dir/$provider.env"
        if [ ! -f "$provider_file" ] && [ ! -f "$creds_dir/$provider" ]; then
            missing="$missing $provider"
        fi
    done
    
    if [ -n "$missing" ]; then
        MESSAGE="Provider credentials missing:$missing"
        DETAILS="Add API keys to $creds_dir/<provider>.env"
        return 0
    fi
    
    return 1
}
