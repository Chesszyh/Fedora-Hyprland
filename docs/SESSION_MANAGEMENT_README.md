# Hyprland Session Management

**English** | [中文](#中文文档)

---

## Overview

A comprehensive session management system for Hyprland that provides macOS-style window restoration functionality. This system automatically saves and restores application windows, workspace layouts, and monitor configurations across login sessions.

## Features

- **Automatic Session Persistence**: Saves current session state during logout/shutdown
- **Intelligent Window Restoration**: Restores applications to their previous workspaces and positions
- **Multi-layered Save Mechanism**: Multiple backup systems ensure reliable session capture
- **Backup Recovery**: Automatic fallback to previous sessions if corruption occurs
- **Manual Session Control**: Keyboard shortcuts and GUI interface for session management
- **Application Recognition**: Built-in support for common Linux applications
- **Workspace Preservation**: Maintains workspace layouts and active workspace state

## Architecture

### Core Components

```
scripts/
├── SessionSave.sh              # Session persistence engine
├── SessionRestore.sh           # Session restoration logic
├── SessionManager.sh           # GUI management interface
├── HyprlandExitMonitor.sh      # Process termination monitor
├── SessionSignalHandler.sh     # Signal-based save trigger
├── PeriodicSessionSaver.sh     # Periodic backup utility
└── TestSessionManagement.sh    # Testing and validation suite
```

### Data Structure

```
sessions/
├── last_session.json          # Primary session data
├── session.log                # Operation logs
└── backups/                   # Historical sessions (max 10)
    ├── session_YYYYMMDD_HHMMSS.json
    └── ...
```

### Session Data Format

```json
{
  "timestamp": "ISO-8601 datetime",
  "monitors": [...],
  "active_workspace": {...},
  "workspaces": [...],
  "clients": [...]
}
```

## Configuration

### Keyboard Bindings

Add to `UserConfigs/UserKeybinds.conf`:

```bash
# Session Management
bind = $mainMod SHIFT, S, exec, $scriptsDir/SessionSave.sh manual
bind = $mainMod CTRL, S, exec, $scriptsDir/SessionRestore.sh restore
bind = $mainMod ALT, S, exec, $scriptsDir/SessionManager.sh
```

### Auto-start Configuration

Add to `UserConfigs/Startup_Apps.conf`:

```bash
# Session management components
exec-once = $scriptsDir/SessionRestore.sh delayed 3
exec-once = $scriptsDir/HyprlandExitMonitor.sh
exec-once = $scriptsDir/SessionSignalHandler.sh
```

### SystemD Integration

Service file: `~/.config/systemd/user/hyprland-session-save.service`

```ini
[Unit]
Description=Hyprland Session Save Service
DefaultDependencies=false
Before=shutdown.target reboot.target halt.target
Conflicts=shutdown.target reboot.target halt.target
After=graphical-session.target

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/bin/true
ExecStop=/bin/bash -c 'if pgrep -x "Hyprland" > /dev/null; then /home/user/.config/hypr/scripts/SessionSave.sh auto; fi'
TimeoutStopSec=30
Environment=WAYLAND_DISPLAY=wayland-0
Environment=XDG_RUNTIME_DIR=%t

[Install]
WantedBy=graphical-session.target
```

## Supported Applications

The system includes built-in recognition for:

- **Browsers**: Firefox, Chrome, Chromium, Edge, Brave
- **Editors**: VS Code, VSCodium, JetBrains IDEs
- **Terminals**: Kitty, Alacritty
- **File Managers**: Thunar, Nautilus
- **Communication**: Discord, Telegram, Element
- **Media**: OBS Studio, VLC, MPV
- **System Tools**: Pavucontrol, Network Manager

### Adding Custom Applications

Edit `SessionRestore.sh` to add support for new applications:

```bash
case "$CLASS" in
    "your-app-class")
        APP_COMMAND="your-app-command"
        ;;
esac
```

## API Reference

### SessionSave.sh

```bash
# Usage
SessionSave.sh [manual|auto]

# Parameters
manual    # Manual save with user notification
auto      # Automatic save during logout
```

### SessionRestore.sh

```bash
# Usage
SessionRestore.sh [restore|delayed|list]

# Parameters
restore       # Immediate restoration
delayed N     # Restore after N seconds (default: 5)
list          # List available sessions
```

### SessionManager.sh

Provides GUI interface with options:
- Save Current Session
- Restore Last Session
- List Sessions
- Clear Sessions

## Error Handling

### Timeout Protection

All Hyprland IPC calls include timeout protection:

```bash
if CLIENTS=$(timeout 10 hyprctl clients -j 2>/dev/null); then
    # Process clients
else
    # Handle timeout
fi
```

### Backup Recovery

If primary session file fails:
1. Attempt to restore from most recent backup
2. Validate JSON integrity before restoration
3. Log failure reasons for debugging

### Signal Handling

Multiple save mechanisms ensure reliability:
- Process termination monitoring
- Signal handler for SIGTERM/SIGINT
- SystemD service integration

## Debugging

### Log Analysis

```bash
# Real-time monitoring
tail -f ~/.config/hypr/sessions/session.log

# Filter by component
grep "MONITOR:" ~/.config/hypr/sessions/session.log
grep "SIGNAL:" ~/.config/hypr/sessions/session.log
```

### Manual Testing

```bash
# Test session save
~/.config/hypr/scripts/SessionSave.sh manual

# Test session restore
~/.config/hypr/scripts/SessionRestore.sh restore

# Run full test suite
~/.config/hypr/scripts/TestSessionManagement.sh
```

### Common Issues

1. **Empty session saves**
   - Check Hyprland responsiveness
   - Verify hyprctl accessibility
   - Review timeout values

2. **Application launch failures**
   - Validate application commands
   - Check PATH environment
   - Review application-specific requirements

3. **Workspace restoration issues**
   - Verify workspace configuration
   - Check monitor setup
   - Review workspace rules

## Performance Considerations

- Session save operations typically complete within 1-2 seconds
- Restoration delay (3 seconds default) allows desktop environment initialization
- Backup retention limited to 10 files to prevent disk space issues
- Periodic saving (if enabled) runs every 5 minutes with minimal system impact

## Security Notes

- Session files contain application class names and window titles
- No sensitive data (passwords, tokens) is stored
- Local file permissions restrict access to user account
- SystemD service runs with user privileges only

---

# 中文文档

**[English](#overview)** | 中文

---

## 概览

为 Hyprland 设计的综合会话管理系统，提供类似 macOS 的窗口恢复功能。该系统能够自动保存和恢复应用程序窗口、工作区布局以及显示器配置。

## 功能特性

- **自动会话持久化**: 在注销/关机时保存当前会话状态
- **智能窗口恢复**: 将应用程序恢复到之前的工作区和位置
- **多层保存机制**: 多重备份系统确保可靠的会话捕获
- **备份恢复**: 发生损坏时自动回退到之前的会话
- **手动会话控制**: 键盘快捷键和图形界面进行会话管理
- **应用程序识别**: 内置对常见 Linux 应用程序的支持
- **工作区保持**: 维护工作区布局和活动工作区状态

## 系统架构

### 核心组件

```
scripts/
├── SessionSave.sh              # 会话持久化引擎
├── SessionRestore.sh           # 会话恢复逻辑
├── SessionManager.sh           # GUI 管理界面
├── HyprlandExitMonitor.sh      # 进程终止监控器
├── SessionSignalHandler.sh     # 基于信号的保存触发器
├── PeriodicSessionSaver.sh     # 定期备份工具
└── TestSessionManagement.sh    # 测试和验证套件
```

### 数据结构

```
sessions/
├── last_session.json          # 主要会话数据
├── session.log                # 操作日志
└── backups/                   # 历史会话（最多10个）
    ├── session_YYYYMMDD_HHMMSS.json
    └── ...
```

### 会话数据格式

```json
{
  "timestamp": "ISO-8601 时间戳",
  "monitors": [...],
  "active_workspace": {...},
  "workspaces": [...],
  "clients": [...]
}
```

## 配置说明

### 键盘绑定

添加到 `UserConfigs/UserKeybinds.conf`：

```bash
# 会话管理
bind = $mainMod SHIFT, S, exec, $scriptsDir/SessionSave.sh manual
bind = $mainMod CTRL, S, exec, $scriptsDir/SessionRestore.sh restore
bind = $mainMod ALT, S, exec, $scriptsDir/SessionManager.sh
```

### 自动启动配置

添加到 `UserConfigs/Startup_Apps.conf`：

```bash
# 会话管理组件
exec-once = $scriptsDir/SessionRestore.sh delayed 3
exec-once = $scriptsDir/HyprlandExitMonitor.sh
exec-once = $scriptsDir/SessionSignalHandler.sh
```

### SystemD 集成

服务文件：`~/.config/systemd/user/hyprland-session-save.service`

```ini
[Unit]
Description=Hyprland Session Save Service
DefaultDependencies=false
Before=shutdown.target reboot.target halt.target
Conflicts=shutdown.target reboot.target halt.target
After=graphical-session.target

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/bin/true
ExecStop=/bin/bash -c 'if pgrep -x "Hyprland" > /dev/null; then /home/user/.config/hypr/scripts/SessionSave.sh auto; fi'
TimeoutStopSec=30
Environment=WAYLAND_DISPLAY=wayland-0
Environment=XDG_RUNTIME_DIR=%t

[Install]
WantedBy=graphical-session.target
```

## 支持的应用程序

系统内置支持以下应用程序：

- **浏览器**: Firefox, Chrome, Chromium, Edge, Brave
- **编辑器**: VS Code, VSCodium, JetBrains IDEs
- **终端**: Kitty, Alacritty
- **文件管理器**: Thunar, Nautilus
- **通讯工具**: Discord, Telegram, Element
- **多媒体**: OBS Studio, VLC, MPV
- **系统工具**: Pavucontrol, Network Manager

### 添加自定义应用程序

编辑 `SessionRestore.sh` 以添加新应用程序支持：

```bash
case "$CLASS" in
    "your-app-class")
        APP_COMMAND="your-app-command"
        ;;
esac
```

## API 参考

### SessionSave.sh

```bash
# 用法
SessionSave.sh [manual|auto]

# 参数
manual    # 手动保存并显示用户通知
auto      # 注销时自动保存
```

### SessionRestore.sh

```bash
# 用法
SessionRestore.sh [restore|delayed|list]

# 参数
restore       # 立即恢复
delayed N     # N秒后恢复（默认：5）
list          # 列出可用会话
```

### SessionManager.sh

提供图形界面，包含选项：
- 保存当前会话
- 恢复最后会话
- 列出会话
- 清除会话

## 错误处理

### 超时保护

所有 Hyprland IPC 调用包含超时保护：

```bash
if CLIENTS=$(timeout 10 hyprctl clients -j 2>/dev/null); then
    # 处理客户端
else
    # 处理超时
fi
```

### 备份恢复

如果主会话文件失败：
1. 尝试从最新备份恢复
2. 恢复前验证 JSON 完整性
3. 记录失败原因用于调试

### 信号处理

多重保存机制确保可靠性：
- 进程终止监控
- SIGTERM/SIGINT 信号处理器
- SystemD 服务集成

## 调试

### 日志分析

```bash
# 实时监控
tail -f ~/.config/hypr/sessions/session.log

# 按组件过滤
grep "MONITOR:" ~/.config/hypr/sessions/session.log
grep "SIGNAL:" ~/.config/hypr/sessions/session.log
```

### 手动测试

```bash
# 测试会话保存
~/.config/hypr/scripts/SessionSave.sh manual

# 测试会话恢复
~/.config/hypr/scripts/SessionRestore.sh restore

# 运行完整测试套件
~/.config/hypr/scripts/TestSessionManagement.sh
```

### 常见问题

1. **空会话保存**
   - 检查 Hyprland 响应性
   - 验证 hyprctl 可访问性
   - 审查超时值

2. **应用程序启动失败**
   - 验证应用程序命令
   - 检查 PATH 环境
   - 审查应用程序特定要求

3. **工作区恢复问题**
   - 验证工作区配置
   - 检查显示器设置
   - 审查工作区规则

## 性能考虑

- 会话保存操作通常在1-2秒内完成
- 恢复延迟（默认3秒）允许桌面环境初始化
- 备份保留限制为10个文件以防止磁盘空间问题
- 定期保存（如果启用）每5分钟运行一次，对系统影响最小

## 安全说明

- 会话文件包含应用程序类名和窗口标题
- 不存储敏感数据（密码、令牌）
- 本地文件权限限制用户账户访问
- SystemD 服务仅以用户权限运行