# log.sh - 4-level logging (FATAL/WARN/INFO/DEBUG), colors, file output

set -e

CLAWICU_LOG_LEVEL="${CLAWICU_LOG_LEVEL:-INFO}"
CLAWICU_LOG_FILE="${CLAWICU_LOG_FILE:-}"

# Colors
LOG_FATAL='\033[0;31m'   # Red
LOG_WARN='\033[0;33m'    # Yellow
LOG_INFO='\033[0;32m'    # Green
LOG_DEBUG='\033[0;36m'   # Cyan
LOG_NC='\033[0m'         # No Color

# Timestamps
timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Log to file only (no stdout)
log_file() {
    if [ -n "$CLAWICU_LOG_FILE" ]; then
        echo "[$(timestamp)] $*" >> "$CLAWICU_LOG_FILE"
    fi
}

# Log with level and color
log() {
    local level="$1"
    shift
    local msg="$*"
    local color=""
    local enabled=0

    case "$level" in
        FATAL) color="$LOG_FATAL"; enabled=1 ;;
        WARN)  color="$LOG_WARN"; enabled=1 ;;
        INFO)  color="$LOG_INFO"; enabled=1 ;;
        DEBUG) color="$LOG_DEBUG";
            if [ "$CLAWICU_LOG_LEVEL" = "DEBUG" ]; then enabled=1; fi
            ;;
    esac

    if [ "$enabled" = 1 ]; then
        echo "${color}[$(timestamp)] [$level] $msg${LOG_NC}"
        log_file "[$level] $msg"
    fi
}

log_fatal() { log "FATAL" "$@"; }
log_warn()  { log "WARN" "$@"; }
log_info()  { log "INFO" "$@"; }
log_debug() { log "DEBUG" "$@"; }
