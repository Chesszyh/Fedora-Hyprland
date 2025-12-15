# Hyprland

## application-style.conf
定义 GTK 应用程序的样式、主题、图标和字体，以确保在 Hyprland 环境下外观统一。主要使用 `gsettings` 命令来设置。

## configs
存放一些基础的、不常变动的配置片段。

### Keybinds.conf
定义了系统的核心快捷键。用户可以通过 `UserConfigs/UserKeybinds.conf` 来覆盖或添加新的快捷键。

## hypridle.conf
`hypridle` 的配置文件，用于设置系统空闲时的行为。例如，定义超时多长时间后锁定屏幕、关闭显示器或进入睡眠状态。

## hyprland.conf
**Hyprland 的主配置文件**，是所有配置的入口。它通过 `source` 命令加载其他所有 `.conf` 文件，将模块化的配置组合在一起。

## hyprlock-1080p.conf
为 1080p 分辨率屏幕优化的 `hyprlock` 锁屏样式文件。

## hyprlock.conf
默认的 `hyprlock` 锁屏样式文件，定义了锁屏界面的背景、文本、输入框等元素的外观。

## initial-boot.sh
系统首次启动时执行一次的脚本，用于完成初始化设置。

## Monitor_Profiles
存放不同显示器布局的配置文件。

### default.conf
默认的显示器布局配置。

## monitors.conf
定义显示器的配置文件。它会设置每个已连接显示器的分辨率、刷新率、位置以及分配给它的工作区。

## scripts
**核心功能脚本目录**。包含了绝大部分功能的实现脚本，由快捷键或 Waybar 点击事件调用。

### AirplaneMode.sh
切换飞行模式的脚本。

### Animations.sh
用于切换 `animations/` 目录中不同动画风格的脚本。

### Battery.sh
获取电池状态和百分比，主要用于在 Waybar 中显示。

### BrightnessKbd.sh
处理键盘背光亮度的脚本。

### Brightness.sh
使用 `brightnessctl` 调节屏幕亮度的脚本。

### ChangeBlur.sh
调整窗口背景模糊度的脚本。

### ChangeLayout.sh
切换键盘布局的脚本。

### ClipManager.sh
使用 `rofi` 和 `cliphist` 显示剪贴板历史记录。

### DarkLight.sh
切换系统深色/浅色主题的脚本。

### Distro_update.sh
用于更新系统的脚本 (似乎是为 Arch Linux 设计的)。

### Dropterminal.sh
实现下拉式终端功能的脚本。

### GameMode.sh
切换游戏模式。通常会禁用动画、模糊、阴影等效果以提升游戏性能。

### Hypridle.sh
用于启动 `hypridle` 进程的脚本。

### KeyBinds.sh
(此文件内容为空)

### KeyHints.sh
在屏幕上显示一个包含所有主要快捷键的提示窗口。

### KillActiveProcess.sh
强制杀死当前聚焦窗口的进程。

### Kitty_themes.sh
为 Kitty 终端切换主题的脚本。

### Kool_Quick_Settings.sh
一个 Rofi 菜单，提供对各种设置的快速访问。

### KooLsDotsUpdate.sh
用于更新这套 dotfiles 配置的脚本。

### LockScreen.sh
执行锁屏命令 (`hyprlock`) 的脚本。

### MediaCtrl.sh
使用 `playerctl` 控制媒体播放（播放/暂停/下一首/上一首）。

### MonitorProfiles.sh
用于切换 `Monitor_Profiles/` 中不同显示器配置的脚本。

### Polkit-NixOS.sh
为 NixOS 设置 Polkit 认证代理的脚本。

### Polkit.sh
为其他发行版设置 Polkit 认证代理的脚本。

### PortalHyprland.sh
设置 XDG Desktop Portal for Hyprland 的脚本，用于改善 Flatpak 应用的集成。

### RefreshNoWaybar.sh
在不重启 Waybar 的情况下刷新 Hyprland 配置。

### Refresh.sh
完全刷新 Hyprland 配置，包括重启 Waybar。

### RofiEmoji.sh
使用 Rofi 选择并复制 Emoji 表情。

### RofiSearch.sh
使用 Rofi 在网络上进行搜索。

### RofiThemeSelector-modified.sh
一个修改版的 Rofi 主题选择器。

### RofiThemeSelector.sh
一个 Rofi 菜单，用于选择和应用不同的 Rofi 主题。

### ScreenShot.sh
功能强大的截图脚本，支持全屏、窗口和选区截图，并提供编辑选项。

### sddm_wallpaper.sh
设置 SDDM 登录管理器背景壁纸的脚本。

### Sounds.sh
播放系统提示音的脚本。

### SwitchKeyboardLayout.sh
切换键盘布局的脚本。

### Tak0-Autodispatch.sh
一个用于自动将窗口分配到不同工作区的脚本。

### Tak0-Per-Window-Switch.sh
一个用于在不同窗口间切换的脚本。

### TouchPad.sh
启用或禁用触摸板的脚本。

### UptimeNixOS.sh
在 NixOS 上获取系统运行时间的脚本。

### Volume.sh
使用 `pamixer` 控制系统音量的脚本。

### WallustSwww.sh
核心脚本之一，使用 `swww` 设置壁纸，然后运行 `wallust` 从壁纸中提取颜色生成新的系统主题。

### WaybarCava.sh
为 Waybar 生成 CAVA 音频可视化数据的脚本。

### WaybarLayout.sh
切换 Waybar 布局的脚本。

### WaybarScripts.sh
(此文件内容为空)

### WaybarStyles.sh
切换 Waybar 样式的脚本。

### Wlogout.sh
启动 `wlogout` 电源/注销菜单的脚本。

## UserConfigs
**用户配置核心目录**。所有个人定制化内容都在这里修改，以避免在更新基础配置时产生冲突。

### 00-Readme
此目录的说明文件，强调了其作为用户配置中心的重要性。

### 01-UserDefaults.conf
用户的默认配置，通常包含一些变量定义。

### ENVariables.conf
用于设置用户特定的环境变量。

### LaptopDisplay.conf
针对笔记本电脑内置显示器的特定配置。

### Laptops.conf
针对笔记本电脑的特定设置，例如合盖行为。

### Startup_Apps.conf
**用户开机自启应用**。在这里添加你希望在登录时自动启动的程序。

### UserAnimations.conf
用于覆盖默认的动画配置。

### UserDecorations.conf
用于覆盖默认的窗口装饰（如边框、阴影）配置。

### UserKeybinds.conf
**用户快捷键配置**。在这里添加或覆盖你的个人快捷键。

### UserSettings.conf
**用户通用设置**。在这里覆盖任何 Hyprland 的默认设置。

### WindowRules.conf
**用户窗口规则**。在这里为你自己的应用程序设置窗口规则（如浮动、大小、位置、工作区分配等）。

### WindowRules-old.conf
旧的窗口规则备份文件。

### WorkSpaceRules
定义工作区规则的文件。

## UserScripts
**用户脚本目录**。用于存放用户自己的定制脚本，与系统提供的核心脚本分离。

### 00-Readme
此目录的说明文件。

### RainbowBorders.bak.sh
一个实现彩虹色动态边框效果的脚本备份。

### RofiBeats.sh
一个用于播放音乐的 Rofi 脚本。

### RofiCalc.sh
一个 Rofi 计算器。

### Tak0-Autodispatch.sh
(重复的脚本)

### WallpaperAutoChange.sh
自动更换壁纸的脚本。

### WallpaperEffects.sh
为壁纸添加特效的脚本。

### WallpaperRandom.sh
随机选择并设置壁纸的脚本。

### WallpaperSelect.sh
使用 Rofi 菜单选择壁纸的脚本。

### Weather.py
一个获取天气的 Python 脚本，可能用于 Waybar。

### Weather.sh
一个获取天气的 Shell 脚本。

### ZshChangeTheme.sh
切换 Zsh 主题的脚本。

## wallpaper_effects
存放经过特效处理的壁纸的目录。

## wallust
存放 `wallust` 生成的色彩主题文件的目录。

### wallust-hyprland.conf
由 `wallust` 生成的 Hyprland 颜色配置文件，会被主配置加载以应用主题色。

## workspaces.conf
定义工作区规则，例如将特定应用（如 Discord, Steam）默认打开在指定的工作区。
