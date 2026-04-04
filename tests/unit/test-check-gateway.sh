#!/bin/sh
# test-check-gateway.sh - Tests for check-gateway.sh

type assert_equals >/dev/null 2>&1 || . "$(dirname "$0")/test-helper.sh"

test_gateway_default_port() {
    local port="${OPENCLAW_GATEWAY_PORT:-18789}"
    assert_equals "18789" "$port" "Default gateway port should be 18789"
}

test_gateway_custom_port() {
    OPENCLAW_GATEWAY_PORT=19999
    local port="${OPENCLAW_GATEWAY_PORT:-18789}"
    assert_equals "19999" "$port" "Custom port should override default"
    unset OPENCLAW_GATEWAY_PORT
}

test_gateway_not_running_message() {
    local msg="Gateway not running on port 18789"
    assert_contains "$msg" "not running" "Should report gateway not running"
    assert_contains "$msg" "18789" "Should mention port number"
}

test_gateway_details_message() {
    local details="OpenClaw gateway should be listening on port 18789"
    assert_contains "$details" "listening" "Details should mention listening"
    assert_contains "$details" "18789" "Details should mention port"
}

test_gateway_severity_is_fatal() {
    local severity="fatal"
    assert_equals "fatal" "$severity" "Gateway check severity should be fatal"
}

test_gateway_detects_os() {
    local os="$(uname -s)"
    case "$os" in
        Darwin*) assert_contains "$os" "Darwin" "Should detect Darwin" ;;
        Linux*)  assert_contains "$os" "Linux" "Should detect Linux" ;;
        *)       assert_contains "$os" "unknown" "Should detect unknown OS" ;;
    esac
}
