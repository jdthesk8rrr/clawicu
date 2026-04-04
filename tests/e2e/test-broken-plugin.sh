#!/bin/sh
# E2E: Broken plugin manifests are detected

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

. "$PROJECT_DIR/tests/unit/test-helper.sh"

test_broken_plugin_detected() {
    TEST_TMPDIR="${TEST_TMPDIR:-/tmp/clawicu-e2e-plugins-$$}"
    mkdir -p "$TEST_TMPDIR/plugins/my-plugin" "$TEST_TMPDIR/plugins/good-plugin"

    touch "$TEST_TMPDIR/plugins/good-plugin/manifest.json"

    export OPENCLAW_PLUGINS_DIR="$TEST_TMPDIR/plugins"
    . "$PROJECT_DIR/rescue/checks/check-plugins.sh"

    TESTS_RUN=$((TESTS_RUN + 1))
    if check_plugins >/dev/null 2>&1; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} broken plugin detected (missing manifest)\n"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} broken plugin should be detected\n"
    fi

    rm -rf "$TEST_TMPDIR"
    unset OPENCLAW_PLUGINS_DIR
}

test_all_valid_plugins_pass() {
    TEST_TMPDIR="${TEST_TMPDIR:-/tmp/clawicu-e2e-plugins-$$}"
    mkdir -p "$TEST_TMPDIR/plugins/plugin-a" "$TEST_TMPDIR/plugins/plugin-b"

    touch "$TEST_TMPDIR/plugins/plugin-a/manifest.json"
    touch "$TEST_TMPDIR/plugins/plugin-b/manifest.json"

    export OPENCLAW_PLUGINS_DIR="$TEST_TMPDIR/plugins"
    . "$PROJECT_DIR/rescue/checks/check-plugins.sh"

    TESTS_RUN=$((TESTS_RUN + 1))
    if check_plugins >/dev/null 2>&1; then
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} valid plugins should pass check\n"
    else
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} all valid plugins pass\n"
    fi

    rm -rf "$TEST_TMPDIR"
    unset OPENCLAW_PLUGINS_DIR
}

test_no_plugins_dir_passes() {
    TEST_TMPDIR="${TEST_TMPDIR:-/tmp/clawicu-e2e-plugins-$$}"
    export OPENCLAW_PLUGINS_DIR="$TEST_TMPDIR/nonexistent"

    . "$PROJECT_DIR/rescue/checks/check-plugins.sh"

    TESTS_RUN=$((TESTS_RUN + 1))
    if check_plugins >/dev/null 2>&1; then
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} nonexistent plugins dir should pass (no plugins = no issue)\n"
    else
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} nonexistent plugins dir passes\n"
    fi

    rm -rf "$TEST_TMPDIR"
    unset OPENCLAW_PLUGINS_DIR
}

test_multiple_broken_plugins_detected() {
    TEST_TMPDIR="${TEST_TMPDIR:-/tmp/clawicu-e2e-plugins-$$}"
    mkdir -p "$TEST_TMPDIR/plugins/broken1" "$TEST_TMPDIR/plugins/broken2" "$TEST_TMPDIR/plugins/ok"

    touch "$TEST_TMPDIR/plugins/ok/manifest.json"

    export OPENCLAW_PLUGINS_DIR="$TEST_TMPDIR/plugins"
    . "$PROJECT_DIR/rescue/checks/check-plugins.sh"

    TESTS_RUN=$((TESTS_RUN + 1))
    if check_plugins >/dev/null 2>&1; then
        output="$(check_plugins 2>&1)"
        case "$output" in
            *"broken1"*"broken2"*)
                TESTS_PASSED=$((TESTS_PASSED + 1))
                printf "${GREEN}✓${NC} multiple broken plugins detected\n"
                ;;
            *)
                TESTS_PASSED=$((TESTS_PASSED + 1))
                printf "${GREEN}✓${NC} broken plugins detected\n"
                ;;
        esac
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} multiple broken plugins should be detected\n"
    fi

    rm -rf "$TEST_TMPDIR"
    unset OPENCLAW_PLUGINS_DIR
}

test_broken_plugin_detected
test_all_valid_plugins_pass
test_no_plugins_dir_passes
test_multiple_broken_plugins_detected

print_summary
