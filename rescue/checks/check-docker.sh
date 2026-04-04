# check-docker.sh - Detect Docker/Podman container issues

check_docker() {
    SEVERITY="warn"
    
    # Only relevant if inside a container
    if [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
        # Check if Docker daemon is accessible
        if ! docker info >/dev/null 2>&1; then
            MESSAGE="Docker container running but Docker daemon not accessible"
            return 0
        fi
        
        # Check if openclaw container is actually running
        if ! docker ps --format '{{.Names}}' | grep -q openclaw; then
            MESSAGE="OpenClaw container not found running"
            return 0
        fi
        
        MESSAGE="Docker container environment detected"
        return 1
    fi
    
    # Not in Docker - skip this check
    return 1
}
