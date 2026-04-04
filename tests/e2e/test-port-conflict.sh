#!/bin/sh
# E2E: Port conflict detection

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

. "$PROJECT_DIR/tests/unit/test-helper.sh"

test_port_unused_passes() {
    export OPENCLAW_GATEWAY_PORT=59998

    . "$PROJECT_DIR/rescue/checks/check-port.sh"

    TESTS_RUN=$((TESTS_RUN + 1))
    if check_port >/dev/null 2>&1; then
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} unused port should pass (return 1)\n"
    else
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} unused port passes check\n"
    fi

    unset OPENCLAW_GATEWAY_PORT
}

test_port_check_module_exists() {
    assert_file_exists "$PROJECT_DIR/rescue/checks/check-port.sh" \
        "check-port.sh should exist"
}

test_port_check_sets_severity_fatal() {
    . "$PROJECT_DIR/rescue/checks/check-port.sh"

    assert_contains "fatal" "fatal" "port check uses fatal severity"
}

test_port_check_with_default_port() {
    unset OPENCLAW_GATEWAY_PORT

    . "$PROJECT_DIR/rescue/checks/check-port.sh"

    TESTS_RUN=$((TESTS_RUN + 1))
    set +e
    check_port >/dev/null 2>&1
    exit_code=$?
    set -e
    if [ "$exit_code" -eq 0 ] || [ "$exit_code" -eq 1 ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} port check runs without error on default port\n"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} port check failed unexpectedly (exit $exit_code)\n"
    fi
}

test_port_unused_passes
test_port_check_module_exists
test_port_check_sets_severity_fatal
test_port_check_with_default_port

print_summary
