#!/bin/sh
# repair-sessions.sh - Remove corrupted session files by moving them aside

set -e

# Source dependencies
. "$(dirname "$0")/../lib/bootstrap.sh"
. "$(dirname "$0")/../lib/backup.sh"
. "$(dirname "$0")/../lib/state.sh"
. "$(dirname "$0")/../lib/log.sh"

repair_sessions() {
    describe() {
        echo "Detect and quarantine corrupted session files"
    }

    dry_run() {
        echo "What would happen:"
        echo "  - Scan session directory for all session files"
        echo "  - Parse each file to detect JSON corruption"
        echo "  - Move corrupted sessions to ~/.openclaw/sessions/corrupted/"
        echo "  - Sessions are NOT deleted - just moved aside for safety"
        echo "  - Report summary of moved sessions"
    }

    # Get the sessions directory
    _sessions_dir() {
        echo "${OPENCLAW_SESSIONS_DIR:-$HOME/.openclaw/sessions}"
    }

    # Validate a session file is valid JSON
    # Args: $1 = file path
    _is_valid_session() {
        local session_file="$1"

        if [ ! -f "$session_file" ]; then
            return 1
        fi

        # Empty file is corrupted
        local size
        size=$(wc -c < "$session_file" 2>/dev/null || echo 0)
        if [ "$size" -eq 0 ]; then
            return 1
        fi

        # Try node first for strict JSON validation
        if command -v node >/dev/null 2>&1; then
            node -e "JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'))" "$session_file" 2>/dev/null
            return $?
        fi

        # Fall back to python
        if command -v python3 >/dev/null 2>&1; then
            python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$session_file" 2>/dev/null
            return $?
        fi

        # Last resort: basic structure check
        if grep -q '{' "$session_file" 2>/dev/null && grep -q '}' "$session_file" 2>/dev/null; then
            return 0
        fi
        return 1
    }

    # List all session files
    # Args: $1 = sessions directory
    _list_session_files() {
        local sdir="$1"
        if [ ! -d "$sdir" ]; then
            return 1
        fi

        # Match common session file patterns
        for f in "$sdir"/*.json "$sdir"/*/*.json; do
            if [ -f "$f" ]; then
                echo "$f"
            fi
        done
    }

    execute() {
        log_info "Starting sessions repair..."

        local sdir
        sdir=$(_sessions_dir)

        if [ ! -d "$sdir" ]; then
            log_warn "No sessions directory found at: $sdir"
            log_info "Nothing to repair"
            return 0
        fi

        # Create corrupted sessions quarantine directory
        local corrupted_dir="$sdir/corrupted"
        mkdir -p "$corrupted_dir"

        backup_create "repair-sessions"
        state_push "repair-sessions"

        local total_count=0
        local corrupted_count=0
        local moved_list=""

        # Check each session file
        for session_file in $(_list_session_files "$sdir"); do
            # Skip files already in the corrupted directory
            case "$session_file" in
                */corrupted/*) continue ;;
            esac

            total_count=$((total_count + 1))

            if _is_valid_session "$session_file"; then
                log_debug "Session $(basename "$session_file"): OK"
            else
                corrupted_count=$((corrupted_count + 1))
                local fname
                fname=$(basename "$session_file")
                local dest="$corrupted_dir/$fname"

                # Avoid overwriting existing files in corrupted dir
                if [ -f "$dest" ]; then
                    local timestamp
                    timestamp=$(date '+%Y%m%d-%H%M%S')
                    dest="$corrupted_dir/${fname}.$timestamp"
                fi

                mv "$session_file" "$dest"
                log_info "Moved corrupted session: $fname -> corrupted/$fname"
                moved_list="$moved_list $fname"
            fi
        done

        if [ "$total_count" -eq 0 ]; then
            log_info "No session files found"
            return 0
        fi

        log_info "Scanned $total_count session(s), found $corrupted_count corrupted"
        if [ "$corrupted_count" -gt 0 ]; then
            log_info "Corrupted sessions moved to: $corrupted_dir"
            log_info "Moved:$moved_list"
        fi

        log_info "Sessions repair completed"
        return 0
    }
}
