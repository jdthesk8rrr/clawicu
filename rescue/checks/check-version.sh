# check-version.sh - Detect unsupported OpenClaw version

check_version() {
    SEVERITY="warn"
    
    if ! command -v openclaw >/dev/null 2>&1; then
        return 1
    fi
    
    local version="$(openclaw --version 2>/dev/null | sed 's/openclaw //' | tr -d 'v')"
    
    if [ -z "$version" ]; then
        MESSAGE="Could not determine OpenClaw version"
        return 0
    fi
    
    local major="$(echo "$version" | cut -d. -f1)"
    local minor="$(echo "$version" | cut -d. -f2)"
    
    if [ "$major" -lt 1 ] 2>/dev/null; then
        MESSAGE="OpenClaw version $version is no longer supported"
        return 0
    fi
    
    return 1
}
