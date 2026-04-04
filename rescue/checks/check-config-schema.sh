# check-config-schema.sh - Detect invalid config field values (port, auth, etc.)

check_config_schema() {
    SEVERITY="warn"
    
    local config_path="${OPENCLAW_CONFIG:-$HOME/.openclaw/config.json5}"
    
    if [ ! -f "$config_path" ]; then
        return 1
    fi
    
    if command -v node >/dev/null 2>&1; then
        local validation=$(node -e "
            const config = require('json5').parse(require('fs').readFileSync('$config_path', 'utf8'));
            const issues = [];
            
            if (config.port && (config.port < 1 || config.port > 65535)) {
                issues.push('Port must be 1-65535');
            }
            
            if (config.auth && typeof config.auth !== 'object') {
                issues.push('auth must be an object');
            }
            
            if (issues.length > 0) {
                console.log(issues.join(', '));
                process.exit(1);
            }
        " 2>&1)
        
        if [ $? -ne 0 ]; then
            MESSAGE="Config has invalid field values: $validation"
            return 0
        fi
    fi
    
    return 1
}
