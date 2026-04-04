#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Running ClawICU test suite..."
echo ""

. "$SCRIPT_DIR/unit/test-helper.sh"

OVERALL_FAILED=0

run_test_dir() {
    _dir="$1"
    _label="$2"
    if [ -d "$_dir" ]; then
        echo "--- $_label ---"
        for test_file in "$_dir"/test-*.sh; do
            if [ -f "$test_file" ] && [ "$(basename "$test_file")" != "test-helper.sh" ]; then
                echo "=== $(basename "$test_file") ==="
                TESTS_RUN=0
                TESTS_PASSED=0
                TESTS_FAILED=0
                TEST_FIXTURES="$_dir/fixtures"
                export TEST_FIXTURES
                # shellcheck disable=SC1090
                . "$test_file"
                _fns="$(grep -o '^test_[a-zA-Z0-9_]*' "$test_file" | sort -u)"
                for _fn in $_fns; do
                    if type "$_fn" >/dev/null 2>&1; then
                        "$_fn" || true
                    fi
                done
                print_summary || OVERALL_FAILED=1
                echo ""
            fi
        done
    fi
}

run_test_dir "$SCRIPT_DIR/unit" "Unit Tests"
run_test_dir "$SCRIPT_DIR/integration" "Integration Tests"
run_test_dir "$SCRIPT_DIR/e2e" "E2E Tests"

if [ "$OVERALL_FAILED" -eq 1 ]; then
    echo "SOME TESTS FAILED"
    exit 1
else
    echo "ALL TESTS PASSED"
    exit 0
fi
