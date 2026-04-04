#!/bin/sh
# ClawICU - OpenClaw Emergency Rescue Script
# OS: {{OS}}, Version: {{VERSION}}
# Generated: {{TIMESTAMP}}

set -e

VERSION="{{VERSION}}"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

printf "${CYAN}=== ClawICU v${VERSION} - OpenClaw Emergency Rescue ===${RESET}\n\n"

detect_os() {
    if [ "$(uname)" = "Darwin" ]; then
        printf "${GREEN}[OK]${RESET} OS: macOS\n"
    else
        printf "${GREEN}[OK]${RESET} OS: Linux\n"
    fi
}

check_openclaw() {
    printf "${CYAN}[DIAG]${RESET} Checking OpenClaw installation...\n"
    if command -v openclaw >/dev/null 2>&1; then
        printf "${GREEN}[OK]${RESET} OpenClaw found at: $(command -v openclaw)\n"
        return 0
    fi
    printf "${YELLOW}[WARN]${RESET} OpenClaw not found in PATH\n"
    return 1
}

check_process() {
    printf "${CYAN}[DIAG]${RESET} Checking OpenClaw process...\n"
    if pgrep -f "openclaw" > /dev/null 2>&1; then
        printf "${GREEN}[OK]${RESET} OpenClaw is running (PID: $(pgrep -f openclaw | head -1))\n"
        return 0
    fi
    printf "${YELLOW}[WARN]${RESET} OpenClaw is not running\n"
    return 1
}

find_config() {
    CONFIG_DIR="${HOME}/.openclaw"
    CONFIG_FILE="${CONFIG_DIR}/config.yaml"
    printf "${CYAN}[DIAG]${RESET} Config: ${CONFIG_FILE}\n"
    if [ -f "${CONFIG_FILE}" ]; then
        printf "${GREEN}[OK]${RESET} Config file exists\n"
    else
        printf "${YELLOW}[WARN]${RESET} Config file not found\n"
    fi
}

printf "${CYAN}[DIAG]${RESET} Running diagnosis...\n"
detect_os
check_openclaw
check_process
find_config

printf "\n${CYAN}[INFO]${RESET} To repair issues, run: openclaw repair\n"
printf "${CYAN}[INFO]${RESET} For full menu: curl -fsSL https://xagent.icu/rescue.sh | sh\n"
