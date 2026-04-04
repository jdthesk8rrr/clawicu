# check-install-method.sh - Detect installation type (npm/Docker/Podman/source)

check_install_method() {
    SEVERITY="warn"
    
    local method="unknown"
    
    # Check Docker
    if [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
        method="docker"
    elif command -v openclaw >/dev/null 2>&1; then
        # Check if npm global
        local openclaw_path="$(command -v openclaw)"
        if echo "$openclaw_path" | grep -q "node_modules"; then
            method="npm-global"
        else
            method="npm-local"
        fi
    elif command -v podman >/dev/null 2>&1; then
        method="podman"
    elif [ -f "$HOME/openclaw/openclaw" ] || [ -f "/usr/local/bin/openclaw" ]; then
        method="source"
    fi
    
    MESSAGE="OpenClaw installed via: $method"
    CLAWICU_INSTALL_METHOD="$method"
    return 1  # This is informational, not an error
}
