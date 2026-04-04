#!/bin/sh
# ClawICU - OpenClaw Emergency Rescue System
# Main entry point - 6-phase orchestrator

set -e

# Script directory (resolve symlinks)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAWICU_VERSION="0.1.0"

# Source all lib modules
. "$SCRIPT_DIR/lib/bootstrap.sh"
. "$SCRIPT_DIR/lib/log.sh"
. "$SCRIPT_DIR/lib/ui.sh"
. "$SCRIPT_DIR/lib/backup.sh"
. "$SCRIPT_DIR/lib/state.sh"
. "$SCRIPT_DIR/lib/verify.sh"

# Initialize bootstrap
bootstrap

# Parse flags
DRY_RUN=0
VERBOSE=0
FORCE=0

while getopts "dhvf" opt; do
    case "$opt" in
        d) DRY_RUN=1 ;;
        v) VERBOSE=1; CLAWICU_LOG_LEVEL="DEBUG" ;;
        f) FORCE=1 ;;
        h)
            echo "Usage: $0 [-d] [-v] [-f]"
            echo "  -d  Dry run (show what would be done)"
            echo "  -v  Verbose output"
            echo "  -f  Force (skip confirmations)"
            exit 0
            ;;
    esac
done

# Phase 0: Bootstrap
phase_0_bootstrap() {
    log_info "ClawICU v$CLAWICU_VERSION - OpenClaw Emergency Rescue"
    log_info "Detected: OS=$CLAWICU_OS, ARCH=$CLAWICU_ARCH, SHELL=$CLAWICU_SHELL"
    log_info "Install method: $CLAWICU_INSTALL_METHOD"
    log_info "Working directory: $CLAWICU_TMPDIR"
    
    # Check prerequisites
    if ! command -v curl >/dev/null 2>&1; then
        log_fatal "curl is required but not found"
        exit 1
    fi
}

# Phase 1: Doctor Delegation
phase_1_doctor() {
    log_info "Phase 1: Doctor Delegation"
    
    if ! command -v openclaw >/dev/null 2>&1; then
        log_warn "openclaw binary not found, skipping doctor delegation"
        return 1
    fi
    
    log_info "Running openclaw doctor..."
    if openclaw doctor 2>&1; then
        log_info "openclaw doctor succeeded"
        return 1  # No issues found
    else
        log_warn "openclaw doctor reported issues"
        # Parse doctor output for issues
        return 0  # Issues found
    fi
}

# Phase 2: Standalone Checks
phase_2_checks() {
    log_info "Phase 2: Running diagnostic checks..."
    
    RESULTS_FILE="$CLAWICU_TMPDIR/check-results.txt"
    > "$RESULTS_FILE"
    
    # Source and run each check module
    for check in "$SCRIPT_DIR/checks"/check-*.sh; do
        if [ -f "$check" ]; then
            . "$check"
            check_name="$(basename "$check" .sh)"
            log_debug "Running check: $check_name"
            
            if check_"${check_name#check-}" 2>/dev/null; then
                # Check returned 0 = issue found
                echo "FAIL:$SEVERITY:$check_name:$MESSAGE:$DETAILS" >> "$RESULTS_FILE"
            else
                # Check returned 1 = OK
                echo "PASS:$check_name" >> "$RESULTS_FILE"
            fi
        fi
    done
    
    fail_count="$(grep -c "^FAIL:" "$RESULTS_FILE" || true)"
    log_info "Checks complete: $fail_count issues found"
}

# Phase 3: Merge & Triage
phase_3_triage() {
    log_info "Phase 3: Merging and triaging results..."
    
    FATAL_COUNT="$(grep -c "^FAIL:fatal:" "$RESULTS_FILE" || true)"
    WARN_COUNT="$(grep -c "^FAIL:warn:" "$RESULTS_FILE" || true)"
    INFO_COUNT="$(grep -c "^FAIL:info:" "$RESULTS_FILE" || true)"
    
    log_info "Summary: $FATAL_COUNT FATAL, $WARN_COUNT WARN, $INFO_COUNT INFO"
}

# Phase 4: Interactive Repair Menu
phase_4_menu() {
    log_info "Phase 4: Guided Repair Menu"
    
    if [ "$FATAL_COUNT" -eq 0 ] && [ "$WARN_COUNT" -eq 0 ]; then
        log_info "No issues found - OpenClaw appears healthy!"
        return 1
    fi
    
    echo ""
    hline
    box "ClawICU - Issues Found" 50
    echo ""
    
    # Display issues
    grep "^FAIL:" "$RESULTS_FILE" | while IFS=: read -r _ severity check msg details; do
        icon="?"
        case "$severity" in
            fatal) icon="X" ;;
            warn) icon="!" ;;
            info) icon="i" ;;
        esac
        echo "  [$icon] $severity: $msg"
    done
    
    echo ""
    hline
    
    if [ "$DRY_RUN" -eq 1 ]; then
        log_info "Dry run - skipping repair menu"
        return 1
    fi
    
    # Show menu options
    echo ""
    echo "  [a] Fix all automatically (recommended)"
    echo "  [1-$((FATAL_COUNT + WARN_COUNT))] Fix individual issues"
    echo "  [s] Safe mode (disable all plugins)"
    echo "  [r] Full state reset (preserve credentials)"
    echo "  [R] Clean reinstall"
    echo "  [e] Export diagnostic report"
    echo "  [q] Quit"
    echo ""
    
    printf "Select option: "
    read -r choice
    
    case "$choice" in
        a) repair_all ;;
        q) log_info "Exiting..."; exit 0 ;;
        *) log_warn "Option not implemented yet" ;;
    esac
}

# Phase 5: Execute Repairs
phase_5_execute() {
    log_info "Phase 5: Executing repairs..."
    # Loop through selected repairs and execute each
    # Each repair creates backup, executes, verifies, rolls back on failure
}

# Phase 6: Verify & Report
phase_6_report() {
    log_info "Phase 6: Verifying and reporting..."
    
    # Re-run checks to verify fixes
    phase_2_checks
    
    # Generate report
    report="$HOME/.openclaw/clawicu-report-$(date '+%Y%m%d-%H%M%S').txt"
    
    {
        echo "ClawICU Rescue Report"
        echo "====================="
        echo "Date: $(date)"
        echo "System: $CLAWICU_OS $CLAWICU_ARCH"
        echo "Install method: $CLAWICU_INSTALL_METHOD"
        echo ""
        echo "Issues Found:"
        grep "^FAIL:" "$RESULTS_FILE" || echo "  None"
        echo ""
        echo "Backup location: $CLAWICU_BACKUP_DIR"
    } > "$report"
    
    log_info "Report saved to: $report"
}

# Main orchestrator
main() {
    phase_0_bootstrap
    phase_1_doctor || true
    phase_2_checks
    phase_3_triage
    phase_4_menu
    phase_5_execute
    phase_6_report
    
    log_info "ClawICU rescue complete!"
}

main "$@"
