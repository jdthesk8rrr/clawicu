#!/bin/sh
# state.sh - Rollback state machine

CLAWICU_STATE_FILE="${CLAWICU_STATE_FILE:-$CLAWICU_TMPDIR/state.json}"

# State machine: push state before each repair
state_push() {
    local action="$1"
    local timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

    # Simple JSON state tracking
    echo "{\"action\": \"$action\", \"timestamp\": \"$timestamp\"}" >> "$CLAWICU_STATE_FILE"
}

# Get last state
state_last() {
    if [ -f "$CLAWICU_STATE_FILE" ]; then
        tail -1 "$CLAWICU_STATE_FILE"
    fi
}

# Clear state
state_clear() {
    if [ -f "$CLAWICU_STATE_FILE" ]; then
        rm "$CLAWICU_STATE_FILE"
    fi
}

# Rollback: restore from most recent backup
state_rollback() {
    local last_action="$(state_last)"

    if [ -z "$last_action" ]; then
        echo "No state to rollback" >&2
        return 1
    fi

    # Find most recent backup
    local backup_dir="${CLAWICU_BACKUP_DIR:-$HOME/.openclaw/backups}"
    local latest="$(ls -t "$backup_dir"/*.tar.gz 2>/dev/null | head -1)"

    if [ -z "$latest" ]; then
        echo "No backup found to rollback to" >&2
        return 1
    fi

    echo "Rolling back: $last_action"
    backup_restore "$latest"
}
