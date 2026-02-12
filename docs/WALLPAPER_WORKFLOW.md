# Hyprland 壁纸系统改造记录（静态/动态/有声/持久化）

本文档汇总本次会话中提出的所有需求、已完成修改、使用方式与后续维护方法。

## 1. 需求汇总（按提出顺序）

1. 使用指定视频作为 Fedora Hyprland 壁纸。  
2. 视频壁纸要有声音。  
3. 去掉黑边，尽量铺满全屏。  
4. 动态壁纸和静态壁纸切换要更方便，不再手动改配置。  
5. 视频壁纸支持一键静音。  
6. 图片切换有动效，视频切换也希望有动效。  
7. `~/.config/hypr/wallpaper_effects/.wallpaper_current` 作为“当前壁纸副本”要正确更新。  
8. 壁纸状态要持久化（重登后恢复）。  
9. 修复 `Win+Ctrl+W` 与 `Win+Alt+W` 无反应。  
10. 支持 Wallpaper Engine 资源（`repkg` 解包后 `raw.mp4 + 独立音频`）一键合成并接入当前配置。

## 2. 已完成变更

### 2.1 启动配置与持久化变量

文件：`UserConfigs/Startup_Apps.conf`

- 新增变量：
  - `$livewallpaper`
  - `$livewallpaper_audio`
  - `$livewallpaper_opts`
  - `$livewallpaper_mute`
- 启动动态壁纸入口统一为：
  - `exec-once = $UserScripts/WallpaperLiveApply.sh`
- 静态壁纸启动行（`swww`）与动态壁纸启动行可由脚本自动切换注释状态。

### 2.2 新增脚本

1. `UserScripts/WallpaperLiveApply.sh`  
作用：统一应用动态壁纸（读取上述变量），支持：
- 视频路径恢复
- 静音状态恢复（`mute=yes/no`）
- 独立音频文件（`$livewallpaper_audio`）附加播放
- 无配置音频时，自动尝试同名 sidecar 音频

2. `UserScripts/WallpaperVideoMuteToggle.sh`  
作用：一键切换视频静音状态并持久化到 `Startup_Apps.conf`，切换后立即重启动态壁纸生效。

3. `UserScripts/WallpaperModeToggle.sh`  
作用：一键切换静态/动态模式，并自动维护 `Startup_Apps.conf` 的相关行状态。

4. `UserScripts/WallpaperEngineImport.sh`  
作用：`repkg + ffmpeg + 自动接入配置` 一体化导入 Wallpaper Engine 包（见第 5 节）。

### 2.3 修改脚本

文件：`UserScripts/WallpaperSelect.sh`

- `Win+W` 选择器同时支持图片/视频，并修复“同名文件可能误选”问题。
- 视频切换新增“过渡帧动画”（先用 `swww` 对视频预览帧做过渡，再切 `mpvpaper`）。
- 图片切换与视频切换都会更新 `~/.config/hypr/wallpaper_effects/.wallpaper_current`：
  - 图片：直接复制当前图片
  - 视频：提取预览帧后复制
- 选择视频时会更新持久化变量（`livewallpaper` 与 `livewallpaper_audio`）。

### 2.4 快捷键

文件：`UserConfigs/UserKeybinds.conf`

- `Win+W`：`WallpaperSelect.sh`（统一选择图片/视频）
- `Win+Ctrl+W`：`WallpaperModeToggle.sh`（静态/动态模式切换）
- `Win+Alt+W`：`WallpaperVideoMuteToggle.sh`（动态壁纸静音切换）

## 3. 动效机制说明

### 3.1 图片壁纸为什么有动效

在 `UserScripts/WallpaperSelect.sh` 中，`SWWW_PARAMS` 定义了动画参数，实际由 `swww img ... $SWWW_PARAMS` 执行。

### 3.2 视频壁纸为什么现在也有“切换动效”

`mpvpaper` 不提供 `swww` 同款切换动画，所以做法是：
1. 抽取视频预览帧；
2. 用 `swww` 对该帧执行过渡动画；
3. 再启动 `mpvpaper` 播放视频。

## 4. 持久化机制

当前状态会持久化在 `UserConfigs/Startup_Apps.conf`：

- 当前动态壁纸路径：`$livewallpaper`
- 外挂音频路径：`$livewallpaper_audio`
- 动态壁纸参数：`$livewallpaper_opts`
- 静音状态：`$livewallpaper_mute`
- 当前启动模式（静态或动态）：由相关 `exec-once` 行是否注释决定

`~/.config/hypr/wallpaper_effects/.wallpaper_current` 会随切换更新，用于锁屏/静态恢复等场景。

## 5. Wallpaper Engine 一键导入（repkg + ffmpeg）

### 5.1 脚本

`UserScripts/WallpaperEngineImport.sh`

输入：
- 第 1 参数：`.pkg` 文件路径（必填）
- 第 2 参数：输出名称（可选，不填则用包名）

流程：
1. 调用 `/usr/local/bin/repkg extract`，在当前目录生成 `output/`
2. 自动选择主视频（优先 `output/materials/*.raw.mp4`，否则其它视频）
3. 自动选择音频（优先 `output/sounds/*`，否则尝试视频同名 sidecar）
4. `ffmpeg` 合成为最终壁纸 `*.final.mp4`
5. 放入：`~/Pictures/wallpapers/Dynamic-Wallpapers/<name>/`
6. 自动更新 Hypr 配置并立即应用

### 5.2 一键命令（推荐）

在 `.pkg` 所在目录执行：

```bash
bash ~/.config/hypr/UserScripts/WallpaperEngineImport.sh "/path/to/your_wallpaper.pkg"
```

指定输出名称：

```bash
bash ~/.config/hypr/UserScripts/WallpaperEngineImport.sh "/path/to/your_wallpaper.pkg" "atri_school"
```

### 5.3 你当前目录结构约定

- 所有壁纸根目录：`/home/chesszyh/Pictures/wallpapers/`
- 动态壁纸目录：`/home/chesszyh/Pictures/wallpapers/Dynamic-Wallpapers/`

导入脚本会自动把最终成品放到动态壁纸目录下并接入当前 Hypr 配置。

## 6. 常见注意点

1. 如果刚改完按键或配置，执行一次：

```bash
hyprctl reload
```

2. 在非 Hypr 会话（或无 Wayland 环境变量）的终端中直接运行脚本时，可能出现 `notify-send` 或 `mpvpaper` 连接报错，但配置文件写入仍然可生效。  

3. `32s` 视频 + `3min` 音频属于时长不一致素材。导入脚本会循环视频并按音频长度截断，生成单一最终文件，避免运行时分别管理两条媒体流。
