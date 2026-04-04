#!/bin/sh
# repair-config-field.sh - Reset individual config fields to defaults

set -e

. "$(dirname "$0")/../lib/bootstrap.sh"
. "$(dirname "$0")/../lib/backup.sh"
. "$(dirname "$0")/../lib/state.sh"
. "$(dirname "$0")/../lib/log.sh"

repair_config_field() {
    # Default values for known config fields
    _default_port="18789"
    _default_auth="true"
    _default_log_level="info"
    _default_host="127.0.0.1"
    _default_timeout="30"

    _field_defaults() {
        case "$1" in
            port)     echo "$_default_port" ;;
            auth)     echo "$_default_auth" ;;
            logLevel) echo "$_default_log_level" ;;
            host)     echo "$_default_host" ;;
            timeout)  echo "$_default_timeout" ;;
            *)        echo "" ;;
        esac
    }

    _known_fields() {
        echo "port - Gateway listen port (default: $_default_port)"
        echo "auth - Enable authentication (default: $_default_auth)"
        echo "logLevel - Logging verbosity (default: $_default_log_level)"
        echo "host - Bind address (default: $_default_host)"
        echo "timeout - Request timeout in seconds (default: $_default_timeout)"
    }

    describe() {
        echo "Reset individual OpenCode config fields to their default values"
    }

    dry_run() {
        echo "What would happen:"
        echo "  - Back up current config"
        echo "  - Reset the specified field to its default value"
        echo "  - Verify config is still valid JSON5"
        echo "  - Roll back if verification fails"
    }

    _validate_json5() {
        local cfg="$1"
        if [ ! -f "$cfg" ]; then
            return 1
        fi
        local size
        size=$(wc -c < "$cfg" 2>/dev/null || echo 0)
        [ "$size" -eq 0 ] && return 1

        if command -v python3 >/dev/null 2>&1; then
            python3 -c "
import re, json, sys
txt = open(sys.argv[1]).read()
txt = re.sub(r'//.*', '', txt)
txt = re.sub(r'/\*.*?\*/', '', txt, flags=re.DOTALL)
txt = re.sub(r',\s*([}\]])', r'\1', txt)
json.loads(txt)
" "$cfg" 2>/dev/null && return 0
        fi

        if command -v node >/dev/null 2>&1; then
            node -e "JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'))" "$cfg" 2>/dev/null && return 0
        fi

        grep -q '{' "$cfg" 2>/dev/null && return 0
        return 1
    }

    _set_field() {
        local cfg="$1"
        local field="$2"
        local value="$3"

        if command -v python3 >/dev/null 2>&1; then
            python3 -c "
import re, json, sys
path, key, val = sys.argv[1], sys.argv[2], sys.argv[3]
txt = open(path).read()
txt = re.sub(r'//.*', '', txt)
txt = re.sub(r'/\*.*?\*/', '', txt, flags=re.DOTALL)
txt = re.sub(r',\s*([}\]])', r'\1', txt)
d = json.loads(txt)
d[key] = val
with open(path, 'w') as f:
    json.dump(d, f, indent=2)
" "$cfg" "$field" "$value" 2>/dev/null && return 0
        fi

        if command -v node >/dev/null 2>&1; then
            node -e "
const fs = require('fs');
const path = process.argv[1], key = process.argv[2], val = process.argv[3];
const obj = JSON.parse(fs.readFileSync(path, 'utf8'));
obj[key] = val;
fs.writeFileSync(path, JSON.stringify(obj, null, 2));
" "$cfg" "$field" "$value" 2>/dev/null && return 0
        fi

        log_fatal "Need python3 or node to modify config fields"
        return 1
    }

    execute() {
        log_info "Starting config field reset repair..."

        local config_dir="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
        local config_file="$config_dir/config.json5"
        [ ! -f "$config_file" ] && config_file="$config_dir/config.json"

        if [ ! -f "$config_file" ]; then
            log_fatal "Cannot find config file in: $config_dir"
            return 1
        fi

        local field="${OPENCODE_RESET_FIELD:-}"
        if [ -z "$field" ]; then
            log_info "Available fields to reset:"
            _known_fields
            log_fatal "Set OPENCODE_RESET_FIELD env var to the field name (e.g. port, auth)"
            return 1
        fi

        local default_val
        default_val="$(_field_defaults "$field")"
        if [ -z "$default_val" ]; then
            log_fatal "Unknown field: $field. Known: port, auth, logLevel, host, timeout"
            return 1
        fi

        log_info "Resetting field '$field' to default: $default_val"

        local backup_path
        backup_path="$(backup_create "repair-config-field")"
        log_info "Backup created: $backup_path"

        state_push "repair-config-field"

        if ! _set_field "$config_file" "$field" "$default_val"; then
            log_error "Failed to set field, rolling back..."
            cp "$backup_path" "$config_file"
            state_rollback
            return 1
        fi

        if _validate_json5 "$config_file"; then
            log_info "Field '$field' reset to '$default_val' successfully"
            return 0
        else
            log_error "Config validation failed after field reset, rolling back..."
            cp "$backup_path" "$config_file"
            state_rollback
            return 1
        fi
    }
}
