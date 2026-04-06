# ClawICU 更新日志

## v0.3.1 - 2026-04-06

### 基于真实修复经验的增强

本次更新基于修复小文 (192.168.11.219) 的实际经验，在修复过程中发现了多个现有脚本未覆盖的问题。

---

### 新增检查模块

#### 1. check-plugins-sdk.sh
**检测插件 SDK 版本兼容性问题**

- 检测 `Cannot find module.*plugin-sdk` - SDK 模块缺失
- 检测 `api.config.get is not a function` - API 版本不兼容
- 检测 `plugins.load.paths` 中的无效路径
- 检测插件依赖缺失

**问题场景**：
```
TypeError: api.config.get is not a function
    at activate (/home/user/.openclaw/extensions/ezviz/dist/index.js:...)
```

---

#### 2. check-version-mismatch.sh
**检测 CLI 和 Gateway 版本不一致**

- 获取 CLI 版本 (`openclaw --version`)
- 获取 Gateway 版本 (systemd/进程/日志)
- 比较两者是否一致

**问题场景**：
```
CLI: OpenClaw 2026.4.5
Gateway: OpenClaw Gateway (v2026.4.2)  # 旧版本！
```

**原因**：npm install 后没有重启 Gateway

---

#### 3. check-channel-policy.sh
**检测 Discord 频道配置问题**

- 检测 `groupPolicy='allowlist'` + `requireMention=true` 组合
- 检测 `allowFrom` 为空的情况
- 提示私信可能不响应的问题

**问题场景**：
```json
{
  "channels": {
    "discord": {
      "groupPolicy": "allowlist",  // 只允许白名单群
      "guilds": {
        "123": { "requireMention": true }  // 需要 @ 提及
      }
    }
  }
}
```
**结果**：私信不响应

---

### 新增修复模块

#### 4. repair-channel-policy.sh
**修复 Discord 频道配置**

- 将 `groupPolicy` 从 `allowlist` 改为 `open`
- 备份配置
- 提示重启 Gateway

---

#### 5. repair-plugins-paths.sh
**清理无效插件路径**

- 检查 `plugins.load.paths` 中每个路径
- 移除不存在的路径
- 备份配置

---

### 测试覆盖

新增 E2E 测试场景：

| 场景 | 问题 | 预期修复 |
|------|------|----------|
| `test-plugin-sdk-missing` | SDK 模块缺失 | 检测到问题 |
| `test-version-mismatch` | 版本不一致 | 提示重启 |
| `test-channel-policy` | 私信不响应 | 修改配置 |

---

### 文件变更

```
rescue/checks/
├── check-plugins-sdk.sh      # 新增
├── check-version-mismatch.sh # 新增
└── check-channel-policy.sh   # 新增

rescue/repairs/
├── repair-channel-policy.sh  # 新增
└── repair-plugins-paths.sh   # 新增
```

---

### 检查模块总数
- 之前: 17
- 之后: **20**

### 修复模块总数
- 之前: 12
- 之后: **14**

---

## 技术细节

### 检查模块接口
```sh
check_xxx() {
    SEVERITY="fatal"  # 或 "warn" 或 "info"
    MESSAGE="问题标题"
    DETAILS="问题详情"
    return 0  # 0=发现问题, 1=没有问题
}
```

### 修复模块接口
```sh
repair_xxx() {
    describe() { echo "描述"; }
    dry_run() { echo "预览"; }
    execute() { 
        # 实际修复逻辑
        return 0  # 0=成功, 1=失败
    }
}
```

---

## 参考

修复小文的完整日志：
- 插件错误: `TypeError: api.config.get is not a function`
- 无效路径: `plugins.load.paths` 指向不存在的 SoloFlow 目录
- 版本不匹配: CLI 2026.4.5 vs Gateway 2026.4.2
- Discord 配置: `groupPolicy='allowlist'` 导致私信不响应
