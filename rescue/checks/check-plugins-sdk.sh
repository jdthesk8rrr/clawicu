#!/bin/sh
# check-plugins-sdk.sh - Detect plugin SDK compatibility issues
# Based on real-world repair of 小文 (192.168.11.219)
#
# 检测的问题:
#   1. ERR_MODULE_NOT_FOUND: plugin-sdk 模块缺失
#   2. api.config.get is not a function - API 版本不兼容
#   3. plugins.load.paths 中的无效路径

check_plugins_sdk() {
    SEVERITY="fatal"

    local doctor_out="${CLAWICU_DOCTOR_OUT:-}"
    local config_file="$HOME/.openclaw/openclaw.json"
    local ext_dir="$HOME/.openclaw/extensions"

    # --- 1. 检测 ERR_MODULE_NOT_FOUND: plugin-sdk ---
    if [ -f "$doctor_out" ]; then
        # "Cannot find module '/path/to/plugin-sdk'"
        if grep -q "Cannot find module.*plugin-sdk\|ERR_MODULE_NOT_FOUND.*plugin-sdk" "$doctor_out" 2>/dev/null; then
            local sdk_err
            sdk_err="$(grep "Cannot find module.*plugin-sdk" "$doctor_out" | head -1)"
            # 提取引用 plugin-sdk 的插件路径
            local plugin_path
            plugin_path="$(grep "imported from" "$doctor_out" 2>/dev/null | head -1 \
                | grep -o '/[^ ]*\.js')"
            
            MESSAGE="Plugin SDK module missing"
            DETAILS="A plugin imports openclaw/plugin-sdk but the module is not installed. Path: ${plugin_path:-unknown}. This usually happens after OpenClaw upgrade. Repair: reinstall plugin dependencies or disable the plugin."
            return 0
        fi

        # "api.config.get is not a function" - specific SDK API incompatibility
        if grep -q "api\.config\.get is not a function\|api\.tools\.register is not a function" "$doctor_out" 2>/dev/null; then
            local api_err
            api_err="$(grep "is not a function" "$doctor_out" | head -1 | sed 's/^[[:space:]]*//')"
            # 提取插件路径
            local plugin_path
            plugin_path="$(grep -B5 "is not a function" "$doctor_out" 2>/dev/null \
                | grep "at activate" | head -1 \
                | grep -o '(/[^)]*)' | tr -d '()' | sed 's/:[0-9]*:[0-9]*$//')"
            
            MESSAGE="Plugin SDK API incompatibility: ${api_err:-unknown API error}"
            DETAILS="Plugin at '${plugin_path:-unknown}' uses an outdated OpenClaw plugin SDK API. The plugin needs to be updated to match the current OpenClaw version, or disabled."
            return 0
        fi

        # "TypeError: ... is not a function" general plugin errors
        if grep -q "TypeError:.*is not a function\|ReferenceError:.*is not defined" "$doctor_out" 2>/dev/null; then
            # 检查是否在 activate 上下文中
            if grep -B3 "is not a function\|is not defined" "$doctor_out" 2>/dev/null | grep -q "at activate"; then
                local type_err
                type_err="$(grep "TypeError:\|ReferenceError:" "$doctor_out" | head -1 | sed 's/^[[:space:]]*//')"
                MESSAGE="Plugin runtime error during activation"
                DETAILS="${type_err:-Unknown error}. This is typically caused by API incompatibility after OpenClaw upgrade."
                return 0
            fi
        fi
    fi

    # --- 2. 检测 plugins.load.paths 中的无效路径 ---
    if [ -f "$config_file" ] && command -v jq >/dev/null 2>&1; then
        local paths
        paths=$(jq -r '.plugins.load.paths[]? // empty' "$config_file" 2>/dev/null)
        
        for path in $paths; do
            # 展开路径
            local expanded_path="${path//\~/$HOME}"
            expanded_path="${expanded_path//\$HOME/$HOME}"
            
            if [ ! -d "$expanded_path" ]; then
                MESSAGE="Invalid plugin path in config: $path"
                DETAILS="plugins.load.paths contains '$path' which does not exist. This will cause Gateway startup failure. Repair will remove this path."
                return 0
            fi
            
            # 检查路径是否指向已禁用的插件目录
            if [ -d "${expanded_path}.disabled" ] || [ -d "${expanded_path}.clawicu-disabled" ]; then
                MESSAGE="Plugin path points to disabled plugin: $path"
                DETAILS="The plugin at '$path' appears to have been disabled (disabled directory exists). Repair will remove this path from config."
                return 0
            fi
        done
    fi

    # --- 3. 检测 extensions 目录中的插件依赖问题 ---
    if [ -d "$ext_dir" ]; then
        for plugin_dir in "$ext_dir"/*/; do
            [ -d "$plugin_dir" ] || continue
            local name
            name="$(basename "$plugin_dir")"
            
            # 跳过已禁用的
            case "$name" in
                *.disabled|*.clawicu-disabled) continue ;;
            esac
            
            # 检查 node_modules 是否存在但 plugin-sdk 缺失
            if [ -f "$plugin_dir/package.json" ] && [ -d "$plugin_dir/node_modules" ]; then
                # 检查 package.json 是否依赖 plugin-sdk
                if grep -q "plugin-sdk\|@openclaw/plugin-sdk" "$plugin_dir/package.json" 2>/dev/null; then
                    if [ ! -d "$plugin_dir/node_modules/openclaw" ] && \
                       [ ! -d "$plugin_dir/node_modules/@openclaw" ]; then
                        MESSAGE="Plugin '$name' has broken plugin-sdk dependency"
                        DETAILS="Plugin at $plugin_dir declares plugin-sdk dependency but node_modules is incomplete. Run: cd '$plugin_dir' && npm install"
                        SEVERITY="warn"
                        return 0
                    fi
                fi
            fi
        done
    fi

    return 1  # No issues found
}
