# check-plugins.sh - Detect broken plugin manifests or load errors

check_plugins() {
    SEVERITY="warn"
    
    local plugins_dir="${OPENCLAW_PLUGINS_DIR:-$HOME/.openclaw/plugins}"
    
    if [ ! -d "$plugins_dir" ]; then
        MESSAGE="Plugins directory not found: $plugins_dir"
        return 1  # Not an error, just no plugins
    fi
    
    local broken=""
    for plugin in "$plugins_dir"/*/; do
        if [ -d "$plugin" ]; then
            local manifest="$plugin/manifest.json"
            if [ ! -f "$manifest" ]; then
                broken="$broken $(basename "$plugin")"
            fi
        fi
    done
    
    if [ -n "$broken" ]; then
        MESSAGE="Plugin manifests missing or broken:$broken"
        return 0
    fi
    
    return 1
}
