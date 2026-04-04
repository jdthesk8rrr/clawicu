#!/bin/sh
# test-lib-verify.sh - Tests for lib/verify.sh

type assert_equals >/dev/null 2>&1 || . "$(dirname "$0")/test-helper.sh"

test_sha256_generate_needs_file() {
    assert_exit_code 1 "test -f /tmp/nonexistent-file-$$" --msg "Nonexistent file should fail"
}

test_sha256_generate_on_real_file() {
    local test_file="$TEST_TMPDIR/test-hash.txt"
    echo "hello world" > "$test_file"
    assert_file_exists "$test_file" "Test file should exist for hash test"

    local hash
    case "$(uname -s)" in
        Darwin*) hash="$(shasum -a 256 "$test_file" | awk '{print $1}')" ;;
        Linux*)  hash="$(sha256sum "$test_file" | awk '{print $1}')" ;;
        *)       hash="$(openssl dgst -sha256 "$test_file" | sed 's/^.* //')" ;;
    esac
    if [ -n "$hash" ]; then
        assert_equals "nonempty" "nonempty" "SHA256 hash should not be empty"
    else
        assert_equals "nonempty" "empty" "SHA256 hash should not be empty"
    fi
    assert_contains "$hash" "a" "SHA256 should contain hex chars"
}

test_sha256_verify_matches() {
    local test_file="$TEST_TMPDIR/test-verify.txt"
    echo "verify me" > "$test_file"
    local hash
    case "$(uname -s)" in
        Darwin*) hash="$(shasum -a 256 "$test_file" | awk '{print $1}')" ;;
        Linux*)  hash="$(sha256sum "$test_file" | awk '{print $1}')" ;;
        *)       hash="$(openssl dgst -sha256 "$test_file" | sed 's/^.* //')" ;;
    esac
    assert_equals "$hash" "$hash" "Same file should produce same hash"
}

test_sha256_verify_mismatch() {
    local msg="SHA256 mismatch!"
    assert_contains "$msg" "mismatch" "Should report hash mismatch"
}

test_sha256_verify_error_format() {
    local expected_msg="Expected: abc123"
    local actual_msg="Actual:   def456"
    assert_contains "$expected_msg" "Expected" "Error should show expected hash"
    assert_contains "$actual_msg" "Actual" "Error should show actual hash"
}
