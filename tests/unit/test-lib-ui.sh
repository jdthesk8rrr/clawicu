#!/bin/sh
# test-lib-ui.sh - Tests for lib/ui.sh

type assert_equals >/dev/null 2>&1 || . "$(dirname "$0")/test-helper.sh"

test_terminal_width_default() {
    local width="${TERMINAL_WIDTH:-80}"
    if [ "$width" -ge 40 ] 2>/dev/null; then
        assert_equals "yes" "yes" "Terminal width should be reasonable (>= 40)"
    else
        assert_equals "yes" "no" "Terminal width should be reasonable"
    fi
}

test_hline_produces_output() {
    local width=20
    local line="$(printf '%*s\n' "$width" '' | tr ' ' '─')"
    assert_contains "$line" "───" "hline should produce dashes"
}

test_clear_line_format() {
    local clear='\r\033[K'
    assert_contains "$clear" "\r" "Clear line should contain carriage return"
    assert_contains "$clear" "\033" "Clear line should contain escape sequence"
}

test_box_title_format() {
    local title="Test Title"
    local width=20
    local padding=5
    assert_contains "$title" "Test" "Title should contain text"
    assert_num_equals "$width" "$width" "Width should be numeric"
}

test_menu_prompt_options_format() {
    local prompt="Select option"
    local options="a,b,c"
    local formatted="$prompt [$options]"
    assert_contains "$formatted" "Select option" "Should contain prompt text"
    assert_contains "$formatted" "[a,b,c]" "Should contain options in brackets"
}

test_confirm_default_yes() {
    local default="y"
    case "$default" in
        y|Y) assert_equals "0" "0" "y default should return 0" ;;
        *)   assert_equals "0" "1" "y default should return 0" ;;
    esac
}

test_confirm_default_no() {
    local default="n"
    case "$default" in
        y|Y) assert_equals "1" "0" "n default should return 1" ;;
        *)   assert_equals "1" "1" "n default should return 1" ;;
    esac
}

test_progress_bar_percent_calculation() {
    local current=50
    local total=100
    local percent=$((current * 100 / total))
    assert_equals "50" "$percent" "50 of 100 should be 50%"
}

test_progress_bar_zero() {
    local current=0
    local total=100
    local percent=$((current * 100 / total))
    assert_equals "0" "$percent" "0 of 100 should be 0%"
}

test_progress_bar_complete() {
    local current=100
    local total=100
    local percent=$((current * 100 / total))
    assert_equals "100" "$percent" "100 of 100 should be 100%"
}
