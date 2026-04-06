#!/bin/sh
# repair-plugins-paths.sh - Clean up invalid plugin load paths
# Based on real-world repair of 小文 (192.168.11.219)
# 
# 问题: plugins.load.paths 包含无效路径导致 Gateway 启动失败
# 解决方案:
#   1. 检查每个路径是否存在
#   2. 从 plugins.load.paths 中移除无效路径
#   3. 备份配置

repair_plugins_paths() {
    describe() {
        echo "Remove invalid paths from plugins.load.paths configuration"
    }

    dry_run() {
        echo "What would happen:"
        echo "  - Parse plugins.load.paths from openclaw.json"
        echo "  - Check each path exists"
        echo "  - Remove non-existent paths from config"
        echo "  - Backup config before modification"
    }

    execute() {
        log_info "Starting plugin paths cleanup..."

        local config_file="$HOME/.openclaw/openclaw.json"
        [ -f "$config_file" ] || { log_warn "Config file not found"; return 0; }

        # 检查是否有 jq
        if ! command -v jq >/dev/null 2>&1; then
            log_warn "jq not available, cannot auto-fix plugin paths"
            printf "   [!] Manual fix: install jq or edit %s manually\n" "$config_file"
            return 1
        fi

        # 检查是否有 paths 配置
        local has_paths
        has_paths=$(jq 'has("plugins") and .plugins.load.paths and (.plugins.load.paths | length > 0)' "$config_file" 2>/dev/null)
        [ "$has_paths" = "true" ] || { log_info "No plugins.load.paths to check"; return 0; }

        # 获取所有路径
        local paths
        paths=$(jq -r '.plugins.load.paths[]? // empty' "$config_file" 2>/dev/null)

        if [ -z "$paths" ]; then
            log_info "plugins.load.paths is empty"
            return 0
        fi

        # 检查每个路径
        local invalid_paths=""
        local valid_paths="[]"
        local count=0
        
        for path in $paths; do
            count=$((count + 1))
            # 展开路径
            local expanded="${path//\~/$HOME}"
            expanded="${expanded//\$HOME/$HOME}"
            
            if [ ! -d "$expanded" ]; then
                invalid_paths="$invalid_paths $path"
                log_warn "Invalid path found: $path"
            else
                # 保留有效路径
                valid_paths=$(echo "$valid_paths" | jq --arg p "$path" '. + [$p]')
            fi
        done

        if [ -z "$invalid_paths" ]; then
            log_info "All $count plugin paths are valid"
            return 0
        fi

        # 备份
        backup_create "repair-plugins-paths" >/dev/null

        # 更新配置
        log_info "Removing invalid paths from config..."
        
        local tmp_file
        tmp_file=$(mktemp)
        
        if jq --argjson paths "$valid_paths" '.plugins.load.paths = $paths' "$config_file" > "$tmp_file"; then
            mv "$tmp_file" "$config_file"
            local removed_count
            removed_count=$(echo "$invalid_paths" | wc -w)
            log_info "Config updated: removed $removed_count invalid path(s)"
            printf "   [OK] Removed paths:%s\n" "$invalid_paths"
        else
            rm -f "$tmp_file"
            log_error "Failed to update config"
            return 1
        fi

        # 提示重启
        log_info "Restart gateway to apply changes: systemctl --user restart openclaw-gateway"

        return 0
    }
}
