# check-binary.sh - Detect if openclaw binary is missing or not executable

check_binary() {
    SEVERITY="fatal"
    
    if ! command -v openclaw >/dev/null 2>&1; then
        MESSAGE="OpenClaw binary not found in PATH"
        return 0
    fi
    
    if [ ! -x "$(command -v openclaw)" ]; then
        MESSAGE="OpenClaw binary found but is not executable"
        return 0
    fi
    
    # Binary found and executable
    return 1
}
