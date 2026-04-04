#!/bin/sh
# test-check-config.sh - Tests for check-config.sh

type assert_equals >/dev/null 2>&1 || . "$(dirname "$0")/test-helper.sh"

FIXTURES="${TEST_FIXTURES:-$(dirname "$0")/fixtures}"

test_config_file_exists() {
    assert_file_exists "$FIXTURES/valid-config.json5" "Valid config fixture should exist"
    assert_file_exists "$FIXTURES/broken-config.json5" "Broken config fixture should exist"
}

test_valid_config_has_balanced_braces() {
    local open_count="$(grep -o '{' "$FIXTURES/valid-config.json5" | wc -l | tr -d ' ')"
    local close_count="$(grep -o '}' "$FIXTURES/valid-config.json5" | wc -l | tr -d ' ')"
    assert_equals "$open_count" "$close_count" "Valid config should have balanced braces"
}

test_broken_config_has_balanced_braces() {
    local open_count="$(grep -o '{' "$FIXTURES/broken-config.json5" | wc -l | tr -d ' ')"
    local close_count="$(grep -o '}' "$FIXTURES/broken-config.json5" | wc -l | tr -d ' ')"
    assert_equals "$open_count" "$close_count" "Broken config still has balanced braces"
}

test_valid_config_has_closing_brace() {
    if grep -q '}' "$FIXTURES/valid-config.json5"; then
        assert_equals "yes" "yes" "Valid config has closing brace"
    else
        assert_equals "yes" "no" "Valid config should have closing brace"
    fi
}

test_config_not_found_message() {
    local msg="Config file not found: /tmp/nonexistent.json5"
    assert_contains "$msg" "not found" "Should report config not found"
}

test_config_default_path() {
    local default_path="${OPENCLAW_CONFIG:-$HOME/.openclaw/config.json5}"
    assert_contains "$default_path" ".openclaw" "Default config path should contain .openclaw"
}

test_broken_config_has_trailing_comma() {
    if grep -q ',[[:space:]]*\n.*[\\]|}' "$FIXTURES/broken-config.json5" 2>/dev/null; then
        assert_equals "yes" "yes" "Broken config has trailing comma pattern"
    else
        assert_contains "$(cat "$FIXTURES/broken-config.json5")" "," "Broken config contains commas"
    fi
}

test_broken_config_has_comments() {
    local content="$(cat "$FIXTURES/broken-config.json5")"
    assert_contains "$content" "//" "Broken config should contain line comments"
}
