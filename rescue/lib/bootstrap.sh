# bootstrap.sh - OS/shell detection, install method detection, temp dir setup

set -e

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*) echo "linux" ;;
        *)      echo "unknown" ;;
    esac
}

# Detect architecture
detect_arch() {
    case "$(uname -m)" in
        x86_64)  echo "x86_64" ;;
        arm64|aarch64) echo "arm64" ;;
        *)       echo "unknown" ;;
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
        # Check if it's a global npm install
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

# Create temp working directory with trap cleanup
bootstrap_init() {
    local work_dir="${CLAWICU_TMPDIR:-/tmp/clawicu-$$}"
    mkdir -p "$work_dir"

    # Set trap to cleanup on exit
    trap "rm -rf $work_dir" EXIT INT TERM

    echo "$work_dir"
}

# Main bootstrap
bootstrap() {
    CLAWICU_OS="$(detect_os)"
    CLAWICU_ARCH="$(detect_arch)"
    CLAWICU_SHELL="$(detect_shell)"
    CLAWICU_INSTALL_METHOD="$(detect_install_method)"
    CLAWICU_TMPDIR="$(bootstrap_init)"

    export CLAWICU_OS CLAWICU_ARCH CLAWICU_SHELL CLAWICU_INSTALL_METHOD CLAWICU_TMPDIR
}
