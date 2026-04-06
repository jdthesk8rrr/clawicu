#!/bin/sh
# repair-channel-policy.sh - Fix channel configuration issues
# Based on real-world repair of 小文 (192.168.11.219)
#
# 问题: groupPolicy='allowlist' 导致私信不响应
# 解决方案: 将 groupPolicy 改为 'open'

repair_channel_policy() {
    describe() {
        echo "Adjust Discord channel policy to allow direct messages"
    }

    dry_run() {
        echo "What would happen:"
        echo "  - Change channels.discord.groupPolicy to 'open'"
        echo "  - Backup config before modification"
        echo "  - Restart gateway to apply changes"
    }

    execute() {
        log_info "Starting channel policy repair..."

        local config_file="$HOME/.openclaw/openclaw.json"
        [ -f "$config_file" ] || { log_warn "Config file not found"; return 1; }

        # 检查是否需要修复
        local current_policy
        current_policy=$(jq -r '.channels.discord.groupPolicy // empty' "$config_file" 2>/dev/null)
        
        if [ "$current_policy" != "allowlist" ]; then
            log_info "Current groupPolicy is '$current_policy', no fix needed"
            return 0
        fi

        log_info "Changing groupPolicy from 'allowlist' to 'open'..."

        # 备份
        backup_create "repair-channel-policy" >/dev/null

        # 修改配置
        if command -v jq >/dev/null 2>&1; then
            local tmp_file
            tmp_file=$(mktemp)
            
            if jq '.channels.discord.groupPolicy = "open"' "$config_file" > "$tmp_file"; then
                mv "$tmp_file" "$config_file"
                log_info "Changed groupPolicy to 'open'"
                printf "   [OK] Discord groupPolicy updated to 'open'\n"
            else
                rm -f "$tmp_file"
                log_error "Failed to update config"
                return 1
            fi
        else
            log_warn "jq not available, cannot auto-fix"
            printf "   [!] Manual fix: edit %s and change groupPolicy to 'open'\n" "$config_file"
            return 1
        fi

        # 提示重启
        log_info "Restart gateway to apply changes: systemctl --user restart openclaw-gateway"
        printf "   [i] Restart required: systemctl --user restart openclaw-gateway\n"

        return 0
    }
}
