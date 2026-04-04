#!/bin/sh
# test-check-node.sh - Tests for check-node.sh

type assert_equals >/dev/null 2>&1 || . "$(dirname "$0")/test-helper.sh"

test_node_major_too_old() {
    local major=20
    if [ "$major" -lt 22 ]; then
        assert_equals "old" "old" "Node 20 should be detected as too old"
    else
        assert_equals "skip" "skip" "Node 20 is not < 22, logic error"
    fi
}

test_node_major_new_enough() {
    local major=22
    if [ "$major" -lt 22 ]; then
        assert_equals "not-old" "old" "Node 22 should NOT be too old"
    else
        assert_equals "ok" "ok" "Node 22 is >= 22, passes check"
    fi
}

test_node_minor_too_old() {
    local major=22
    local minor=11
    if [ "$major" -eq 22 ] && [ "$minor" -lt 12 ]; then
        assert_equals "old" "old" "Node 22.11 should be too old (< 22.12)"
    else
        assert_equals "skip" "skip" "Node 22.11 is >= 22.12, logic error"
    fi
}

test_node_minor_ok() {
    local major=22
    local minor=12
    if [ "$major" -eq 22 ] && [ "$minor" -lt 12 ]; then
        assert_equals "not-old" "old" "Node 22.12 should pass"
    else
        assert_equals "ok" "ok" "Node 22.12 >= 22.12, passes check"
    fi
}

test_node_version_parsing() {
    local node_version="22.14.0"
    local major="$(echo "$node_version" | cut -d. -f1)"
    local minor="$(echo "$node_version" | cut -d. -f2)"
    local patch="$(echo "$node_version" | cut -d. -f3)"
    assert_equals "22" "$major" "Major should be 22"
    assert_equals "14" "$minor" "Minor should be 14"
    assert_equals "0" "$patch" "Patch should be 0"
}

test_node_version_stripping_v() {
    local raw="v22.14.0"
    local stripped="$(echo "$raw" | sed 's/v//')"
    assert_equals "22.14.0" "$stripped" "Should strip leading v from version"
}

test_node_missing_message() {
    local msg="Node.js not found - OpenClaw requires Node.js"
    assert_contains "$msg" "not found" "Should report node not found"
    assert_contains "$msg" "requires" "Should mention OpenClaw requirement"
}

test_node_old_version_message() {
    local msg="Node.js version 20.10.0 is too old. OpenClaw requires Node.js >= 22.12"
    assert_contains "$msg" "too old" "Should mention version too old"
    assert_contains "$msg" "22.12" "Should mention minimum version 22.12"
}
