#!/bin/sh
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TEST_TMPDIR="${TEST_TMPDIR:-/tmp/clawicu-test-$$}"

_test_setup() {
    mkdir -p "$TEST_TMPDIR"
}

_test_teardown() {
    if [ -d "$TEST_TMPDIR" ]; then
        rm -rf "$TEST_TMPDIR"
    fi
}

# assert_equals expected actual "message"
assert_equals() {
    _ae_expected="$1"
    _ae_actual="$2"
    _ae_msg="${3:-}"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ "$_ae_expected" = "$_ae_actual" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} %s\\n" "$_ae_msg"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} %s\\n" "$_ae_msg"
        printf "  Expected: '%s'\\n" "$_ae_expected"
        printf "  Actual:   '%s'\\n" "$_ae_actual"
        return 1
    fi
}

# assert_contains "haystack" "needle" "message"
assert_contains() {
    _ac_haystack="$1"
    _ac_needle="$2"
    _ac_msg="${3:-}"
    TESTS_RUN=$((TESTS_RUN + 1))
    case "$_ac_haystack" in
        *"$_ac_needle"*)
            TESTS_PASSED=$((TESTS_PASSED + 1))
            printf "${GREEN}✓${NC} %s\\n" "$_ac_msg"
            return 0
            ;;
        *)
            TESTS_FAILED=$((TESTS_FAILED + 1))
            printf "${RED}✗${NC} %s\\n" "$_ac_msg"
            printf "  Expected to contain: '%s'\\n" "$_ac_needle"
            printf "  In: '%s'\\n" "$_ac_haystack"
            return 1
            ;;
    esac
}

# assert_not_contains "haystack" "needle" "message"
assert_not_contains() {
    _anc_haystack="$1"
    _anc_needle="$2"
    _anc_msg="${3:-}"
    TESTS_RUN=$((TESTS_RUN + 1))
    case "$_anc_haystack" in
        *"$_anc_needle"*)
            TESTS_FAILED=$((TESTS_FAILED + 1))
            printf "${RED}✗${NC} %s\\n" "$_anc_msg"
            printf "  Expected NOT to contain: '%s'\\n" "$_anc_needle"
            printf "  In: '%s'\\n" "$_anc_haystack"
            return 1
            ;;
        *)
            TESTS_PASSED=$((TESTS_PASSED + 1))
            printf "${GREEN}✓${NC} %s\\n" "$_anc_msg"
            return 0
            ;;
    esac
}

# assert_file_exists "filepath" "message"
assert_file_exists() {
    _afe_file="$1"
    _afe_msg="${2:-File exists: $_afe_file}"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ -f "$_afe_file" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} %s\\n" "$_afe_msg"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} %s\\n" "$_afe_msg"
        printf "  File not found: %s\\n" "$_afe_file"
        return 1
    fi
}

# assert_dir_exists "dirpath" "message"
assert_dir_exists() {
    _ade_dir="$1"
    _ade_msg="${2:-Directory exists: $_ade_dir}"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ -d "$_ade_dir" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} %s\\n" "$_ade_msg"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} %s\\n" "$_ade_msg"
        printf "  Directory not found: %s\\n" "$_ade_dir"
        return 1
    fi
}

# assert_exit_code expected command [args...] --msg "message"
assert_exit_code() {
    _aec_expected="$1"
    shift
    _aec_msg=""
    _aec_cmd=""
    _aec_found_delim=0
    for _aec_arg in "$@"; do
        if [ "$_aec_arg" = "--msg" ]; then
            _aec_found_delim=1
            continue
        fi
        if [ "$_aec_found_delim" -eq 1 ]; then
            _aec_msg="$_aec_arg"
        else
            if [ -z "$_aec_cmd" ]; then
                _aec_cmd="$_aec_arg"
            else
                _aec_cmd="$_aec_cmd $_aec_arg"
            fi
        fi
    done
    if [ -z "$_aec_msg" ]; then
        _aec_msg="Exit code $_aec_expected: $_aec_cmd"
    fi
    TESTS_RUN=$((TESTS_RUN + 1))
    # shellcheck disable=SC2086
    eval "$_aec_cmd" >/dev/null 2>&1
    _aec_actual=$?
    if [ "$_aec_actual" -eq "$_aec_expected" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} %s\\n" "$_aec_msg"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} %s\\n" "$_aec_msg"
        printf "  Expected exit code: %s\\n" "$_aec_expected"
        printf "  Actual exit code:   %s\\n" "$_aec_actual"
        return 1
    fi
}

# assert_num_equals expected actual "message"
assert_num_equals() {
    _ane_expected="$1"
    _ane_actual="$2"
    _ane_msg="${3:-}"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ "$_ane_expected" -eq "$_ane_actual" ] 2>/dev/null; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} %s\\n" "$_ane_msg"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        printf "${RED}✗${NC} %s\\n" "$_ane_msg"
        printf "  Expected: %s\\n" "$_ane_expected"
        printf "  Actual:   %s\\n" "$_ane_actual"
        return 1
    fi
}

print_summary() {
    printf "\\n"
    printf "Tests run: %s\\n" "$TESTS_RUN"
    printf "Passed:    %s\\n" "$TESTS_PASSED"
    printf "Failed:    %s\\n" "$TESTS_FAILED"
    if [ "$TESTS_FAILED" -gt 0 ]; then
        printf "${RED}FAILED${NC}\\n"
        return 1
    else
        printf "${GREEN}ALL PASSED${NC}\\n"
        return 0
    fi
}

mock_openclaw() {
    mkdir -p "$TEST_TMPDIR"
    cat > "$TEST_TMPDIR/openclaw" << 'MOCK'
#!/bin/sh
case "$1" in
    doctor) exit 0 ;;
    --version) echo "openclaw 1.2.3" ;;
    *) exit 1 ;;
esac
MOCK
    chmod +x "$TEST_TMPDIR/openclaw"
}

_test_setup
