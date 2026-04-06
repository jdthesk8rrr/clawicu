# ui.sh - Terminal UI with automatic ASCII/Unicode detection

# Terminal width
TERMINAL_WIDTH="${TERMINAL_WIDTH:-$(tput cols 2>/dev/null || echo 80)}"

# Colors
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_CYAN='\033[0;36m'
C_MAGENTA='\033[0;35m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_NC='\033[0m'
C_BG_RED='\033[41m'
C_BG_GREEN='\033[42m'

# ---------------------------------------------------------------------------
# Auto-detect Unicode support.
# Safe if LANG/LC_ALL/LC_CTYPE contains UTF-8, and locale charmap returns UTF-8.
# ---------------------------------------------------------------------------
_detect_unicode() {
    local lang="${LANG:-}${LC_ALL:-}${LC_CTYPE:-}"
    case "$lang" in
        *[Uu][Tt][Ff][-_]8*|*[Uu][Tt][Ff]8*) return 0 ;;
    esac
    if command -v locale >/dev/null 2>&1; then
        case "$(locale charmap 2>/dev/null)" in
            UTF-8|utf-8) return 0 ;;
        esac
    fi
    return 1
}

if _detect_unicode; then
    UI_UNICODE=1
else
    UI_UNICODE=0
fi

# Character sets - chosen once at startup
if [ "$UI_UNICODE" = "1" ]; then
    CH_DIAMOND="*"
    CH_BULLET="*"
    CH_CHECK="[OK]"
    CH_CROSS="[!!]"
    CH_WARN="[!]"
    CH_INFO="[i]"
    CH_SPIN="/-\|"
    CH_HLINE_CHAR="-"
    CH_BAR_FULL="#"
    CH_BAR_EMPTY="-"
    CH_BOX_TL="+"
    CH_BOX_TR="+"
    CH_BOX_BL="+"
    CH_BOX_BR="+"
    CH_BOX_H="-"
    CH_BOX_V="|"
    CH_BOX_LT="+"
    CH_BOX_RT="+"
    # Use Unicode for richer display
    CH_DIAMOND="*"
    CH_CHECK="[OK]"
    CH_CROSS="[!!]"
    CH_WARN="[!]"
    CH_INFO="[i]"
    CH_SPIN="/-\\|"
    CH_HLINE_CHAR="-"
    CH_BAR_FULL="="
    CH_BAR_EMPTY="-"
    CH_DOT="*"
else
    CH_DIAMOND="*"
    CH_CHECK="[OK]"
    CH_CROSS="[!!]"
    CH_WARN="[!]"
    CH_INFO="[i]"
    CH_SPIN="/-\\|"
    CH_HLINE_CHAR="-"
    CH_BAR_FULL="="
    CH_BAR_EMPTY="-"
    CH_DOT="*"
fi

# Clear line
clear_line() {
    printf "\r\033[K"
}

# Print a horizontal rule of dashes
hline() {
    printf '   '
    printf '%*s' "$((TERMINAL_WIDTH - 3))" '' | tr ' ' "$CH_HLINE_CHAR"
    printf '\n'
}

# Simple title box using ASCII
box() {
    local title="$1"
    local width="${2:-60}"
    printf "   +%s+\n" "$(printf '%*s' "$width" '' | tr ' ' '-')"
    printf "   |  %-${width}s|\n" "$title"
    printf "   +%s+\n" "$(printf '%*s' "$width" '' | tr ' ' '-')"
}

# Header - pure ASCII art (safe everywhere)
icu_header() {
    local version="${1:-0.1.0}"
    clear
    printf "\n"
    printf "   ============================================================\n"
    printf "    ____  __    ___  _    _____  ____  __  __\n"
    printf "   / ___||  |  / _ \\| |  |_   _|/ ___||  \\/  |\n"
    printf "  | |    | | | |_| | |    | | | |    | |\\/| |\n"
    printf "  | |___ | |_|  _  | |___ | | | |___ | |  | |\n"
    printf "   \\____||____|_| |_|_____|___|  \\____||_|  |_|\n"
    printf "   OpenClaw Emergency Rescue System\n"
    printf "   ============================================================\n"
    printf "   Version: %s\n" "$version"
    printf "\n"
}

# Compact vital signs display (ASCII-safe)
vital_monitor() {
    local status="$1"
    printf "\n"
    printf "   +-----------------------------------------------+\n"
    printf "   |  ICU VITAL SIGNS MONITOR                      |\n"
    printf "   +-----------------------------------------------+\n"
    case "$status" in
        CRITICAL) printf "   |  STATUS: CRITICAL                             |\n" ;;
        WARNING)  printf "   |  STATUS: WARNING                              |\n" ;;
        STABLE)   printf "   |  STATUS: STABLE                               |\n" ;;
    esac
    printf "   +-----------------------------------------------+\n"
}

# Spinner - returns PID, must be stopped with stop_spinner
icu_spinner() {
    local msg="${1:-Loading}"
    local delay="${2:-0.1}"
    local spin=0
    while true; do
        case $spin in
            0) printf "\r   | %s..." "$msg" ;;
            1) printf "\r   / %s..." "$msg" ;;
            2) printf "\r   - %s..." "$msg" ;;
            3) printf "\r   \\ %s..." "$msg" ;;
        esac
        spin=$(( (spin + 1) % 4 ))
        sleep "$delay"
    done &
    echo $!
}

stop_spinner() {
    local pid="$1"
    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
    clear_line
}

# Progress bar using = and - (ASCII-safe)
progress_bar() {
    local current="$1"
    local total="$2"
    local msg="${3:-Progress}"
    local width=40

    [ "$total" -eq 0 ] && total=1
    local percent=$((current * 100 / total))
    local filled=$((width * current / total))
    [ "$filled" -gt "$width" ] && filled="$width"
    local empty=$((width - filled))

    local bar=""
    local i
    for i in $(seq 1 "$filled"); do bar="${bar}="; done
    for i in $(seq 1 "$empty");  do bar="${bar}-"; done

    printf "\r   [%s] %3d%% %s" "$bar" "$percent" "$msg"
}

# Phase indicator - the line that was showing garbled characters
phase_indicator() {
    local phase="$1"
    local total="$2"
    local name="$3"

    printf "\n"
    printf "   ${C_CYAN}%s${C_NC} ${C_BOLD}Phase %d/%d:${C_NC} ${C_BOLD}%s${C_NC}\n" \
        "$CH_DIAMOND" "$phase" "$total" "$name"
    printf "   ${C_DIM}"
    printf '%*s' "$((TERMINAL_WIDTH - 3))" '' | tr ' ' '-'
    printf "${C_NC}\n"
}

# Check result line
check_result() {
    local status="$1"
    local check_name="$2"
    local message="${3:-}"

    case "$status" in
        OK)
            printf "   ${C_GREEN}%s${C_NC} ${C_BOLD}%s${C_NC}" "$CH_CHECK" "$check_name"
            [ -n "$message" ] && printf " - ${C_GREEN}%s${C_NC}" "$message"
            printf "\n"
            ;;
        FAIL|CRITICAL|FATAL)
            printf "   ${C_RED}%s${C_NC} ${C_BOLD}%s${C_NC}" "$CH_CROSS" "$check_name"
            [ -n "$message" ] && printf " - ${C_RED}%s${C_NC}" "$message"
            printf "\n"
            ;;
        WARN|WARNING)
            printf "   ${C_YELLOW}%s${C_NC} ${C_BOLD}%s${C_NC}" "$CH_WARN" "$check_name"
            [ -n "$message" ] && printf " - ${C_YELLOW}%s${C_NC}" "$message"
            printf "\n"
            ;;
        INFO)
            printf "   ${C_CYAN}%s${C_NC} ${C_BOLD}%s${C_NC}" "$CH_INFO" "$check_name"
            [ -n "$message" ] && printf " - ${C_CYAN}%s${C_NC}" "$message"
            printf "\n"
            ;;
        PROCESSING|RUNNING)
            printf "   ${C_CYAN}...${C_NC} ${C_BOLD}%s${C_NC}" "$check_name"
            [ -n "$message" ] && printf " - ${C_CYAN}%s${C_NC}" "$message"
            printf "\r"
            ;;
    esac
}

# Rescue announcement box (ASCII-safe)
rescue_announce() {
    local type="$1"
    local message="$2"

    printf "\n"
    case "$type" in
        START)
            printf "   ${C_MAGENTA}+---------------------------------------+${C_NC}\n"
            printf "   ${C_MAGENTA}|${C_NC}  ${C_BOLD}${C_MAGENTA}[!!] INITIATING EMERGENCY RESCUE${C_NC}    ${C_MAGENTA}|${C_NC}\n"
            printf "   ${C_MAGENTA}+---------------------------------------+${C_NC}\n"
            ;;
        ING)
            printf "   ${C_YELLOW}+---------------------------------------+${C_NC}\n"
            printf "   ${C_YELLOW}|${C_NC}  ${C_BOLD}${C_YELLOW}[>>] ICU RESCUING -- STANDBY${C_NC}        ${C_YELLOW}|${C_NC}\n"
            printf "   ${C_YELLOW}+---------------------------------------+${C_NC}\n"
            ;;
        COMPLETE)
            printf "   ${C_GREEN}+---------------------------------------+${C_NC}\n"
            printf "   ${C_GREEN}|${C_NC}  ${C_BOLD}${C_GREEN}[OK] RESCUE COMPLETE - STABLE${C_NC}       ${C_GREEN}|${C_NC}\n"
            printf "   ${C_GREEN}+---------------------------------------+${C_NC}\n"
            ;;
        FAILED)
            printf "   ${C_RED}+---------------------------------------+${C_NC}\n"
            printf "   ${C_RED}|${C_NC}  ${C_BOLD}${C_RED}[!!] RESCUE FAILED - CRITICAL${C_NC}       ${C_RED}|${C_NC}\n"
            printf "   ${C_RED}+---------------------------------------+${C_NC}\n"
            ;;
    esac
    printf "\n"
}

# Heartbeat line - simple ASCII animation
heartbeat_line() {
    local delay="${1:-0.05}"
    local count="${2:-2}"
    local i
    for i in $(seq 1 "$count"); do
        printf "\r   |  .  .  "
        sleep "$delay"
        printf "\r   | /\\ /\\ "
        sleep "$delay"
        printf "\r   |/  V  \\"
        sleep "$delay"
    done
    clear_line
}

# ECG flatline
ecg_flatline() {
    printf "\r   ${C_DIM}------------------------------------------------${C_NC} "
}

# Menu box
icu_menu() {
    local title="$1"
    local width="${2:-50}"
    printf "\n"
    printf "   +%s+\n" "$(printf '%*s' "$width" '' | tr ' ' '-')"
    printf "   |  %s\n" "$title"
    printf "   +%s+\n" "$(printf '%*s' "$width" '' | tr ' ' '-')"
}

# Scan line (simplified)
scan_line() {
    local i
    for i in $(seq 1 20); do
        printf "\r   [%s%s]" "$(printf '%*s' "$i" '' | tr ' ' '=')" "$(printf '%*s' "$((20-i))" '' | tr ' ' '-')"
        sleep 0.03
    done
    clear_line
}

# Pulse OK (simple)
pulse_ok() {
    local delay="${1:-0.5}"
    printf "   <3 "
    sleep "$delay"
    printf "\b\b\b   "
    sleep "$delay"
}

# Visual beep
visual_beep() {
    printf "\a"
    sleep 0.1
    printf "\a"
}
