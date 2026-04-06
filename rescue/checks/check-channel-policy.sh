#!/bin/sh
# check-channel-policy.sh - Detect channel configuration issues
# Based on real-world repair of 小文 (192.168.11.219)
#
# 问题: groupPolicy='allowlist' + requireMention=true 导致私信不响应
# 解决方案: 将 groupPolicy 改为 'open' 或移除 requireMention

check_channel_policy() {
    SEVERITY="warn"
    
    local config_file="$HOME/.openclaw/openclaw.json"
    [ -f "$config_file" ] || return 1
    
    # 需要 jq 解析 JSON
    command -v jq >/dev/null 2>&1 || return 1
    
    # 1. 检查 Discord 是否启用
    local discord_enabled
    discord_enabled=$(jq -r '.channels.discord.enabled // false' "$config_file" 2>/dev/null)
    [ "$discord_enabled" = "true" ] || return 1
    
    # 2. 检查 Discord groupPolicy
    local discord_policy
    discord_policy=$(jq -r '.channels.discord.groupPolicy // empty' "$config_file" 2>/dev/null)
    
    if [ "$discord_policy" = "allowlist" ]; then
        # 3. 检查是否有 requireMention
        local has_require_mention
        has_require_mention=$(jq '[.channels.discord.guilds[]?.requireMention // false] | any' "$config_file" 2>/dev/null)
        
        if [ "$has_require_mention" = "true" ]; then
            MESSAGE="Discord DMs may not work: groupPolicy='allowlist' with requireMention=true"
            DETAILS="Direct messages to Discord bot will be ignored. Fix: Change groupPolicy to 'open' or set requireMention to false."
            return 0
        fi
    fi
    
    # 4. 检查 allowFrom 是否为空
    local allow_from_count
    allow_from_count=$(jq '.channels.discord.allowFrom // [] | length' "$config_file" 2>/dev/null)
    
    if [ "$allow_from_count" = "0" ] && [ "$discord_policy" != "open" ]; then
        MESSAGE="Discord allowFrom is empty - no users can message the bot"
        DETAILS="Add user IDs to allowFrom array to allow specific users to message the bot, or set groupPolicy to 'open'."
        return 0
    fi
    
    return 1  # No channel policy issues
}
