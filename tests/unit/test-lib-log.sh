#!/bin/sh
# test-lib-log.sh - Tests for lib/log.sh

type assert_equals >/dev/null 2>&1 || . "$(dirname "$0")/test-helper.sh"

test_log_default_level() {
    local level="${CLAWICU_LOG_LEVEL:-INFO}"
    assert_equals "INFO" "$level" "Default log level should be INFO"
}

test_log_custom_level() {
    CLAWICU_LOG_LEVEL="DEBUG"
    local level="${CLAWICU_LOG_LEVEL:-INFO}"
    assert_equals "DEBUG" "$level" "Custom log level should override default"
    unset CLAWICU_LOG_LEVEL
}

test_log_timestamp_format() {
    local ts="$(date '+%Y-%m-%d %H:%M:%S')"
    assert_contains "$ts" "$(date '+%Y')" "Timestamp should contain current year"
    assert_contains "$ts" ":" "Timestamp should contain time separators"
}

test_log_file_default_empty() {
    local log_file="${CLAWICU_LOG_FILE:-}"
    assert_equals "" "$log_file" "Default log file should be empty"
}

test_log_fatal_color_defined() {
    local color='\033[0;31m'
    assert_equals "$color" "$color" "FATAL color should be red"
}

test_log_warn_color_defined() {
    local color='\033[0;33m'
    assert_equals "$color" "$color" "WARN color should be yellow"
}

test_log_info_color_defined() {
    local color='\033[0;32m'
    assert_equals "$color" "$color" "INFO color should be green"
}

test_log_debug_color_defined() {
    local color='\033[0;36m'
    assert_equals "$color" "$color" "DEBUG color should be cyan"
}

test_log_file_writes_when_set() {
    CLAWICU_LOG_FILE="$TEST_TMPDIR/test.log"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] test message" >> "$CLAWICU_LOG_FILE"
    assert_file_exists "$CLAWICU_LOG_FILE" "Log file should be created"
    local content="$(cat "$CLAWICU_LOG_FILE")"
    assert_contains "$content" "test message" "Log file should contain message"
    rm -f "$CLAWICU_LOG_FILE"
    unset CLAWICU_LOG_FILE
}
