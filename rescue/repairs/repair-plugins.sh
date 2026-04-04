#!/bin/sh
# repair-plugins.sh - Detect and disable broken plugins

set -e

# Source dependencies
. "$(dirname "$0")/../lib/bootstrap.sh"
. "$(dirname "$0")/../lib/backup.sh"
. "$(dirname "$0")/../lib/state.sh"
. "$(dirname "$0")/../lib/log.sh"

repair_plugins() {
    describe() {
        echo "Detect and disable broken OpenClaw plugins"
    }

    dry_run() {
        echo "What would happen:"
        echo "  - Scan plugin directory for installed plugins"
        echo "  - Validate each plugin manifest (JSON parse check)"
        echo "  - Identify plugins with broken or invalid manifests"
        echo "  - Rename broken manifests from manifest.json to manifest.bak"
        echo "  - Record disabled plugins for potential re-enable later"
        echo "  - Verify remaining plugins are valid"
    }

    # Get the plugins directory
    _plugins_dir() {
        echo "${OPENCLAW_PLUGINS_DIR:-$HOME/.openclaw/plugins}"
    }

    # List all plugin directories
    _list_plugins() {
        local pdir="$1"
        if [ ! -d "$pdir" ]; then
            return 1
        fi
        for d in "$pdir"/*/; do
            if [ -d "$d" ]; then
                basename "$d"
            fi
        done
    }

    # Check if a plugin manifest is valid
    # Args: $1 = plugin directory path
    _is_plugin_valid() {
        local plugin_dir="$1"
        local manifest="$plugin_dir/manifest.json"

        # No manifest means broken
        if [ ! -f "$manifest" ]; then
            # Check if there's a .bak already
            if [ -f "$plugin_dir/manifest.bak" ]; then
                return 1
            fi
            return 1
        fi

        # Validate JSON
        if command -v node >/dev/null 2>&1; then
            node -e "JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'))" "$manifest" 2>/dev/null
            return $?
        elif command -v python3 >/dev/null 2>&1; then
            python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$manifest" 2>/dev/null
            return $?
        else
            # Fallback: basic structural check
            grep -q '{' "$manifest" 2>/dev/null && grep -q '}' "$manifest" 2>/dev/null
            return $?
        fi
    }

    # Record a disabled plugin for later re-enable
    # Args: $1 = plugin name
    _record_disabled() {
        local plugin_name="$1"
        local record_file="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}/disabled-plugins.txt"
        local timestamp
        timestamp=$(date '+%Y-%m-%dT%H:%M:%S')
        echo "$plugin_name disabled_at=$timestamp" >> "$record_file"
    }

    execute() {
        log_info "Starting plugins repair..."

        local pdir
        pdir=$(_plugins_dir)

        if [ ! -d "$pdir" ]; then
            log_warn "No plugins directory found at: $pdir"
            log_info "Nothing to repair"
            return 0
        fi

        backup_create "repair-plugins"
        state_push "repair-plugins"

        local broken_count=0
        local disabled_list=""

        # Check each plugin
        for plugin in $(_list_plugins "$pdir"); do
            local plugin_path="$pdir/$plugin"

            if _is_plugin_valid "$plugin_path"; then
                log_info "Plugin $plugin: OK"
            else
                log_warn "Plugin $plugin: BROKEN"
                broken_count=$((broken_count + 1))

                # Disable by renaming manifest
                if [ -f "$plugin_path/manifest.json" ]; then
                    mv "$plugin_path/manifest.json" "$plugin_path/manifest.bak"
                    log_info "Disabled plugin: $plugin (manifest.json -> manifest.bak)"
                elif [ ! -f "$plugin_path/manifest.bak" ]; then
                    log_warn "Plugin $plugin has no manifest at all, creating stub .bak"
                    touch "$plugin_path/manifest.bak"
                fi

                _record_disabled "$plugin"
                disabled_list="$disabled_list $plugin"
            fi
        done

        if [ "$broken_count" -eq 0 ]; then
            log_info "All plugins are valid, nothing to disable"
            return 0
        fi

        log_info "Disabled $broken_count broken plugin(s):$disabled_list"
        log_info "Disabled plugins are recorded in ~/.openclaw/disabled-plugins.txt"
        log_info "To re-enable: rename manifest.bak back to manifest.json"
        return 0
    }
}
