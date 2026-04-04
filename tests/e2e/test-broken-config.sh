#!/bin/sh
# E2E: Broken config is detected by check-config

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

. "$PROJECT_DIR/tests/unit/test-helper.sh"

test_unbalanced_braces_detected() {
    TEST_TMPDIR="${TEST_TMPDIR:-/tmp/clawicu-e2e-config-$$}"
    mkdir -p "$TEST_TMPDIR"

    echo '{ "port": 18789,' > "$TEST_TMPDIR/broken-config.json5"

    export OPENCLAW_CONFIG="$TEST_TMPDIR/broken-config.json5"
    . "$PROJECT_DIR/rescue/checks/check-config.sh"

    TESTS_RUN=$((TESTS_RUN + 1))
    if check_config >/dev/null 2>&1; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} unbalanced braces detected as issue\n"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} unbalanced braces should be detected\n"
    fi

    rm -rf "$TEST_TMPDIR"
}

test_missing_config_detected() {
    TEST_TMPDIR="${TEST_TMPDIR:-/tmp/clawicu-e2e-config-$$}"
    export OPENCLAW_CONFIG="$TEST_TMPDIR/nonexistent-config.json5"

    . "$PROJECT_DIR/rescue/checks/check-config.sh"

    TESTS_RUN=$((TESTS_RUN + 1))
    if check_config >/dev/null 2>&1; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} missing config detected as issue\n"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} missing config should be detected\n"
    fi

    unset OPENCLAW_CONFIG
}

test_empty_config_detected() {
    TEST_TMPDIR="${TEST_TMPDIR:-/tmp/clawicu-e2e-config-$$}"
    mkdir -p "$TEST_TMPDIR"

    echo "" > "$TEST_TMPDIR/empty-config.json5"

    export OPENCLAW_CONFIG="$TEST_TMPDIR/empty-config.json5"
    . "$PROJECT_DIR/rescue/checks/check-config.sh"

    TESTS_RUN=$((TESTS_RUN + 1))
    if check_config >/dev/null 2>&1; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} empty config detected as issue\n"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} empty config should be detected\n"
    fi

    rm -rf "$TEST_TMPDIR"
    unset OPENCLAW_CONFIG
}

test_valid_config_passes() {
    TEST_TMPDIR="${TEST_TMPDIR:-/tmp/clawicu-e2e-config-$$}"
    mkdir -p "$TEST_TMPDIR"

    cat > "$TEST_TMPDIR/valid-config.json5" << 'CFG'
{
  "port": 18789,
  "logLevel": "info"
}
CFG

    export OPENCLAW_CONFIG="$TEST_TMPDIR/valid-config.json5"
    . "$PROJECT_DIR/rescue/checks/check-config.sh"

    TESTS_RUN=$((TESTS_RUN + 1))
    if check_config >/dev/null 2>&1; then
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} valid config should pass (return 1)\n"
    else
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} valid config passes check\n"
    fi

    rm -rf "$TEST_TMPDIR"
    unset OPENCLAW_CONFIG
}

test_check_module_exists() {
    assert_file_exists "$PROJECT_DIR/rescue/checks/check-config.sh" \
        "check-config.sh should exist"
}

test_unbalanced_braces_detected
test_missing_config_detected
test_empty_config_detected
test_valid_config_passes
test_check_module_exists

print_summary
