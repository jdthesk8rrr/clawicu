#!/bin/sh
# repair-downgrade.sh - Downgrade OpenClaw to a stable version

set -e

# Source dependencies
. "$(dirname "$0")/../lib/bootstrap.sh"
. "$(dirname "$0")/../lib/backup.sh"
. "$(dirname "$0")/../lib/state.sh"
. "$(dirname "$0")/../lib/log.sh"

repair_downgrade() {
    describe() {
        echo "Downgrade OpenClaw to a previous stable version"
    }

    dry_run() {
        echo "What would happen:"
        echo "  - Detect current OpenClaw version"
        echo "  - Prompt for target version or detect latest stable"
        echo "  - Create full backup of current installation"
        echo "  - Uninstall current version"
        echo "  - Install the target version via npm"
        echo "  - Verify the installed version matches target"
        echo "  - Roll back on failure"
    }

    # Get current version
    _current_version() {
        if command -v openclaw >/dev/null 2>&1; then
            openclaw --version 2>/dev/null || echo "unknown"
        else
            echo "not-installed"
        fi
    }

    # Get latest stable version from npm
    _latest_stable() {
        if command -v npm >/dev/null 2>&1; then
            npm view openclaw versions --json 2>/dev/null \
                | tail -5 \
                | grep -oE '"[0-9]+\.[0-9]+\.[0-9]+"' \
                | tr -d '"' \
                | tail -1
        else
            echo ""
        fi
    }

    # Prompt user for target version
    # Args: $1 = current version
    _prompt_version() {
        local current="$1"
        local stable
        stable=$(_latest_stable)

        printf "Current version: %s\n" "$current" >&2
        if [ -n "$stable" ]; then
            printf "Latest stable:   %s\n" "$stable" >&2
        fi
        printf "Enter target version to downgrade to: " >&2

        read -r target
        echo "$target"
    }

    # Install a specific version
    # Args: $1 = version string
    _install_version() {
        local version="$1"

        if ! command -v npm >/dev/null 2>&1; then
            log_fatal "npm is required for downgrade but not found"
            return 1
        fi

        log_info "Installing openclaw@$version..."
        npm install -g "openclaw@$version" 2>&1
        return $?
    }

    # Verify installed version matches target
    # Args: $1 = expected version
    _verify_version() {
        local expected="$1"
        local actual
        actual=$(_current_version)

        if [ "$actual" = "$expected" ]; then
            return 0
        fi

        # Handle version prefix differences (v1.0.0 vs 1.0.0)
        case "$actual" in
            "v$expected") return 0 ;;
        esac
        case "$expected" in
            "v$actual") return 0 ;;
        esac

        log_warn "Version mismatch: expected $expected, got $actual"
        return 1
    }

    execute() {
        log_info "Starting downgrade repair..."

        # Check prerequisites
        if ! command -v npm >/dev/null 2>&1; then
            log_fatal "npm is required for downgrade. Please install Node.js first."
            return 1
        fi

        local current_version
        current_version=$(_current_version)
        log_info "Current version: $current_version"

        if [ "$current_version" = "not-installed" ]; then
            log_warn "OpenClaw is not currently installed. Use repair-reinstall instead."
            return 1
        fi

        # Determine target version
        local target_version="${OPENCLAW_DOWNGRADE_VERSION:-}"

        if [ -z "$target_version" ]; then
            target_version=$(_prompt_version "$current_version")
        fi

        if [ -z "$target_version" ]; then
            log_fatal "No target version specified"
            return 1
        fi

        log_info "Target version: $target_version"

        if [ "$current_version" = "$target_version" ]; then
            log_info "Already at target version, nothing to do"
            return 0
        fi

        # Create backup before downgrade
        local backup_path
        backup_path="$(backup_create "repair-downgrade")"
        log_info "Backup created: $backup_path"
        state_push "repair-downgrade"

        # Perform downgrade
        if _install_version "$target_version"; then
            log_info "Installation completed"
        else
            log_warn "Installation failed, attempting rollback..."
            _install_version "$current_version" || true
            state_rollback
            log_fatal "Downgrade failed, attempted rollback to $current_version"
            return 1
        fi

        # Verify
        if _verify_version "$target_version"; then
            log_info "Downgrade to $target_version completed successfully"
            return 0
        else
            log_warn "Verification failed, rolling back..."
            _install_version "$current_version" || true
            state_rollback
            return 1
        fi
    }
}
