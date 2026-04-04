# check-node.sh - Detect if Node.js is missing or version < 22.12

check_node() {
    SEVERITY="fatal"
    
    if ! command -v node >/dev/null 2>&1; then
        MESSAGE="Node.js not found - OpenClaw requires Node.js"
        return 0
    fi
    
    # Get version (node --version returns v22.14.0 format)
    local node_version="$(node --version 2>/dev/null | sed 's/v//')"
    local major="$(echo "$node_version" | cut -d. -f1)"
    local minor="$(echo "$node_version" | cut -d. -f2)"
    local patch="$(echo "$node_version" | cut -d. -f3)"
    
    # Check if version < 22.12
    if [ "$major" -lt 22 ]; then
        MESSAGE="Node.js version $node_version is too old. OpenClaw requires Node.js >= 22.12"
        return 0
    fi
    
    if [ "$major" -eq 22 ] && [ "$minor" -lt 12 ]; then
        MESSAGE="Node.js version $node_version is too old. OpenClaw requires Node.js >= 22.12"
        return 0
    fi
    
    return 1
}
