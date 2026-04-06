# bootstrap.sh - OS/shell detection, install method detection, temp dir setup
# NOTE: Do NOT put 'set -e' here - the bundle inlines all modules into one
# script and set -e from individual modules causes premature exits.

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        *)       echo "unknown" ;;
    esac
}

# Detect architecture
detect_arch() {
    case "$(uname -m)" in
        x86_64)        echo "x86_64" ;;
        arm64|aarch64) echo "arm64" ;;
        *)             echo "unknown" ;;
    esac
}

# Detect shell capabilities
detect_shell() {
    if [ -n "$BASH_VERSION" ]; then
        if [ "${BASH_VERSION%%.*}" -ge 4 ]; then
            echo "bash4"
        else
            echo "bash3"
        fi
    elif [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    else
        echo "sh"
    fi
}

# Detect install method (npm/Docker/Podman/source)
detect_install_method() {
    # Check if running in Docker
    if [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
        echo "docker"
        return
    fi

    # Check if openclaw is installed via npm
    if command -v openclaw >/dev/null 2>&1; then
        if [ -d "$HOME/.npm" ] || [ -d "/usr/local/lib/node_modules/openclaw" ]; then
            echo "npm-global"
            return
        fi
        echo "npm-local"
        return
    fi

    # Check if podman is available
    if command -v podman >/dev/null 2>&1; then
        echo "podman"
        return
    fi

    # Check for source install
    if [ -f "$HOME/openclaw/openclaw" ] || [ -f "/usr/local/bin/openclaw" ]; then
        echo "source"
        return
    fi

    echo "unknown"
}

# Main bootstrap - creates the temp working directory in the CURRENT shell
# so the trap and mkdir both take effect in the parent process (not a subshell).
bootstrap() {
    CLAWICU_OS="$(detect_os)"
    CLAWICU_ARCH="$(detect_arch)"
    CLAWICU_SHELL="$(detect_shell)"
    CLAWICU_INSTALL_METHOD="$(detect_install_method)"

    # Determine and create the temp dir directly here (NOT via $(...) subshell).
    # Using $(...) would run the mkdir inside a subshell whose EXIT trap would
    # immediately delete the directory before the parent shell can use it.
    CLAWICU_TMPDIR="${CLAWICU_TMPDIR:-/tmp/clawicu-$$}"
    mkdir -p "$CLAWICU_TMPDIR"

    # Register cleanup trap in the current (parent) shell
    # shellcheck disable=SC2064
    trap "rm -rf '$CLAWICU_TMPDIR'" EXIT INT TERM

    export CLAWICU_OS CLAWICU_ARCH CLAWICU_SHELL CLAWICU_INSTALL_METHOD CLAWICU_TMPDIR
}
