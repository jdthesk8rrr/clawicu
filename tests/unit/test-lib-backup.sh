#!/bin/sh
# test-lib-backup.sh - Tests for lib/backup.sh

type assert_equals >/dev/null 2>&1 || . "$(dirname "$0")/test-helper.sh"

test_backup_dir_default() {
    : "${CLAWICU_BACKUP_DIR:=$HOME/.openclaw/backups}"
    assert_contains "$CLAWICU_BACKUP_DIR" ".openclaw" "Default backup dir should contain .openclaw"
    assert_contains "$CLAWICU_BACKUP_DIR" "backups" "Default backup dir should contain backups"
}

test_backup_dir_custom() {
    CLAWICU_BACKUP_DIR="/tmp/custom-backups"
    local dir="${CLAWICU_BACKUP_DIR:-$HOME/.openclaw/backups}"
    assert_equals "/tmp/custom-backups" "$dir" "Custom backup dir should override default"
    unset CLAWICU_BACKUP_DIR
}

test_backup_create_uses_timestamp() {
    local timestamp="$(date '+%Y%m%d-%H%M%S')"
    assert_contains "$timestamp" "$(date '+%Y')" "Timestamp should contain current year"
    assert_contains "$timestamp" "$(date '+%m')" "Timestamp should contain current month"
}

test_backup_name_format() {
    local label="manual"
    local timestamp="$(date '+%Y%m%d-%H%M%S')"
    local name="clawicu-$label-$timestamp.tar.gz"
    assert_contains "$name" "clawicu" "Backup name should contain clawicu"
    assert_contains "$name" "$label" "Backup name should contain label"
    assert_contains "$name" ".tar.gz" "Backup name should have .tar.gz extension"
}

test_backup_restore_checks_file_exists() {
    local msg="Backup not found: /tmp/nonexistent.tar.gz"
    assert_contains "$msg" "not found" "Restore should report backup not found"
}

test_backup_verify_needs_file() {
    assert_exit_code 1 "test -f /tmp/nonexistent-backup.tar.gz" --msg "Nonexistent file should fail verify"
}

test_backup_list_no_dir() {
    local msg="No backups found"
    assert_contains "$msg" "No backups" "Should report no backups when dir missing"
}
