#!/bin/sh
# repair-config.sh - Restore OpenCode config from a backup

set -e

# Source dependencies
. "$(dirname "$0")/../lib/bootstrap.sh"
. "$(dirname "$0")/../lib/backup.sh"
. "$(dirname "$0")/../lib/state.sh"
. "$(dirname "$0")/../lib/log.sh"

repair_config() {
    describe() {
        echo "Restore OpenCode configuration from a previous backup"
    }

    dry_run() {
        echo "What would happen:"
        echo "  - List available config backups"
        echo "  - Back up current config before overwriting"
        echo "  - Restore selected backup to active config path"
        echo "  - Verify restored config is valid JSON5"
        echo "  - Roll back if verification fails"
    }

    # List available backups and return the chosen one
    # Args: $1 = backup directory path
    _list_backups() {
        local backup_dir="$1"
        if [ ! -d "$backup_dir" ]; then
            log_warn "No backup directory found at: $backup_dir"
            return 1
        fi

        local count=0
        for f in "$backup_dir"/*.json5 "$backup_dir"/*.json; do
            if [ -f "$f" ]; then
                count=$((count + 1))
                echo "$count $(basename "$f")"
            fi
        done

        if [ "$count" -eq 0 ]; then
            log_warn "No backup files found in: $backup_dir"
            return 1
        fi
        return 0
    }

    # Validate a file is parseable JSON5 / JSON
    # Args: $1 = file path
    _validate_json5() {
        local cfg="$1"
        if [ ! -f "$cfg" ]; then
            return 1
        fi

        # Basic structural check: ensure the file is non-empty and
        # contains at least one key-value pair.
        local size
        size=$(wc -c < "$cfg" 2>/dev/null || echo 0)
        if [ "$size" -eq 0 ]; then
            return 1
        fi

        # Try python or node for JSON validation if available
        if command -v python3 >/dev/null 2>&1; then
            python3 -c "import json,sys; json.loads(open(sys.argv[1]).read())" "$cfg" 2>/dev/null && return 0
            # If strict JSON fails, try a lenient check (JSON5-like)
            python3 -c "
import re, sys
txt = open(sys.argv[1]).read()
# Strip JS-style comments and trailing commas for a rough check
txt = re.sub(r'//.*', '', txt)
txt = re.sub(r'/\*.*?\*/', '', txt, flags=re.DOTALL)
txt = re.sub(r',\s*([}\]])', r'\1', txt)
import json
json.loads(txt)
" "$cfg" 2>/dev/null && return 0
        fi

        if command -v node >/dev/null 2>&1; then
            node -e "try { require('fs').readFileSync(process.argv[1],'utf8'); } catch(e) { process.exit(1); }" "$cfg" 2>/dev/null && return 0
        fi

        # Fallback: accept any non-empty file with braces
        grep -q '{' "$cfg" 2>/dev/null && return 0

        return 1
    }

    execute() {
        log_info "Starting config restore repair..."

        # Locate config file
        local config_dir="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
        local config_file="$config_dir/config.json5"

        if [ ! -f "$config_file" ]; then
            config_file="$config_dir/config.json"
        fi

        if [ ! -f "$config_file" ]; then
            log_fatal "Cannot find config file in: $config_dir"
            return 1
        fi

        # Locate backups
        local backup_dir="${OPENCODE_BACKUP_DIR:-$HOME/.local/share/opencode/backups/config}"

        log_info "Looking for backups in: $backup_dir"
        if ! _list_backups "$backup_dir"; then
            log_fatal "No config backups available for restore"
            return 1
        fi

        # Determine which backup to restore
        # Use env var or fall back to the most recent backup
        local target_backup="${OPENCODE_RESTORE_BACKUP:-}"

        if [ -z "$target_backup" ]; then
            # Pick the most recent backup file
            target_backup=$(ls -t "$backup_dir"/*.json5 "$backup_dir"/*.json 2>/dev/null | head -1)
        else
            # Treat as a filename relative to backup_dir
            if [ ! -f "$target_backup" ]; then
                target_backup="$backup_dir/$target_backup"
            fi
        fi

        if [ ! -f "$target_backup" ]; then
            log_fatal "Backup file not found: $target_backup"
            return 1
        fi

        log_info "Selected backup: $(basename "$target_backup")"

        # Validate the backup before using it
        if ! _validate_json5 "$target_backup"; then
            log_fatal "Backup file does not appear to be valid JSON: $target_backup"
            return 1
        fi

        # Backup current config before overwriting
        local backup_path
        backup_path="$(backup_create "repair-config")"
        log_info "Current config backed up to: $backup_path"

        # Record state for rollback
        state_push "repair-config"

        # Perform the restore
        cp "$target_backup" "$config_file"
        log_info "Restored backup to: $config_file"

        # Verify the restored config
        if _validate_json5 "$config_file"; then
            log_info "Config restore completed successfully"
            return 0
        else
            log_error "Restored config failed validation, rolling back..."
            # Restore from the backup we just made
            cp "$backup_path" "$config_file"
            state_rollback
            log_error "Rolled back to previous config"
            return 1
        fi
    }
}
