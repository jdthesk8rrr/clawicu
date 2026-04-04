#!/bin/sh
# repair-nuclear.sh - Full state reset preserving credentials (HIGH RISK)

set -e

# Source dependencies
. "$(dirname "$0")/../lib/bootstrap.sh"
. "$(dirname "$0")/../lib/backup.sh"
. "$(dirname "$0")/../lib/state.sh"
. "$(dirname "$0")/../lib/log.sh"

repair_nuclear() {
    describe() {
        echo "FULL STATE RESET - Preserve only credentials, reset everything else (HIGH RISK)"
    }

    dry_run() {
        echo "What would happen:"
        echo "  - *** WARNING: THIS IS A DESTRUCTIVE OPERATION ***"
        echo "  - Create comprehensive backup of entire ~/.openclaw/"
        echo "  - Backup credentials directory separately"
        echo "  - Remove ALL state except credentials/"
        echo "  - Remove sessions, plugins, config, logs, cache"
        echo "  - Reinitialize with fresh default config"
        echo "  - Restore credentials from backup"
        echo "  - You will need to reconfigure everything else"
    }

    # Print extensive warning and require confirmation
    _warn_and_confirm() {
        echo "" >&2
        log_warn "=============================================="
        log_warn "  *** HIGH RISK OPERATION ***"
        log_warn "=============================================="
        log_warn ""
        log_warn "This will RESET your entire OpenClaw state:"
        log_warn "  - ALL sessions will be destroyed"
        log_warn "  - ALL plugins will be removed"
        log_warn "  - ALL configuration will be reset to defaults"
        log_warn "  - ALL logs and cache will be cleared"
        log_warn ""
        log_warn "Only your API credentials will be preserved."
        log_warn ""
        log_warn "A full backup will be created, but this is"
        log_warn "still the most aggressive repair available."
        log_warn ""
        log_warn "=============================================="
        printf "Type 'NUCLEAR-RESET' to proceed: " >&2

        read -r confirmation
        if [ "$confirmation" != "NUCLEAR-RESET" ]; then
            log_info "Nuclear reset cancelled by user"
            return 1
        fi
        return 0
    }

    # Backup credentials separately for safety
    _backup_credentials() {
        local state_dir="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
        local cred_dir="$state_dir/credentials"
        local cred_backup="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}/credentials-backup-$(date '+%Y%m%d-%H%M%S')"

        if [ -d "$cred_dir" ]; then
            cp -r "$cred_dir" "$cred_backup"
            chmod 700 "$cred_backup" 2>/dev/null || true
            echo "$cred_backup"
        else
            echo ""
        fi
    }

    # Remove all state except credentials
    _nuke_state() {
        local state_dir="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"

        for item in "$state_dir"/*; do
            [ -e "$item" ] || continue
            local name
            name=$(basename "$item")

            case "$name" in
                credentials)
                    # Preserve credentials
                    log_info "Preserving: $name/"
                    ;;
                credentials-backup-*)
                    # Preserve credential backups
                    log_info "Preserving: $name/"
                    ;;
                backups)
                    # Preserve backups for rollback
                    log_info "Preserving: $name/"
                    ;;
                *)
                    log_info "Removing: $name"
                    rm -rf "$item"
                    ;;
            esac
        done
    }

    # Reinitialize with fresh defaults
    _reinitialize() {
        local state_dir="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"

        # Create directory structure
        mkdir -p "$state_dir/sessions"
        mkdir -p "$state_dir/plugins"
        mkdir -p "$state_dir/logs"
        mkdir -p "$state_dir/cache"

        # Create minimal default config
        cat > "$state_dir/config.json5" <<'DEFCONFIG'
{
  // OpenClaw Configuration - Reset to defaults
  // Re-run openclaw setup to configure providers
  "version": "1.0.0",
  "gateway": {
    "port": 18789,
    "host": "127.0.0.1"
  },
  "providers": {},
  "plugins": []
}
DEFCONFIG

        log_info "Fresh config initialized"
    }

    execute() {
        log_info "Starting NUCLEAR repair..."
        log_warn "This is a HIGH RISK operation"

        # Require explicit confirmation
        if ! _warn_and_confirm; then
            return 1
        fi

        local state_dir="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"

        if [ ! -d "$state_dir" ]; then
            log_warn "State directory does not exist: $state_dir"
            log_info "Nothing to nuke, creating fresh state"
            mkdir -p "$state_dir"
            _reinitialize
            return 0
        fi

        # Create comprehensive backup
        log_info "Creating comprehensive backup..."
        local backup_path
        backup_path="$(backup_create "repair-nuclear")"
        log_info "Full backup created: $backup_path"

        state_push "repair-nuclear"

        # Backup credentials separately
        local cred_backup
        cred_backup=$(_backup_credentials)
        if [ -n "$cred_backup" ]; then
            log_info "Credentials backed up to: $cred_backup"
        else
            log_warn "No credentials directory found to preserve"
        fi

        # Nuke everything except credentials and backups
        log_warn "Removing all state (preserving credentials)..."
        _nuke_state

        # Reinitialize with fresh config
        log_info "Reinitializing with fresh defaults..."
        _reinitialize

        # Verify credentials survived
        if [ -d "$state_dir/credentials" ]; then
            local cred_count
            cred_count=$(ls "$state_dir/credentials/" 2>/dev/null | wc -l | tr -d ' ')
            log_info "Credentials preserved: $cred_count file(s)"
        fi

        log_info "Nuclear reset completed"
        log_warn "You will need to reconfigure OpenClaw (providers, plugins, etc.)"
        log_info "A full backup is available at: $backup_path"
        return 0
    }
}
