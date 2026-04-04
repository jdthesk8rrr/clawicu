# check-exec-approvals.sh - Detect unparseable exec-approvals.json

check_exec_approvals() {
    SEVERITY="info"
    
    local approvals_file="${OPENCLAW_STATE_DIR:-$HOME/.openclaw/exec-approvals.json}"
    
    if [ ! -f "$approvals_file" ]; then
        return 1
    fi
    
    if ! node -e "JSON.parse(require('fs').readFileSync('$approvals_file', 'utf8'))" 2>/dev/null; then
        MESSAGE="exec-approvals.json is not valid JSON"
        return 0
    fi
    
    return 1
}
