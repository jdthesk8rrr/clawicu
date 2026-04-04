#!/bin/sh
# E2E: Gateway not running is detected

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

. "$PROJECT_DIR/tests/unit/test-helper.sh"

test_gateway_down_detected() {
    export OPENCLAW_GATEWAY_PORT=59999

    . "$PROJECT_DIR/rescue/checks/check-gateway.sh"

    TESTS_RUN=$((TESTS_RUN + 1))
    if check_gateway >/dev/null 2>&1; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} gateway down on unused port detected\n"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} gateway down should be detected on unused port\n"
    fi

    unset OPENCLAW_GATEWAY_PORT
}

test_gateway_check_module_exists() {
    assert_file_exists "$PROJECT_DIR/rescue/checks/check-gateway.sh" \
        "check-gateway.sh should exist"
}

test_gateway_check_sets_severity_fatal() {
    . "$PROJECT_DIR/rescue/checks/check-gateway.sh"
    
    export OPENCLAW_GATEWAY_PORT=59999
    check_gateway >/dev/null 2>&1 || true
    
    assert_equals "fatal" "$SEVERITY" "gateway check severity should be fatal"
    
    unset OPENCLAW_GATEWAY_PORT
}

test_gateway_down_sets_message() {
    export OPENCLAW_GATEWAY_PORT=59999
    
    . "$PROJECT_DIR/rescue/checks/check-gateway.sh"
    check_gateway >/dev/null 2>&1 || true
    
    assert_contains "$MESSAGE" "not running" "gateway check message should mention not running"
    
    unset OPENCLAW_GATEWAY_PORT
}

test_gateway_down_detected
test_gateway_check_module_exists
test_gateway_check_sets_severity_fatal
test_gateway_down_sets_message

print_summary
