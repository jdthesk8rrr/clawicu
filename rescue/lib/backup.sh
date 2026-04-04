#!/bin/sh
# backup.sh - tar.gz backup engine with create/restore/list/verify

# Backup directory
CLAWICU_BACKUP_DIR="${CLAWICU_BACKUP_DIR:-$HOME/.openclaw/backups}"

# Create a timestamped backup
backup_create() {
    local label="${1:-manual}"
    local backup_dir="$CLAWICU_BACKUP_DIR"
    local timestamp="$(date '+%Y%m%d-%H%M%S')"
    local backup_name="clawicu-$label-$timestamp.tar.gz"
    local backup_path="$backup_dir/$backup_name"

    mkdir -p "$backup_dir"

    # Backup state directory
    local state_dir="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"

    tar -czf "$backup_path" -C "$state_dir" . 2>/dev/null || true

    # Create manifest
    echo "$timestamp" > "$backup_path.meta"
    echo "$label" >> "$backup_path.meta"

    echo "$backup_path"
}

# Restore from backup
backup_restore() {
    local backup_path="$1"
    local state_dir="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"

    if [ ! -f "$backup_path" ]; then
        echo "Backup not found: $backup_path" >&2
        return 1
    fi

    # Create a safety backup first
    local safety_backup="$state_dir.pre-restore-$(date '+%Y%m%d-%H%M%S').tar.gz"
    tar -czf "$safety_backup" -C "$state_dir" . 2>/dev/null || true

    # Restore
    tar -xzf "$backup_path" -C "$state_dir"
}

# List backups
backup_list() {
    local backup_dir="$CLAWICU_BACKUP_DIR"

    if [ ! -d "$backup_dir" ]; then
        echo "No backups found"
        return
    fi

    ls -lht "$backup_dir"/*.tar.gz 2>/dev/null | awk '{print $6, $7, $8, $9}' || echo "No backups found"
}

# Verify backup integrity
backup_verify() {
    local backup_path="$1"

    if [ ! -f "$backup_path" ]; then
        return 1
    fi

    tar -tzf "$backup_path" >/dev/null 2>&1
}

# Leverage openclaw backup if available
backup_try_openclaw() {
    if command -v openclaw >/dev/null 2>&1; then
        openclaw backup "$@" 2>/dev/null
        return $?
    fi
    return 1
}
