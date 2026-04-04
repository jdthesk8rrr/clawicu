# check-config.sh - Detect invalid JSON5 config file

check_config() {
    SEVERITY="fatal"
    
    local config_path="${OPENCLAW_CONFIG:-$HOME/.openclaw/config.json5}"
    
    if [ ! -f "$config_path" ]; then
        MESSAGE="Config file not found: $config_path"
        return 0
    fi
    
    # Simple JSON5 validation
    # OpenClaw uses JSON5 (trailing commas, comments, unquoted keys)
    # Basic checks: balanced braces, no unclosed strings
    
    # Check for balanced braces
    local brace_count="$(grep -o '{' "$config_path" | wc -l)"
    local close_brace_count="$(grep -o '}' "$config_path" | wc -l)"
    
    if [ "$brace_count" -ne "$close_brace_count" ]; then
        MESSAGE="Config file has unbalanced braces"
        DETAILS="Expected balanced {} pairs"
        return 0
    fi
    
    # Check for at least one closing bracket
    if ! grep -q '}' "$config_path"; then
        MESSAGE="Config file appears incomplete (no closing brace)"
        return 0
    fi
    
    # Check if it's parseable by Node.js as JSON5
    if command -v node >/dev/null 2>&1; then
        if ! node -e "require('json5').parse(require('fs').readFileSync('$config_path', 'utf8'))" 2>/dev/null; then
            MESSAGE="Config file has invalid JSON5 syntax"
            DETAILS="Run 'node -e \"JSON5.parse(require('fs').readFileSync('$config_path', 'utf8'))\"' for details"
            return 0
        fi
    fi
    
    return 1
}
