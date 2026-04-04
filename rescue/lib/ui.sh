# ui.sh - ICU风格界面：动画、心电图、体征监控
set -e

# Terminal width (default 80)
TERMINAL_WIDTH="${TERMINAL_WIDTH:-$(tput cols 2>/dev/null || echo 80)}"

# Colors - ICU Medical Theme
C_RED='\033[0;31m'       # Critical/Fatal
C_GREEN='\033[0;32m'     # Healthy/OK
C_YELLOW='\033[1;33m'     # Warning
C_CYAN='\033[0;36m'      # Info/Processing
C_MAGENTA='\033[0;35m'    # Accent
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_NC='\033[0m'            # No Color
C_BG_RED='\033[41m'       # Critical background
C_BG_GREEN='\033[42m'     # OK background

# ECG Animation characters
ECG_CHARS="▁▂▃▄▅▆▇█▇▆▅▄▃▂▁"

# Vital signs symbols
VITAL_HEART="♥"
VITAL_PULSE="◉"
VITAL_LOADING="◐◑◒◓"

# Clear line
clear_line() {
    printf "\r\033[K"
}

# Print horizontal line
hline() {
    printf '%*s\n' "$TERMINAL_WIDTH" '' | tr ' ' '─'
}

# Double line box
box() {
    local title="$1"
    local width="${2:-60}"
    local padding=$(( (TERMINAL_WIDTH - width - 2) / 2 ))
    local pad=$(( padding > 0 ? padding : 0 ))
    
    printf "%${pad}s╔%${width}s╗\n" '' '' | tr ' ' '─'
    printf "%${pad}s║%${width}s║\n" '' " $title "
    printf "%${pad}s╚%${width}s╝\n" '' '' | tr ' ' '─'
}

# ICU Monitor Header - Animated
icu_header() {
    local version="${1:-0.1.0}"
    clear
    cat << 'EOF'

   ██╗    ██╗ █████╗ ███████╗███████╗██╗
   ██║    ██║██╔══██╗██╔════╝██╔════╝██║
   ██║ █╗ ██║███████║███████╗███████╗██║
   ██║███╗██║██╔══██║╚════██║╚════██║██║
   ╚███╔███╔╝██║  ██║███████║███████║███████╗
    ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝
   
   ██████╗ ███████╗██████╗ ██╗      █████╗ ███████╗██╗ ██████╗ ███╗
   ██╔══██╗██╔════╝██╔══██╗██║     ██╔══██╗██╔════╝██║██╔═══██╗████╗ 
   ██████╔╝█████╗  ██████╔╝██║     ███████║███████╗██║██║   ██║██╔██╗ 
   ██╔══██╗██╔══╝  ██╔══██╗██║     ██╔══██║╚════██║██║██║   ██║██║╚██╗
   ██║  ██║███████╗██████╔╝███████╗██║  ██║███████║██║╚██████╔╝██║ ╚██╗
   ╚═╝  ╚═╝╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚██╗
EOF
    printf "\n"
    printf "   ${C_CYAN}◆${C_NC} OpenClaw Emergency Rescue System ${C_CYAN}◆${C_NC}\n"
    printf "   ${C_DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_NC}\n"
    printf "   Version: ${C_BOLD}%s${C_NC} | ICU Mode: ${C_GREEN}● ACTIVE${C_NC}\n" "$version"
    printf "\n"
}

# ICU Vital Signs Monitor Display
vital_monitor() {
    local status="$1"      # CRITICAL/WARNING/STABLE
    local heartbeat="$2"   # heartbeat rate
    local spo2="$3"        # oxygen saturation
    local temp="$4"        # temperature
    
    printf "\n"
    printf "   ┌─────────────────────────────────────────────────────────────────┐\n"
    printf "   │${C_BOLD}  ICU VITAL SIGNS MONITOR${C_NC}                                      │\n"
    printf "   ├─────────────────────────────────────────────────────────────────┤\n"
    
    # Status indicator
    case "$status" in
        CRITICAL)
            printf "   │ ${C_RED}● STATUS: CRITICAL${C_NC}                                           │\n"
            ;;
        WARNING)
            printf "   │ ${C_YELLOW}● STATUS: WARNING${C_NC}                                            │\n"
            ;;
        STABLE)
            printf "   │ ${C_GREEN}● STATUS: STABLE${C_NC}                                             │\n"
            ;;
    esac
    
    printf "   │                                                         │\n"
    printf "   │  ${VITAL_HEART} Heart Rate: ${C_BOLD}%s BPM${C_NC}          ${VITAL_PULSE} SpO2: ${C_BOLD}%s%%%C_NC          🌡️ Temp: ${C_BOLD}%s°C${C_NC}  │\n" "$heartbeat" "$spo2" "$temp"
    printf "   │                                                         │\n"
    printf "   └─────────────────────────────────────────────────────────────────┘\n"
}

# Animated heartbeat line
heartbeat_line() {
    local delay="${1:-0.05}"
    local count="${2:-3}"
    
    for i in $(seq 1 "$count"); do
        for char in $(echo "$ECG_CHARS" | sed 's/\(.\)/\1 /g'); do
            printf "\r   ${C_RED}%s${C_NC} " "$char"
            sleep "$delay"
        done
    done
    clear_line
}

# ECG flatline (for dramatic effect)
ecg_flatline() {
    printf "\r   ${C_DIM}%s${C_NC} " "▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
}

# Loading spinner with ICU theme
icu_spinner() {
    local msg="${1:-Loading}"
    local delay="${2:-0.1}"
    local spin=0
    
    while true; do
        case $spin in
            0) printf "\r   ${C_CYAN}◐${C_NC} ${msg}..." ;;
            1) printf "\r   ${C_CYAN}◑${C_NC} ${msg}..." ;;
            2) printf "\r   ${C_CYAN}◒${C_NC} ${msg}..." ;;
            3) printf "\r   ${C_CYAN}◓${C_NC} ${msg}..." ;;
        esac
        spin=$(( (spin + 1) % 4 ))
        sleep "$delay"
    done &
    echo $!
}

# Stop spinner
stop_spinner() {
    local pid="$1"
    kill "$pid" 2>/dev/null
    wait "$pid" 2>/dev/null
    clear_line
}

# Progress bar with percentage
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
    for i in $(seq 1 "$filled"); do
        bar="${bar}█"
    done
    for i in $(seq 1 "$empty"); do
        bar="${bar}░"
    done
    
    printf "\r   [%s] %3d%% %s" "$bar" "$percent" "$msg"
}

# Phase indicator with animation
phase_indicator() {
    local phase="$1"
    local total="$2"
    local name="$3"
    
    printf "\n"
    printf "   ${C_CYAN}◆${C_NC} ${C_BOLD}Phase %d/%d:${C_NC} ${C_BOLD}%s${C_NC}\n" "$phase" "$total" "$name"
    printf "   ${C_DIM}"
    printf '%*s' "$TERMINAL_WIDTH" '' | tr ' ' '─'
    printf "${C_NC}\n"
}

# Check result with dramatic output
check_result() {
    local status="$1"      # OK/FAIL/WARN/INFO
    local check_name="$2"
    local message="${3:-}"
    
    case "$status" in
        OK)
            printf "   ${C_GREEN}✓${C_NC} ${C_BOLD}%s${C_NC}" "$check_name"
            [ -n "$message" ] && printf " — ${C_GREEN}%s${C_NC}" "$message"
            printf "\n"
            ;;
        FAIL|CRITICAL|FATAL)
            printf "   ${C_RED}✗${C_NC} ${C_BOLD}%s${C_NC}" "$check_name"
            [ -n "$message" ] && printf " — ${C_RED}%s${C_NC}" "$message"
            printf "\n"
            ;;
        WARN|WARNING)
            printf "   ${C_YELLOW}⚠${C_NC} ${C_BOLD}%s${C_NC}" "$check_name"
            [ -n "$message" ] && printf " — ${C_YELLOW}%s${C_NC}" "$message"
            printf "\n"
            ;;
        INFO)
            printf "   ${C_CYAN}ℹ${C_NC} ${C_BOLD}%s${C_NC}" "$check_name"
            [ -n "$message" ] && printf " — ${C_CYAN}%s${C_NC}" "$message"
            printf "\n"
            ;;
        PROCESSING|RUNNING)
            printf "   ${C_CYAN}◐${C_NC} ${C_BOLD}%s${C_NC}" "$check_name"
            [ -n "$message" ] && printf " — ${C_CYAN}%s${C_NC}" "$message"
            printf "\r"
            ;;
    esac
}

# Dramatic rescue announcement
rescue_announce() {
    local type="$1"   # START/ING/COMPLETE/FAILED
    local message="$2"
    
    printf "\n"
    case "$type" in
        START)
            printf "   ${C_MAGENTA}┌───────────────────────────────────────┐${C_NC}\n"
            printf "   ${C_MAGENTA}│${C_NC}  ${C_BOLD}${C_MAGENTA}🚨 INITIATING EMERGENCY RESCUE 🚨${C_NC}  ${C_MAGENTA}│${C_NC}\n"
            printf "   ${C_MAGENTA}└───────────────────────────────────────┘${C_NC}\n"
            ;;
        ING)
            printf "   ${C_YELLOW}┌───────────────────────────────────────┐${C_NC}\n"
            printf "   ${C_YELLOW}│${C_NC}  ${C_BOLD}${C_YELLOW}🚑 ICU RESCUING — STANDBY 🚑${C_NC}    ${C_YELLOW}│${C_NC}\n"
            printf "   ${C_YELLOW}└───────────────────────────────────────┘${C_NC}\n"
            ;;
        COMPLETE)
            printf "   ${C_GREEN}┌───────────────────────────────────────┐${C_NC}\n"
            printf "   ${C_GREEN}│${C_NC}  ${C_BOLD}${C_GREEN}✅ RESCUE COMPLETE — PATIENT STABLE ✅${C_NC}  ${C_GREEN}│${C_NC}\n"
            printf "   ${C_GREEN}└───────────────────────────────────────┘${C_NC}\n"
            ;;
        FAILED)
            printf "   ${C_RED}┌───────────────────────────────────────┐${C_NC}\n"
            printf "   ${C_RED}│${C_NC}  ${C_BOLD}${C_RED}❌ RESCUE FAILED — CRITICAL ❌${C_NC}    ${C_RED}│${C_NC}\n"
            printf "   ${C_RED}└───────────────────────────────────────┘${C_NC}\n"
            ;;
    esac
    printf "\n"
}

# Animated scan line
scan_line() {
    local direction="${1:-left}"  # left or right
    local width=60
    local i
    
    if [ "$direction" = "right" ]; then
        for i in $(seq 0 "$width"); do
            printf "\r   ${C_CYAN}%*s${C_NC}" "$i" "█"
            sleep 0.02
        done
    else
        for i in $(seq "$width" -1 0); do
            printf "\r   ${C_CYAN}%*s${C_NC}" "$i" "█"
            sleep 0.02
        done
    fi
    clear_line
}

# Menu box with ICU styling
icu_menu() {
    local title="$1"
    local width="${2:-50}"
    
    printf "\n"
    printf "   ${C_BOLD}╭%${width}s╮${C_NC}\n" '' | tr ' ' '─'
    printf "   ${C_BOLD}│${C_NC}  ${C_BOLD}%s${C_NC}\n" "$title"
    printf "   ${C_BOLD}╰%${width}s╯${C_NC}\n" '' | tr ' ' '─'
}

# Pulse animation for OK status
pulse_ok() {
    local delay="${1:-0.5}"
    printf "   ${C_GREEN}♥${C_NC} "
    sleep "$delay"
    printf "\b\b  "
    sleep "$delay"
}

# Terminal beep effect (visual)
visual_beep() {
    printf "\a"
    sleep 0.1
    printf "\a"
}
