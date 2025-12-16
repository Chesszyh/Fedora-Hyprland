# Trouble Shooting

## 假死问题

与最开始一样，锁屏时间长了以后就会导致假死，无法再次唤醒。

TODO

## 调整最小化动效

- 添加：win+m: 最小化；alt+m: 显示最小化窗口
- 可优化TODO：点击即恢复窗口原来位置

- 修改的文件：
    - macos-style.conf：动效配置
    - MacOSMinimize.sh
    - MacOSRestore.sh

## 调整落霞文楷字体

- LXGWWenKai-Regular.ttf - 基础中文字体（必须）
- LXGWWenKai-Medium.ttf - 中等粗细，用于标题等（推荐）
- LXGWWenKaiMono-Regular.ttf - 等宽字体，用于代码编辑（推荐）

```bash
# 创建字体下载目录
mkdir -p ~/Downloads/fonts

# 进入下载目录
cd ~/Downloads/fonts

# 使用 wget 或 curl 下载字体（需要替换为实际下载链接）
# 示例：从 GitHub releases 下载
wget https://github.com/lxgw/LxgwWenKai/releases/download/v1.330/LXGWWenKai-Regular.ttf
wget https://github.com/lxgw/LxgwWenKai/releases/download/v1.330/LXGWWenKai-Medium.ttf
wget https://github.com/lxgw/LxgwWenKai/releases/download/v1.330/LXGWWenKaiMono-Regular.ttf

# 创建用户字体目录
mkdir -p ~/.local/share/fonts

# 复制字体文件到字体目录
cp ~/Downloads/fonts/LXGWWenKai*.ttf ~/.local/share/fonts/

# 刷新字体缓存
fc-cache -fv

# 查看是否成功安装
fc-list | grep -i "lxgw\|wenkai"

# 测试字体匹配
fc-match "LXGW WenKai"

# 创建字体配置目录
mkdir -p ~/.config/fontconfig/conf.d
nano ~/.config/fontconfig/conf.d/50-user.conf
```

```html
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <!-- 全局字体替换 - 使用落霞文楷 -->
    <alias>
        <family>serif</family>
        <prefer>
            <family>LXGW WenKai</family>
            <family>Noto Serif CJK SC</family>
            <family>Source Han Serif CN</family>
        </prefer>
    </alias>

    <alias>
        <family>sans-serif</family>
        <prefer>
            <family>LXGW WenKai</family>
            <family>Noto Sans CJK SC</family>
            <family>Source Han Sans CN</family>
        </prefer>
    </alias>

    <alias>
        <family>monospace</family>
        <prefer>
            <family>LXGW WenKai Mono</family>
            <family>Fira Code</family>
            <family>Noto Sans Mono CJK SC</family>
        </prefer>
    </alias>

    <!-- 中文字体回退到落霞文楷 -->
    <match target="pattern">
        <test qual="any" name="family">
            <string>SimSun</string>
        </test>
        <edit name="family" mode="assign" binding="same">
            <string>LXGW WenKai</string>
        </edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family">
            <string>SimHei</string>
        </test>
        <edit name="family" mode="assign" binding="same">
            <string>LXGW WenKai</string>
        </edit>
    </match>
</fontconfig>
```

调整GTK配置，使用落霞文楷字体、暗色主题：

```bash
# 更新 GTK-3.0 配置使用落霞文楷
cat > ~/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=WhiteSur-Dark
gtk-icon-theme-name=Flat-Remix-Blue-Dark
gtk-font-name=LXGW WenKai 11
gtk-cursor-theme-name=Bibata-Modern-Ice
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
gtk-application-prefer-dark-theme=1
EOF

# 更新 GTK-4.0 配置
cat > ~/.config/gtk-4.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=WhiteSur-Dark
gtk-icon-theme-name=Flat-Remix-Blue-Dark
gtk-font-name=LXGW WenKai 11
gtk-cursor-theme-name=Bibata-Modern-Ice
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
EOF
```

设置系统字体：

```bash
# 设置系统默认字体为落霞文楷
gsettings set org.gnome.desktop.interface font-name 'LXGW WenKai 11'
gsettings set org.gnome.desktop.interface document-font-name 'LXGW WenKai 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'LXGW WenKai Mono 10'

# 刷新字体缓存
fc-cache -fv

# 验证中文字体匹配
fc-match :lang=zh-cn
fc-match "sans-serif:lang=zh-cn"

# 检查新字体是否被正确识别
fc-list | grep "LXGW WenKai"
```

这样就基本没问题了。

原来vscode的字体配置，如果直接在vsc的设置里调整，会有点问题，terminal的字体用落霞文楷会很难看，目前都使用的Consolas。但使用以上方法后，整个vscode的字体也能使用luoxia字体了。挺好看的。

## 无法调节暗色

主要是flatpak安装的应用。现代应用很多使用gtk-4.0，flatpak应用也需要特殊的权限和环境变量才能访问系统主题。

我们需要调整GTK配置, 主要在`~/.config/gtk-4.0/settings.ini`中进行设置。

```bash
# GTK-4.0，3.0配置，参考“落霞文楷”字体一节

# 给 Flatpak 应用授予访问主题的权限
flatpak --user override --filesystem=$HOME/.themes
flatpak --user override --filesystem=$HOME/.icons
flatpak --user override --filesystem=$HOME/.config/gtk-3.0:ro
flatpak --user override --filesystem=$HOME/.config/gtk-4.0:ro

# 设置 Flatpak 应用的环境变量
flatpak --user override --env=GTK_THEME=WhiteSur-Dark
flatpak --user override --env=ICON_THEME=Flat-Remix-Blue-Dark

# 检查全局 Flatpak 覆盖设置
flatpak --user override --show
```

修改`ENVariables.conf`:

```ini
# GTK themes
env = GTK_THEME,WhiteSur-Dark
env = GTK2_RC_FILES,$HOME/.gtkrc-2.0

# Flatpak GTK themes
env = GTK_USE_PORTAL,1
```

## 主屏幕字体太小

调整`monitors.conf`参数：

```ini
# Monitors~
# monitor=,preferred,auto,1
monitor=eDP-1,2560x1600@240,0x0,1.3333333 # from 1 to 1.3333, etc
monitor=HDMI-A-1,1920x1080@60,auto,1
```

其实默认给的缩放1就是正常的，显示太小是因为`gnome-tweaks`里调小了缩放，这两个都会对窗口产生影响。

## 中文打字优化

使用[雾凇拼音](https://github.com/iDvel/rime-ice)以及基于雾凇优化的[白霜拼音](https://github.com/gaboolic/rime-frost).[这个](https://github.com/fcitx/fcitx5-rime)似乎是白霜拼音的fcitx5版本。

雾凇配置时，`fcitx5-configtool`选择中州韵，`fcitx5-remote -r`重启输入法，重新加载配置。

优化后肉眼可见打字快了很多，并且自动纠错能力也强了一些。

## 中文打字时有时无法显示文本候选框

出界了，原因是窗口缩放比例没调好。将`monitors.conf`缩放改为1,就能正常显示输入法了；然后再将`gnome-tweaks`缩放改到1.2左右，界面大小差不多也合适了。其他修改了但不一定起作用的地方：

- `WindowRules.conf`: 

```ini
# Fcitx5 输入法窗口规则
windowrulev2 = float, class:^(fcitx)$
windowrulev2 = nofocus, class:^(fcitx)$
windowrulev2 = minsize 1 1, class:^(fcitx)$
windowrulev2 = dimaround, class:^(fcitx)$
windowrulev2 = noborder, class:^(fcitx)$
windowrulev2 = noshadow, class:^(fcitx)$
windowrulev2 = noblur, class:^(fcitx)$
```

`fcitx5`配置：

```ini
# ~/.config/fcitx5/conf/classicui.conf
# 垂直候选列表
Vertical Candidate List=False
# 候选词窗口跟随光标
WheelForPaging=True
# 字体设置
Font="Noto Sans CJK SC 12"
```

## Swappy启动报错：桌面文件未指定exec字段。

`swappy` 本身不是一个图片查看器，它是个截图标注工具。

`desktop`文件包括：

1. 系统级：`/usr/share/applications/*.desktop`，全系统用户可见，由操作系统或软件包（dnf）提供，不应随便修改（更新时会被覆盖）
2. 用户级：`~/.local/share/applications/*.desktop`，仅当前用户可见，且优先级更高，不会被系统更新覆盖，可自定义修改。

### 1. 用户级`desktop`文件配置

`~/.local/share/applications`：

```ini
[Desktop Entry]
Name=Swappy (Open Image)
Comment=Open images with Swappy for annotation
Exec=swappy -f %F
Terminal=false
Type=Application
Icon=swappy
MimeType=image/png;image/jpeg;
Categories=Graphics;
```

再更新桌面数据库：

```bash
update-desktop-database ~/.local/share/applications/
```

把PNG/JPEG图片文件关联到这个新的桌面文件：

```bash
xdg-mime default swappy-open.desktop image/png
xdg-mime default swappy-open.desktop image/jpeg
```

### 2. 系统级`desktop`文件配置（仅参考）

```ini
Exec=sh -c "if [ -n \"\\$*\" ]; then exec swappy -f \"\\$@\"; else grim -g \"\\$(slurp)\" - | swappy -f -; fi" placeholder %F
```

## Gnome-tweaks + Hyprland: 无法最小化窗口

GNOME Tweaks 设置的窗口按钮是为 GNOME/Mutter 窗口管理器设计的，Hyprland 是独立的 Wayland 合成器，有自己的窗口管理逻辑。两者的窗口控制协议不兼容，因此导致冲突和卡死。

```bash
# 检查当前设置
gsettings get org.gnome.desktop.wm.preferences button-layout

# 禁用gnome的窗口按钮
gsettings set org.gnome.desktop.wm.preferences button-layout ''
```

修改`Keybinds.conf`，添加窗口最小化/隐藏(使用特殊工作区)功能：

```ini
# Hyprland "Minimize" (Move to special workspace)
bind = $mainMod, M, movetoworkspace, special:minimized

# Toggle Special Workspace to see "minimized" windows
bind = $mainMod ALT, M, togglespecialworkspace, minimized
```

## 启动时长时间黑屏

问题：启动电脑的时候，都会先黑屏（实际是左上角有一个下划线，按任意键都没反应）10秒左右，然后才能加载出现桌面。

### 第1次优化

- 在`swww-daemon`启动后立即设置壁纸，这样在其他自启动项加载时不会停留在黑屏界面；并且在启动项 Startup_Apps.conf 中将 session-restore 的延迟从 3 秒缩短为 1 秒。
- 缩短了 SessionRestore.sh 中 session restore 的内部等待循环，从原来的约 8 秒回退到约 2 秒，从而减少启动时应用恢复前的卡顿时间。

未能解决。

### 第2次优化

修改`Startup_Apps.conf`，把所有长驻进程的 exec-once 改为后台运行，避免 Hyprland 顺序等待它们退出。

TODO

## 壁纸

现在开机时壁纸会默认切换到 `~/Pictures/wallpapers/瑞希.jpg`，即使我换了其他壁纸，重启后也会回去。并且锁屏壁纸也一直是这张，我不知道怎么改。

解答：手动替换`cp -r ~/Pictures/wallpapers/瑞希2.jpg ~/.config/hypr/wallpaper_effects/.wallpaper_current`即可。按道理说，每次Ctrl+w切换壁纸时，都会更新`.wallpaper_current`文件，但目前看来并没有生效。

Hyprland小bug太多了，忍一忍吧。