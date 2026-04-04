#!/bin/sh
# repair-reinstall.sh - Complete clean reinstall of OpenClaw (HIGH RISK)

set -e

# Source dependencies
. "$(dirname "$0")/../lib/bootstrap.sh"
. "$(dirname "$0")/../lib/backup.sh"
. "$(dirname "$0")/../lib/state.sh"
. "$(dirname "$0")/../lib/log.sh"

repair_reinstall() {
    describe() {
        echo "Complete clean reinstall of OpenClaw (MOST DESTRUCTIVE)"
    }

    dry_run() {
        echo "What would happen:"
        echo "  - *** WARNING: THIS IS THE MOST DESTRUCTIVE REPAIR ***"
        echo "  - Create full backup of ALL OpenClaw data"
        echo "  - Stop any running OpenClaw processes"
        echo "  - Uninstall OpenClaw completely (npm/Docker)"
        echo "  - Remove ~/.openclaw/ entirely"
        echo "  - Perform a clean fresh install"
        echo "  - Nothing is preserved - start from scratch"
        echo "  - Backup is kept for manual recovery"
    }

    # Print extensive warning and require double confirmation
    _warn_and_confirm() {
        echo "" >&2
        log_warn "=============================================="
        log_warn "  *** MOST DESTRUCTIVE OPERATION ***"
        log_warn "=============================================="
        log_warn ""
        log_warn "This will COMPLETELY REMOVE OpenClaw:"
        log_warn "  - ALL data will be destroyed"
        log_warn "  - ALL sessions, plugins, config GONE"
        log_warn "  - ALL credentials will be destroyed"
        log_warn "  - The application itself will be uninstalled"
        log_warn "  - Then reinstalled fresh from scratch"
        log_warn ""
        log_warn "A backup will be made, but this is the"
        log_warn "LAST RESORT. Try other repairs first."
        log_warn ""
        log_warn "=============================================="
        printf "Type 'FULL-REINSTALL' to proceed: " >&2

        read -r confirmation1
        if [ "$confirmation1" != "FULL-REINSTALL" ]; then
            log_info "Reinstall cancelled by user"
            return 1
        fi

        printf "Are you ABSOLUTELY sure? Type 'YES' to confirm: " >&2
        read -r confirmation2
        if [ "$confirmation2" != "YES" ]; then
            log_info "Reinstall cancelled by user"
            return 1
        fi

        return 0
    }

    # Stop any running OpenClaw processes
    _stop_processes() {
        log_info "Stopping OpenClaw processes..."

        # Try graceful stop first
        if command -v openclaw >/dev/null 2>&1; then
            openclaw stop 2>/dev/null || true
        fi

        # Kill any remaining processes
        local pids
        pids=$(pgrep -f "openclaw" 2>/dev/null || true)
        if [ -n "$pids" ]; then
            log_warn "Killing remaining OpenClaw processes: $pids"
            echo "$pids" | xargs kill 2>/dev/null || true
            sleep 2
            echo "$pids" | xargs kill -9 2>/dev/null || true
        fi
    }

    # Uninstall OpenClaw based on install method
    _uninstall() {
        local install_method="$1"

        case "$install_method" in
            npm-global)
                log_info "Uninstalling via npm (global)..."
                npm uninstall -g openclaw 2>&1 || true
                ;;
            npm-local)
                log_info "Uninstalling via npm (local)..."
                npm uninstall openclaw 2>&1 || true
                ;;
            docker)
                log_info "Removing Docker container..."
                docker rm -f openclaw 2>/dev/null || true
                ;;
            podman)
                log_info "Removing Podman container..."
                podman rm -f openclaw 2>/dev/null || true
                ;;
            *)
                log_warn "Unknown install method: $install_method"
                log_info "Attempting npm uninstall as fallback..."
                npm uninstall -g openclaw 2>&1 || true
                ;;
        esac
    }

    # Clean install OpenClaw
    _clean_install() {
        local install_method="$1"

        case "$install_method" in
            npm-global|npm-local|unknown)
                log_info "Installing OpenClaw fresh via npm..."
                npm install -g openclaw 2>&1
                return $?
                ;;
            docker)
                log_info "Creating fresh Docker container..."
                docker run -d --name openclaw openclaw:latest 2>&1
                return $?
                ;;
            podman)
                log_info "Creating fresh Podman container..."
                podman run -d --name openclaw openclaw:latest 2>&1
                return $?
                ;;
            *)
                log_info "Attempting npm install..."
                npm install -g openclaw 2>&1
                return $?
                ;;
        esac
    }

    # Verify installation works
    _verify_install() {
        if command -v openclaw >/dev/null 2>&1; then
            local version
            version=$(openclaw --version 2>/dev/null || echo "unknown")
            log_info "OpenClaw installed: version $version"
            return 0
        fi

        # Check Docker
        if docker ps 2>/dev/null | grep -q openclaw; then
            log_info "OpenClaw container is running"
            return 0
        fi

        return 1
    }

    execute() {
        log_info "Starting REINSTALL repair..."
        log_warn "This is the MOST DESTRUCTIVE repair option"

        # Require double confirmation
        if ! _warn_and_confirm; then
            return 1
        fi

        local install_method="$CLAWICU_INSTALL_METHOD"
        local state_dir="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"

        # Create full backup before anything
        log_info "Creating full backup of all data..."
        local backup_path
        backup_path="$(backup_create "repair-reinstall")"
        log_info "Full backup created: $backup_path"
        log_info "This backup will be preserved even after reinstall"

        state_push "repair-reinstall"

        # Stop processes
        _stop_processes

        # Uninstall
        log_info "Uninstalling current OpenClaw..."
        _uninstall "$install_method"

        # Remove all state data
        if [ -d "$state_dir" ]; then
            log_warn "Removing state directory: $state_dir"
            rm -rf "$state_dir"
        fi

        # Clean install
        log_info "Performing clean install..."
        if ! _clean_install "$install_method"; then
            log_fatal "Clean install failed. Backup is at: $backup_path"
            return 1
        fi

        # Verify
        if _verify_install; then
            log_info "Reinstall completed successfully"
            log_info "Backup of previous installation: $backup_path"
            log_warn "You need to set up OpenClaw from scratch (credentials, config, plugins)"
            return 0
        else
            log_fatal "Verification failed after reinstall"
            log_info "Backup is available at: $backup_path"
            return 1
        fi
    }
}
