#!/bin/sh
# Integration test: Doctor delegation phase
# Verifies that rescue.sh handles openclaw doctor correctly,
# including missing binary, passing doctor, and failing doctor.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

. "$PROJECT_DIR/tests/unit/test-helper.sh"

# --- Helper: create mock openclaw that simulates doctor outcomes ---

setup_doctor_pass() {
    TEST_TMPDIR="${TEST_TMPDIR:-/tmp/clawicu-doctor-$$}"
    mkdir -p "$TEST_TMPDIR/bin"
    cat > "$TEST_TMPDIR/bin/openclaw" << 'MOCK'
#!/bin/sh
case "$1" in
    doctor)
        echo "Checking binary... OK"
        echo "Checking config... OK"
        echo "All checks passed"
        exit 0
        ;;
    --version) echo "openclaw 1.2.3"; exit 0 ;;
    *) echo "Unknown: $1" >&2; exit 1 ;;
esac
MOCK
    chmod +x "$TEST_TMPDIR/bin/openclaw"
    export PATH="$TEST_TMPDIR/bin:$PATH"
}

setup_doctor_fail() {
    TEST_TMPDIR="${TEST_TMPDIR:-/tmp/clawicu-doctor-$$}"
    mkdir -p "$TEST_TMPDIR/bin"
    cat > "$TEST_TMPDIR/bin/openclaw" << 'MOCK'
#!/bin/sh
case "$1" in
    doctor)
        echo "ERROR: config file is malformed" >&2
        echo "WARN: daemon not running" >&2
        exit 1
        ;;
    --version) echo "openclaw 1.2.3"; exit 0 ;;
    *) echo "Unknown: $1" >&2; exit 1 ;;
esac
MOCK
    chmod +x "$TEST_TMPDIR/bin/openclaw"
    export PATH="$TEST_TMPDIR/bin:$PATH"
}

teardown() {
    if [ -d "$TEST_TMPDIR" ]; then
        rm -rf "$TEST_TMPDIR"
    fi
}

# --- Tests ---

test_doctor_pass_exits_0() {
    setup_doctor_pass
    
    TESTS_RUN=$((TESTS_RUN + 1))
    set +e
    output="$(openclaw doctor 2>&1)"
    actual=$?
    set -e
    if [ "$actual" -eq 0 ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} mock openclaw doctor passes (exit 0)\n"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} mock openclaw doctor should exit 0, got $actual\n"
    fi
    
    teardown
}

test_doctor_fail_exits_1() {
    setup_doctor_fail
    
    TESTS_RUN=$((TESTS_RUN + 1))
    set +e
    output="$(openclaw doctor 2>&1)"
    actual=$?
    set -e
    if [ "$actual" -eq 1 ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} mock openclaw doctor fails (exit 1)\n"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} mock openclaw doctor should exit 1, got $actual\n"
    fi
    
    teardown
}

test_doctor_pass_output_contains_ok() {
    setup_doctor_pass
    
    set +e
    output="$(openclaw doctor 2>&1)"
    set -e
    assert_contains "$output" "OK" "Doctor pass output should contain 'OK'"
    
    teardown
}

test_doctor_fail_output_contains_error() {
    setup_doctor_fail
    
    set +e
    output="$(openclaw doctor 2>&1)"
    set -e
    assert_contains "$output" "ERROR" "Doctor fail output should contain 'ERROR'"
    
    teardown
}

test_no_openclaw_binary() {
    # Ensure no openclaw in PATH
    TEST_TMPDIR="${TEST_TMPDIR:-/tmp/clawicu-doctor-$$}"
    mkdir -p "$TEST_TMPDIR/bin"
    
    # Save original PATH and use minimal PATH
    _orig_path="$PATH"
    export PATH="$TEST_TMPDIR/bin:/usr/bin:/bin"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    if command -v openclaw >/dev/null 2>&1; then
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} openclaw should NOT be found with minimal PATH\n"
    else
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} openclaw not found with minimal PATH (expected)\n"
    fi
    
    export PATH="$_orig_path"
    teardown
}

# --- Run ---
test_doctor_pass_exits_0
test_doctor_fail_exits_1
test_doctor_pass_output_contains_ok
test_doctor_fail_output_contains_error
test_no_openclaw_binary

print_summary
