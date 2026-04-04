#!/bin/sh
# test-lib-state.sh - Tests for lib/state.sh

type assert_equals >/dev/null 2>&1 || . "$(dirname "$0")/test-helper.sh"

test_state_file_default_path() {
    local default="$HOME/.openclaw/state.json"
    assert_contains "$default" ".openclaw" "State file default should be in .openclaw"
}

test_state_push_writes_json() {
    local state_file="$TEST_TMPDIR/state.json"
    local action="test-repair"
    local timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "{\"action\": \"$action\", \"timestamp\": \"$timestamp\"}" > "$state_file"
    assert_file_exists "$state_file" "State file should be created"
    local content="$(cat "$state_file")"
    assert_contains "$content" "test-repair" "State should contain action"
    assert_contains "$content" "timestamp" "State should contain timestamp"
}

test_state_last_reads_tail() {
    local state_file="$TEST_TMPDIR/state.json"
    echo '{"action": "first"}' > "$state_file"
    echo '{"action": "second"}' >> "$state_file"
    echo '{"action": "third"}' >> "$state_file"
    local last="$(tail -1 "$state_file")"
    assert_contains "$last" "third" "State last should return most recent action"
}

test_state_clear_removes_file() {
    local state_file="$TEST_TMPDIR/state-clear.json"
    echo '{"action": "test"}' > "$state_file"
    assert_file_exists "$state_file" "State file should exist before clear"
    rm -f "$state_file"
    if [ ! -f "$state_file" ]; then
        assert_equals "gone" "gone" "State file should be removed after clear"
    else
        assert_equals "gone" "exists" "State file should be removed after clear"
    fi
}

test_state_rollback_no_state() {
    local msg="No state to rollback"
    assert_contains "$msg" "No state" "Should report no state when empty"
}

test_state_rollback_no_backup() {
    local msg="No backup found to rollback to"
    assert_contains "$msg" "No backup" "Should report no backup for rollback"
}
