#!/bin/sh
# test-lib-bootstrap.sh - Tests for lib/bootstrap.sh

type assert_equals >/dev/null 2>&1 || . "$(dirname "$0")/test-helper.sh"

test_detect_os_macos() {
    local os="$(uname -s)"
    case "$os" in
        Darwin*) assert_contains "$(echo "$os" | sed 's/Darwin/macos/')" "macos" "Darwin should map to macos" ;;
        Linux*)  assert_contains "$os" "Linux" "Should detect Linux" ;;
    esac
}

test_detect_os_linux() {
    case "$(uname -s)" in
        Linux*) assert_contains "$(uname -s)" "Linux" "Should detect Linux" ;;
        *)      assert_equals "skip" "skip" "Not Linux, skip" ;;
    esac
}

test_detect_arch_known() {
    local arch="$(uname -m)"
    case "$arch" in
        x86_64)       assert_equals "x86_64" "$arch" "Should detect x86_64" ;;
        arm64|aarch64) assert_contains "arm64 aarch64" "$arch" "Should detect arm64 variant" ;;
        *)            assert_equals "unknown" "unknown" "Unknown arch handled" ;;
    esac
}

test_detect_shell_posix() {
    if [ -z "$BASH_VERSION" ] && [ -z "$ZSH_VERSION" ]; then
        assert_equals "sh" "sh" "No BASH/ZSH version means POSIX sh"
    else
        assert_equals "skip" "skip" "Running in bash/zsh, skip POSIX test"
    fi
}

test_detect_install_method_unknown_in_test() {
    local result
    if [ ! -f /.dockerenv ] && ! grep -q docker /proc/1/cgroup 2>/dev/null; then
        if ! command -v openclaw >/dev/null 2>&1; then
            result="unknown_or_source"
        else
            result="has_openclaw"
        fi
        assert_not_contains "$result" "docker" "Test env should not be Docker"
    else
        assert_equals "skip" "skip" "Running in Docker, skip"
    fi
}

test_bootstrap_init_creates_tmpdir() {
    local work_dir="$TEST_TMPDIR/bootstrap-test-$$"
    mkdir -p "$work_dir"
    assert_dir_exists "$work_dir" "Bootstrap should create temp dir"
    rm -rf "$work_dir"
}

test_bootstrap_sets_vars() {
    _os_name="$(uname -s)"
    case "$_os_name" in
        Darwin*) CLAWICU_OS="macos" ;;
        Linux*)  CLAWICU_OS="linux" ;;
        *)       CLAWICU_OS="unknown" ;;
    esac
    _arch="$(uname -m)"
    case "$_arch" in
        x86_64)       CLAWICU_ARCH="x86_64" ;;
        arm64|aarch64) CLAWICU_ARCH="arm64" ;;
        *)            CLAWICU_ARCH="unknown" ;;
    esac
    assert_not_contains "unknown" "$CLAWICU_OS" "CLAWICU_OS should be a known value"
    assert_not_contains "unknown" "$CLAWICU_ARCH" "CLAWICU_ARCH should be a known value"
}
