#!/bin/sh
# E2E: Daemon not installed is detected

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

. "$PROJECT_DIR/tests/unit/test-helper.sh"

test_daemon_missing_detected() {
    TEST_TMPDIR="${TEST_TMPDIR:-/tmp/clawicu-e2e-daemon-$$}"
    mkdir -p "$TEST_TMPDIR/home"
    export HOME="$TEST_TMPDIR/home"

    . "$PROJECT_DIR/rescue/checks/check-daemon.sh"

    TESTS_RUN=$((TESTS_RUN + 1))
    if check_daemon >/dev/null 2>&1; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} missing daemon detected\n"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} missing daemon should be detected\n"
    fi

    rm -rf "$TEST_TMPDIR"
}

test_daemon_check_module_exists() {
    assert_file_exists "$PROJECT_DIR/rescue/checks/check-daemon.sh" \
        "check-daemon.sh should exist"
}

test_daemon_check_sets_severity_warn() {
    TEST_TMPDIR="${TEST_TMPDIR:-/tmp/clawicu-e2e-daemon-$$}"
    mkdir -p "$TEST_TMPDIR/home"
    export HOME="$TEST_TMPDIR/home"

    . "$PROJECT_DIR/rescue/checks/check-daemon.sh"
    check_daemon >/dev/null 2>&1 || true

    assert_equals "warn" "$SEVERITY" "daemon check severity should be warn"

    rm -rf "$TEST_TMPDIR"
}

test_daemon_missing_sets_message() {
    TEST_TMPDIR="${TEST_TMPDIR:-/tmp/clawicu-e2e-daemon-$$}"
    mkdir -p "$TEST_TMPDIR/home"
    export HOME="$TEST_TMPDIR/home"

    . "$PROJECT_DIR/rescue/checks/check-daemon.sh"
    check_daemon >/dev/null 2>&1 || true

    case "$(uname -s)" in
        Darwin*)
            assert_contains "$MESSAGE" "launchd" "daemon message should mention launchd on macOS"
            ;;
        Linux*)
            assert_contains "$MESSAGE" "systemd" "daemon message should mention systemd on Linux"
            ;;
    esac

    rm -rf "$TEST_TMPDIR"
}

test_daemon_missing_detected
test_daemon_check_module_exists
test_daemon_check_sets_severity_warn
test_daemon_missing_sets_message

print_summary
