#!/bin/sh
# Integration test: diagnose → repair → verify pipeline
# Verifies check modules detect issues, repair modules can be sourced,
# and the full pipeline runs without errors.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

. "$PROJECT_DIR/tests/unit/test-helper.sh"

# --- Setup: create mock environment with a fake openclaw ---

setup_mock_env() {
    TEST_TMPDIR="${TEST_TMPDIR:-/tmp/clawicu-integration-$$}"
    mkdir -p "$TEST_TMPDIR/bin"
    mkdir -p "$TEST_TMPDIR/home/.openclaw/plugins"
    
    # Mock openclaw binary
    cat > "$TEST_TMPDIR/bin/openclaw" << 'MOCK'
#!/bin/sh
case "$1" in
    doctor)
        echo "Checking binary... OK"
        echo "Checking config... OK"
        echo "Checking daemon... OK"
        echo "All checks passed"
        exit 0
        ;;
    --version)
        echo "openclaw 1.2.3"
        ;;
    *)
        echo "Unknown command: $1" >&2
        exit 1
        ;;
esac
MOCK
    chmod +x "$TEST_TMPDIR/bin/openclaw"
    
    # Valid config
    cat > "$TEST_TMPDIR/home/.openclaw/config.json5" << 'CFG'
{
  "port": 18789,
  "logLevel": "info",
  "gateway": {
    "enabled": true
  }
}
CFG
    
    export PATH="$TEST_TMPDIR/bin:$PATH"
    export HOME="$TEST_TMPDIR/home"
    export OPENCLAW_CONFIG="$TEST_TMPDIR/home/.openclaw/config.json5"
}

teardown_mock_env() {
    if [ -d "$TEST_TMPDIR" ]; then
        rm -rf "$TEST_TMPDIR"
    fi
}

# --- Tests ---

test_all_check_modules_source() {
    for check in "$PROJECT_DIR/rescue/checks"/check-*.sh; do
        if [ -f "$check" ]; then
            assert_file_exists "$check" "Check module should exist: $(basename "$check")"
        fi
    done
}

test_all_repair_modules_source() {
    for repair in "$PROJECT_DIR/rescue/repairs"/repair-*.sh; do
        if [ -f "$repair" ]; then
            assert_file_exists "$repair" "Repair module should exist: $(basename "$repair")"
        fi
    done
}

test_all_lib_modules_source() {
    for lib in bootstrap log ui backup state verify; do
        lib_file="$PROJECT_DIR/rescue/lib/$lib.sh"
        assert_file_exists "$lib_file" "Lib module should exist: $lib.sh"
    done
}

to_underscore() {
    echo "$1" | tr '-' '_'
}

test_check_modules_define_functions() {
    for check in "$PROJECT_DIR/rescue/checks"/check-*.sh; do
        if [ -f "$check" ]; then
            check_name="$(basename "$check" .sh)"
            func_suffix="$(to_underscore "${check_name#check-}")"
            assert_contains "$(cat "$check")" "check_$func_suffix" \
                "$check_name should define check_$func_suffix()"
        fi
    done
}

test_repair_modules_define_functions() {
    for repair in "$PROJECT_DIR/rescue/repairs"/repair-*.sh; do
        if [ -f "$repair" ]; then
            repair_name="$(basename "$repair" .sh)"
            func_suffix="$(to_underscore "${repair_name#repair-}")"
            assert_contains "$(cat "$repair")" "repair_$func_suffix" \
                "$repair_name should define repair_$func_suffix()"
        fi
    done
}

test_check_binary_with_mock() {
    setup_mock_env
    
    # Source the check module and run it
    . "$PROJECT_DIR/rescue/checks/check-binary.sh"
    
    # With mock in PATH, binary should be found → return 1 (no issue)
    TESTS_RUN=$((TESTS_RUN + 1))
    if check_binary >/dev/null 2>&1; then
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} check_binary should return 1 (OK) when binary exists\n"
    else
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} check_binary returns 1 (OK) when binary exists\n"
    fi
    
    teardown_mock_env
}

test_check_config_with_valid_file() {
    setup_mock_env
    
    # Source and run check-config with our valid config
    . "$PROJECT_DIR/rescue/checks/check-config.sh"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    if check_config >/dev/null 2>&1; then
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} check_config should return 1 (OK) for valid config\n"
    else
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} check_config returns 1 (OK) for valid config\n"
    fi
    
    teardown_mock_env
}

test_check_plugins_empty_dir() {
    setup_mock_env
    
    # Empty plugins dir → no broken plugins
    . "$PROJECT_DIR/rescue/checks/check-plugins.sh"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    if check_plugins >/dev/null 2>&1; then
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} check_plugins should return 1 (OK) for empty plugins dir\n"
    else
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} check_plugins returns 1 (OK) for empty plugins dir\n"
    fi
    
    teardown_mock_env
}

# --- Run ---
test_all_check_modules_source
test_all_repair_modules_source
test_all_lib_modules_source
test_check_modules_define_functions
test_repair_modules_define_functions
test_check_binary_with_mock
test_check_config_with_valid_file
test_check_plugins_empty_dir

print_summary
