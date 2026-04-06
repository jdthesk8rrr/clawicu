#!/bin/sh
# check-version-mismatch.sh - Detect CLI/Gateway version mismatch
# Based on real-world repair of 小文 (192.168.11.219)
#
# 问题: npm install 后 CLI 是 2026.4.5，但 Gateway 显示 2026.4.2
# 原因: Gateway 没有重启，还在用旧版本
# 检测: 比较运行中的 Gateway 版本和安装的 CLI 版本

check_version_mismatch() {
    SEVERITY="warn"
    
    local cli_version
    local gateway_version
    
    # 1. 获取 CLI 版本
    if command -v openclaw >/dev/null 2>&1; then
        cli_version=$(openclaw --version 2>/dev/null | grep -oE '[0-9]{4}\.[0-9]+\.[0-9]+' | head -1)
    else
        return 1  # openclaw binary not found
    fi
    
    [ -n "$cli_version" ] || return 1
    
    # 2. 获取 Gateway 版本
    # 方法 1: 从 systemd 服务状态
    if command -v systemctl >/dev/null 2>&1; then
        if systemctl --user is-active openclaw-gateway >/dev/null 2>&1; then
            gateway_version=$(systemctl --user status openclaw-gateway --no-pager 2>/dev/null \
                | grep -oE 'v[0-9]{4}\.[0-9]+\.[0-9]+' | head -1 | tr -d 'v')
        fi
    fi
    
    # 方法 2: 从进程列表
    if [ -z "$gateway_version" ]; then
        gateway_version=$(ps aux 2>/dev/null | grep "[o]penclaw-gatewa" \
            | grep -oE 'v[0-9]{4}\.[0-9]+\.[0-9]+' | head -1 | tr -d 'v')
    fi
    
    # 方法 3: 从日志文件
    if [ -z "$gateway_version" ]; then
        local log_file="$HOME/.openclaw/logs/openclaw-$(date +%Y-%m-%d).log"
        if [ -f "$log_file" ]; then
            gateway_version=$(grep -h "OpenClaw Gateway" "$log_file" 2>/dev/null | tail -1 \
                | grep -oE 'v[0-9]{4}\.[0-9]+\.[0-9]+' | head -1 | tr -d 'v')
        fi
    fi
    
    # 方法 4: 从 /tmp 日志
    if [ -z "$gateway_version" ]; then
        gateway_version=$(grep -rh "OpenClaw Gateway" /tmp/openclaw/*.log 2>/dev/null | tail -1 \
            | grep -oE 'v[0-9]{4}\.[0-9]+\.[0-9]+' | head -1 | tr -d 'v')
    fi
    
    # 3. 比较版本
    if [ -n "$gateway_version" ]; then
        if [ "$cli_version" != "$gateway_version" ]; then
            MESSAGE="Version mismatch: CLI=$cli_version, Gateway=$gateway_version"
            DETAILS="Gateway is running an older version than installed CLI. Restart with: systemctl --user restart openclaw-gateway"
            return 0
        fi
    fi
    
    return 1  # No version mismatch
}
