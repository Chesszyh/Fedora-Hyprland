# Fedora Hyprland Dotfiles

This is my personal configuration for Fedora 42 running Hyprland.

## Install Hyprland

Refer to the [official installation guide](https://github.com/JaKooLit/Fedora-Hyprland)。This project is also my template.

After install, you should restart and set SDDM(Simple Desktop Display Manager) as your default display manager.

Maybe you should also run `sudo usermod -aG video $(whoami)`, in order to grant your user the necessary permissions for managing display settings.

## ✨ Main features

- **Tiling Window Management**: Customize and switch between your workspaces!
- **Shell Script Support**: Such as brightness/volume adjustment, screenshot, theme switching, etc., refer to `scripts/`.
- **Dynamic Wallpaper and Theme**: Use `swww` and `wallust` to achieve wallpaper switching and wallpaper-based dynamic color themes. Wallpapers are stored in `~/Pictures/wallpapers` by default.
- **Power Management**: Configure screen locking and suspend behavior through `hypridle` and `hyprlock`, refer to `hypridle.conf` and `hyprlock.conf`。

> [!CAUTION]
> Fedora 42 has a freeze issue on my Lenovo Legion (the screen cannot be woken up after suspend), both Gnome and Hyprland are affected. TODO

- **Customizable Keybinds**: Refer to `configs/Keybinds.conf`.
- **Monitor Profiles**: Easily manage different monitor layouts with `Monitor_Profiles/` and `monitors.conf`.

## Animations

<details>
<summary>Animation Configurations</summary>

1. **`00-default.conf`** & **`Mahaveer - me-2.conf`**
   These two configuration files define basic sliding animation styles.
   * **Definition**: Core bezier curves include `wind`, `winIn`, `winOut`, providing quick startup and gentle ending animation rhythms.
   * **Differences & Effects**:
      * Core animations like `windows`, `windowsIn`, `windowsOut`, `windowsMove`, `workspaces` all use slide style.
      * `borderangle` animation is set to loop for continuous visual effects like rainbow borders.
      * Both configurations are nearly identical, providing smooth, classic, and efficient sliding experience.

2. **`01-default - v2.conf`**
   This is the legacy default configuration with more elastic and playful style.
   * **Definition**: Introduces bezier curves like `bounce` and `slow`.
   * **Differences & Effects**:
      * Window animations (`windowsIn`, `windowsOut`) use popin style combined with bounce curves, creating bouncy, non-linear visual effects.
      * Workspace switching (`workspaces`) retains wind curves, making overall animations lively.

3. **`03- Disable Animation.conf`**
   Minimal configuration for disabling all animations.
   * **Definition**: `animations { enabled = no }`.
   * **Effect**: Completely disables Hyprland's animation system for maximum performance and direct visual feedback.

4. **`END-4.conf`**
   Modern animation set from end-4/dots-hyprland, inspired by Material Design 3.
   * **Definition**: Extensively uses `md3_decel` (deceleration) and `md3_accel` (acceleration) bezier curves.
   * **Differences & Effects**:
      * Window animations use popin 60%, providing clean popup effects with 60% initial scaling.
      * Layers and workspaces use slide effects.
      * Special workspaces use slidevert (vertical sliding).
      * Overall style is refined, modern, with physical metaphors.

5. **`HYDE - Vertical.conf`**
   This configuration emphasizes vertical direction animations.
   * **Definition**: Uses curves like `fluent_decel` (fluent deceleration).
   * **Differences & Effects**:
      * Most notable feature is workspace switching (`workspaces`) using slidefadevert 30% style - vertical sliding with 30% fade in/out effects.
      * Window animations use popin 60%.

6. **`HYDE - minimal-1.conf`** & **`ML4W - high.conf`** & **`ML4W - dynamic.conf`**
   These three configurations can be grouped together, all featuring fast, direct sliding styles.
   * **Definition**: All based on `wind`, `winIn`, `winOut` bezier curve sets.
   * **Differences & Effects**:
      * Almost all animations are set to slide, fast speed, no extra decorations.
      * `dynamic.conf` sets borderangle to loop, making border colors rotate continuously.
      * `high.conf` and `minimal-1.conf` set borderangle to once, playing only when triggered.

7. **`HYDE - minimal-2.conf`**
   Minimalist unified style configuration.
   * **Definition**: Only defines and uses one bezier curve named `quart`.
   * **Differences & Effects**: All animations (windows, borders, fades, workspaces) use exactly the same animation curves and speed, achieving high visual unity but might seem monotonous.

8. **`HYDE - optimized.conf`**
   A finely tuned complex animation set.
   * **Definition**: Defines numerous bezier curves like `overshot`, `crazyshot`, `OutBack`.
   * **Differences & Effects**:
      * This is a hybrid style configuration with different animations for different operations. For example, window entrance (`windowsIn`) uses slide, while window closing (`windowsOut`) uses easeOutCirc.
      * Aims to provide highly optimized and responsive "tactile" feel through complex curve combinations while maintaining animation richness.

9. **`ML4W - classic.conf`** & **`ML4W - standard.conf`**
   These two configuration files are almost identical, defining classic "jelly" or "bounce" effects.
   * **Definition**: Uses `myBezier` curves, with `windowsOut` set to popin 80%.
   * **Differences & Effects**: Window animations have slight elasticity or "bounce" feel rather than simple linear motion, presenting a retro dynamic effect.

10. **`ML4W - fast.conf`**
    Can be seen as a fast-paced version of END-4.conf.
    * **Definition**: Also uses Material Design style curves like `md3_decel`.
    * **Differences & Effects**: Window animations are fast popin, workspace switching is fast slide, overall animation duration is shorter, feeling more aggressive.

11. **`ML4W - moving.conf`**
    This configuration aims to create strong "movement sense" and "inertia".
    * **Definition**: Uses curves like `overshot` and `smoothIn/smoothOut`.
    * **Differences & Effects**:
       * Window animations (`windows`) use overshot style slide, sliding past target position then bouncing back.
       * Window movement (`windowsMove`) has obvious ease-in effects, simulating physical inertia.

12. **`Mahaveer - me-1.conf`**
    A personalized configuration integrating multiple styles.
    * **Definition**: Defines numerous bezier curves but mainly enables wind series sliding animations.
    * **Differences & Effects**:
       * Core window animations are similar to HYDE - minimal-1.conf, featuring fast sliding.
       * But it also borrows layer (`layers`) and special workspace (`specialWorkspace`) animation definitions from END-4.conf.
       * This is a hybrid combining fast sliding with modern layer animations.

13. **`macos-style.conf`**
    Similar to macOS effects like Genie Effect (scale folding), fade out, smooth sliding, etc.

</details>

## ⌨️ Shortcuts

`$mainMod` defaults to the `SUPER` (Win) key. You can activate the help menu with `$mainMod`+`H`.

Note that the help menu is not updated automatically. You need to manually update the documentation after modifying shortcuts.

## 🛠️ How to Customize

### Basic Configuration

To keep the configuration clean and easy to update, place all your personal modifications in the UserConfigs directory.

- **Modify Shortcuts**: Edit Keybinds.conf.
- **Add Startup Applications**: Edit Startup_Apps.conf. You can also configure startup applications in `~/.config/autostart/`.
- **Modify Window Rules**: Edit WindowRules.conf.
- **Modify Animation Effects**: Add custom animations under the `Animations/` directory. The selected animation effects will be copied to UserAnimations.conf.
- **Set Environment Variables**: Edit ENVariables.conf.

### Areas to Explore

1.  **Status Bar (Waybar):**
    - **Configuration Files:** `~/.config/waybar/config` and `~/.config/waybar/style.css`.
    - **Customization:** You can add or remove modules (e.g., existing weather, CPU usage, network speed), modify styles, etc. For example, you can try adding a module to Waybar that displays windows in the "Special Workspace," making the "minimized" experience more intuitive.

2.  **Application Launcher (Rofi / AGS):**
    - **Rofi:** The default launcher for this project. It is launched with `Super + D` by default. Configuration is located in `~/.config/rofi/`. You can modify themes, layouts, etc.
    - **AGS (A Gs Shell):** A more powerful component that needs to be installed manually. AGS can create very fancy desktop widgets.

## 💡 Dependencies

To ensure all features work properly, make sure the following main dependencies are installed. Normally, the upstream template repository's auto-installation script should handle all dependencies:

- **Core:** `hyprland`, `hyprlock`, `hypridle`, `waybar`, `rofi`, `kitty`, `thunar`
- **System Tools:** `brightnessctl`, `pamixer`, `playerctl`, `cliphist`, `polkit-kde`
- **Screenshot Tools:** `grim`, `slurp`, `swappy`
- **Themes and Appearance:** `swww`, wallust, `nwg-look`, `wlogout`, `noto-fonts-emoji`
- **Others:** `cava` (used for Waybar audio visualization)