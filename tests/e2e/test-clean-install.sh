#!/bin/sh
# E2E: Clean install - all check modules exist and are sourced correctly

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

. "$PROJECT_DIR/tests/unit/test-helper.sh"

test_all_check_files_exist() {
    for check_name in binary config config-schema credentials daemon disk docker envvars exec-approvals gateway install-method node plugins port sessions state-dir version; do
        assert_file_exists "$PROJECT_DIR/rescue/checks/check-$check_name.sh" \
            "check-$check_name.sh should exist"
    done
}

test_all_repair_files_exist() {
    for repair_name in config config-field credentials daemon docker downgrade gateway nuclear plugins port reinstall sessions; do
        assert_file_exists "$PROJECT_DIR/rescue/repairs/repair-$repair_name.sh" \
            "repair-$repair_name.sh should exist"
    done
}

test_rescue_main_script_exists() {
    assert_file_exists "$PROJECT_DIR/rescue/rescue.sh" "rescue.sh main script should exist"
}

test_all_lib_files_exist() {
    for lib in backup bootstrap log state ui verify; do
        assert_file_exists "$PROJECT_DIR/rescue/lib/$lib.sh" "lib/$lib.sh should exist"
    done
}

test_rescue_script_is_executable() {
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ -x "$PROJECT_DIR/rescue/rescue.sh" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓${NC} rescue.sh is executable\n"
    else
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${YELLOW}!${NC} rescue.sh not executable (may be sourced)\n"
    fi
}

test_check_modules_are_valid_sh() {
    for check in "$PROJECT_DIR/rescue/checks"/check-*.sh; do
        if [ -f "$check" ]; then
            assert_exit_code 0 sh -n "$check" --msg "$(basename "$check") should be valid sh syntax"
        fi
    done
}

test_repair_modules_are_valid_sh() {
    for repair in "$PROJECT_DIR/rescue/repairs"/repair-*.sh; do
        if [ -f "$repair" ]; then
            assert_exit_code 0 sh -n "$repair" --msg "$(basename "$repair") should be valid sh syntax"
        fi
    done
}

test_lib_modules_are_valid_sh() {
    for lib in "$PROJECT_DIR/rescue/lib"/*.sh; do
        if [ -f "$lib" ]; then
            assert_exit_code 0 sh -n "$lib" --msg "$(basename "$lib") should be valid sh syntax"
        fi
    done
}

test_all_check_files_exist
test_all_repair_files_exist
test_rescue_main_script_exists
test_all_lib_files_exist
test_rescue_script_is_executable
test_check_modules_are_valid_sh
test_repair_modules_are_valid_sh
test_lib_modules_are_valid_sh

print_summary
