# ui.sh - Menu rendering, prompts, spinners, box drawing

set -e

# Terminal width (default 80)
TERMINAL_WIDTH="${TERMINAL_WIDTH:-$(tput cols 2>/dev/null || echo 80)}"

# Clear line
clear_line() {
    printf "\r\033[K"
}

# Print a horizontal line
hline() {
    printf '%*s\n' "$TERMINAL_WIDTH" '' | tr ' ' '─'
}

# Print a box with title
box() {
    local title="$1"
    local width="${2:-60}"
    local padding=$(( (TERMINAL_WIDTH - width) / 2 ))

    printf "%${padding}s┌%${width}s┐\n" '' '' | tr ' ' '─'
    printf "%${padding}s│%${width}s│\n" '' " $title "
    printf "%${padding}s└%${width}s┘\n" '' '' | tr ' ' '─'
}

# Menu prompt (returns selected option letter)
menu_prompt() {
    local prompt="$1"
    local options="$2"  # comma-separated like "a,b,c"

    printf "%s [%s]: " "$prompt" "$options"
    read -r choice
    echo "$choice"
}

# Confirm prompt (yes/no)
confirm() {
    local prompt="$1"
    local default="${2:-n}"

    printf "%s [%s]: " "$prompt" "$default"
    read -r answer

    if [ -z "$answer" ]; then
        answer="$default"
    fi

    case "$answer" in
        y|Y) return 0 ;;
        *)   return 1 ;;
    esac
}

# Spinner (for background tasks) - bash 4+ only
# Falls back to simple animation for bash 3 / POSIX sh
spinner_start() {
    local pid="$1"
    local delay="${2:-0.1}"
    local spinstr='|/-\'

    while kill -0 "$pid" 2>/dev/null; do
        local temp="${spinstr#?}"
        printf " [%c]  " "$spinstr"
        spinstr="$temp${spinstr%"$temp"}"
        sleep "$delay"
        clear_line
    done
    printf " [✓]  \n"
}

# Progress bar
progress_bar() {
    local current="$1"
    local total="$2"
    local width="${3:-40}"
    local percent=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))

    printf "\rProgress: [%${filled}s%${empty}s] %3d%%" '' '' "$percent"
}
