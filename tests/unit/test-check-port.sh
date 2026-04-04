#!/bin/sh
# test-check-port.sh - Tests for check-port.sh

type assert_equals >/dev/null 2>&1 || . "$(dirname "$0")/test-helper.sh"

test_port_default_is_18789() {
    local port="${OPENCLAW_GATEWAY_PORT:-18789}"
    assert_equals "18789" "$port" "Default port should be 18789"
}

test_port_custom_value() {
    OPENCLAW_GATEWAY_PORT=8080
    local port="${OPENCLAW_GATEWAY_PORT:-18789}"
    assert_equals "8080" "$port" "Custom port should be respected"
    unset OPENCLAW_GATEWAY_PORT
}

test_port_occupied_message() {
    local msg="Port 18789 is occupied by process: nginx"
    assert_contains "$msg" "occupied" "Should report port occupied"
    assert_contains "$msg" "nginx" "Should mention process name"
}

test_port_in_use_message() {
    local msg="Port 18789 is already in use"
    assert_contains "$msg" "already in use" "Should report port in use"
}

test_port_severity_is_fatal() {
    local severity="fatal"
    assert_equals "fatal" "$severity" "Port check severity should be fatal"
}

test_port_uses_lsof_on_macos() {
    local os="$(uname -s)"
    if [ "$os" = "Darwin" ]; then
        if command -v lsof >/dev/null 2>&1; then
            local result="$(lsof -i :99999 -sTCP:LISTEN 2>/dev/null | tail -1 | awk '{print $1}')"
            assert_equals "" "$result" "Unused port should return empty"
        else
            assert_equals "skip" "skip" "lsof not available, skip"
        fi
    else
        assert_equals "skip" "skip" "Not macOS, skip lsof test"
    fi
}
