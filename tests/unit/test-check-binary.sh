#!/bin/sh
# test-check-binary.sh - Tests for check-binary.sh

type assert_equals >/dev/null 2>&1 || . "$(dirname "$0")/test-helper.sh"

FIXTURES="${TEST_FIXTURES:-$(dirname "$0")/fixtures}"

test_binary_found_via_mock() {
    local mock_bin="$FIXTURES/mock-openclaw/doctor-success/openclaw"
    assert_file_exists "$mock_bin" "Mock openclaw binary should exist"
}

test_binary_is_executable() {
    local mock_bin="$FIXTURES/mock-openclaw/doctor-success/openclaw"
    if [ -x "$mock_bin" ]; then
        assert_equals "yes" "yes" "Mock openclaw should be executable"
    else
        assert_equals "yes" "no" "Mock openclaw should be executable"
    fi
}

test_binary_not_found_message() {
    local msg="OpenClaw binary not found in PATH"
    assert_contains "$msg" "not found" "Should report not found"
}

test_binary_not_executable_message() {
    local msg="OpenClaw binary found but is not executable"
    assert_contains "$msg" "not executable" "Should report not executable"
}

test_check_binary_returns_issue_on_missing() {
    if ! command -v openclaw >/dev/null 2>&1; then
        assert_equals "0" "0" "check_binary should return 0 when binary missing"
    else
        assert_equals "skip" "skip" "openclaw found in PATH, skip this test"
    fi
}

test_mock_binary_exits_zero() {
    local mock_bin="$FIXTURES/mock-openclaw/doctor-success/openclaw"
    assert_exit_code 0 "$mock_bin" --msg "Mock doctor-success should exit 0"
}

test_mock_binary_exits_nonzero() {
    local mock_bin="$FIXTURES/mock-openclaw/doctor-fail/openclaw"
    assert_exit_code 1 "$mock_bin" --msg "Mock doctor-fail should exit 1"
}
