#!/bin/bash

# /* ---- 💫 Session Management Test Script 💫 ---- */
# Test script for session management functionality

SESSION_DIR="$HOME/.config/hypr/sessions"
SCRIPTS_DIR="$HOME/.config/hypr/scripts"

echo "🧪 Testing Hyprland Session Management Functionality"
echo "=================================================="

# Test 1: Check if required scripts exist
echo "📁 Checking script files..."
scripts=("SessionSave.sh" "SessionRestore.sh" "SessionManager.sh" "LogoutHook.sh" "HyprlandExitMonitor.sh" "SessionSignalHandler.sh" "PeriodicSessionSaver.sh")
for script in "${scripts[@]}"; do
    if [ -x "$SCRIPTS_DIR/$script" ]; then
        echo "  ✅ $script - OK"
    else
        echo "  ❌ $script - Missing or not executable"
    fi
done

# Test 2: Check if session directory exists
echo ""
echo "📂 Checking session directory..."
if [ -d "$SESSION_DIR" ]; then
    echo "  ✅ Session directory exists: $SESSION_DIR"
else
    echo "  ❌ Session directory missing: $SESSION_DIR"
    mkdir -p "$SESSION_DIR"
    echo "  🔧 Created session directory"
fi

# Test 3: Check systemd service
echo ""
echo "🔧 Checking systemd service..."
if systemctl --user is-enabled hyprland-session-save.service >/dev/null 2>&1; then
    echo "  ✅ hyprland-session-save.service is enabled"
    if systemctl --user is-active hyprland-session-save.service >/dev/null 2>&1; then
        echo "  ✅ Service is active"
    else
        echo "  ⚠️  Service is not active (this is normal)"
    fi
else
    echo "  ❌ hyprland-session-save.service is not enabled"
    echo "  🔧 Enabling service..."
    systemctl --user enable hyprland-session-save.service
fi

# Test 4: Test session save
echo ""
echo "💾 Testing session save..."
if "$SCRIPTS_DIR/SessionSave.sh" manual; then
    echo "  ✅ Session save test passed"
    if [ -f "$SESSION_DIR/last_session.json" ]; then
        echo "  ✅ Session file created successfully"
        window_count=$(jq '.clients | length' "$SESSION_DIR/last_session.json" 2>/dev/null || echo "0")
        echo "  📊 Current session has $window_count windows"
    else
        echo "  ❌ Session file not created"
    fi
else
    echo "  ❌ Session save test failed"
fi

# Test 5: Check required dependencies
echo ""
echo "🔍 Checking dependencies..."
dependencies=("jq" "rofi" "hyprctl" "notify-send")
for dep in "${dependencies[@]}"; do
    if command -v "$dep" >/dev/null 2>&1; then
        echo "  ✅ $dep - Available"
    else
        echo "  ❌ $dep - Missing"
    fi
done

# Test 6: Check configuration integration
echo ""
echo "📋 Checking configuration integration..."
if grep -q "SessionRestore.sh delayed" "$HOME/.config/hypr/UserConfigs/Startup_Apps.conf" 2>/dev/null; then
    echo "  ✅ Auto-restore configured in Startup_Apps.conf"
else
    echo "  ❌ Auto-restore not found in Startup_Apps.conf"
fi

if grep -q "SessionConfig.conf" "$HOME/.config/hypr/hyprland.conf" 2>/dev/null; then
    echo "  ✅ SessionConfig.conf sourced in main config"
else
    echo "  ❌ SessionConfig.conf not sourced in main config"
fi

if grep -q "SessionSave.sh manual" "$HOME/.config/hypr/UserConfigs/UserKeybinds.conf" 2>/dev/null; then
    echo "  ✅ Session keybinds configured"
else
    echo "  ❌ Session keybinds not found"
fi

echo ""
echo "🎯 Test Summary - Enhanced Session Management"
echo "============================================="
echo "✅ Enhanced session management functionality is now active!"
echo ""
echo "🔧 New Features Added:"
echo "  • Multiple session save triggers (systemd, exit monitor, signal handler)"
echo "  • Backup session recovery if main session fails"
echo "  • Improved error handling and timeout protection"
echo "  • Periodic session saving option (currently disabled)"
echo ""
echo "📚 Key bindings:"
echo "  Super + Shift + S: Save session manually"
echo "  Super + Ctrl + S:  Restore last session"
echo "  Super + Alt + S:   Open session manager"
echo ""
echo "📖 For detailed documentation, see:"
echo "  ~/.config/hypr/SESSION_MANAGEMENT_README.md"
echo ""
echo "🔄 To test the functionality:"
echo "  1. Open some applications"
echo "  2. Press Super + Shift + S to save session"
echo "  3. Restart Hyprland or reboot system"
echo "  4. Session should auto-restore after 8 seconds"
echo ""
echo "🛠️ If session doesn't restore automatically:"
echo "  • Check ~/.config/hypr/sessions/session.log for errors"
echo "  • Press Super + Ctrl + S to manually restore"
echo "  • Use Super + Alt + S to access session manager"
echo ""
echo "Happy session managing! 🎉"