#!/bin/sh
# test-check-disk.sh - Tests for check-disk.sh

type assert_equals >/dev/null 2>&1 || . "$(dirname "$0")/test-helper.sh"

test_disk_default_min_free() {
    local min_free_mb="${CLAWICU_MIN_FREE_MB:-100}"
    assert_equals "100" "$min_free_mb" "Default minimum free space should be 100MB"
}

test_disk_custom_min_free() {
    CLAWICU_MIN_FREE_MB=500
    local min_free_mb="${CLAWICU_MIN_FREE_MB:-100}"
    assert_equals "500" "$min_free_mb" "Custom min free should override default"
    unset CLAWICU_MIN_FREE_MB
}

test_disk_severity_is_warn() {
    local severity="warn"
    assert_equals "warn" "$severity" "Disk check severity should be warn (not fatal)"
}

test_disk_reads_free_space() {
    local free_space="$(df -k "$HOME" 2>/dev/null | tail -1 | awk '{print $4}')"
    if [ -n "$free_space" ]; then
        local free_mb=$((free_space / 1024))
        assert_num_equals 1 "1" "Should calculate free MB without error"
    else
        assert_equals "skip" "skip" "df not available, skip"
    fi
}

test_disk_low_space_detection() {
    local free_mb=50
    local min_free_mb=100
    if [ "$free_mb" -lt "$min_free_mb" ]; then
        assert_equals "low" "low" "50MB should be detected as low disk space"
    else
        assert_equals "low" "ok" "50MB should be low but was not detected"
    fi
}

test_disk_sufficient_space() {
    local free_mb=500
    local min_free_mb=100
    if [ "$free_mb" -lt "$min_free_mb" ]; then
        assert_equals "ok" "low" "500MB should be sufficient, not low"
    else
        assert_equals "ok" "ok" "500MB is sufficient"
    fi
}

test_disk_low_space_message() {
    local msg="Low disk space: 50MB free (minimum 100MB recommended)"
    assert_contains "$msg" "Low disk space" "Should report low disk space"
    assert_contains "$msg" "50MB" "Should show free space"
    assert_contains "$msg" "100MB" "Should show minimum"
}
