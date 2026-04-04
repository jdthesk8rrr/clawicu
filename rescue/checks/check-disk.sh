# check-disk.sh - Detect low disk space

check_disk() {
    SEVERITY="warn"
    
    local min_free_mb="${CLAWICU_MIN_FREE_MB:-100}"
    
    case "$(uname -s)" in
        Darwin*)
            local free_space="$(df -k "$HOME" 2>/dev/null | tail -1 | awk '{print $4}')"
            local free_mb=$((free_space / 1024))
            ;;
        Linux*)
            local free_space="$(df -k "$HOME" 2>/dev/null | tail -1 | awk '{print $4}')"
            local free_mb=$((free_space / 1024))
            ;;
    esac
    
    if [ -n "$free_mb" ] && [ "$free_mb" -lt "$min_free_mb" ]; then
        MESSAGE="Low disk space: ${free_mb}MB free (minimum ${min_free_mb}MB recommended)"
        return 0
    fi
    
    return 1
}
