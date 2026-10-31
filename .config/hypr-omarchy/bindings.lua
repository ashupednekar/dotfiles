-- Personal Omarchy keybindings. Defaults are loaded before this file.
-- Use Omarchy's rebind helper when available; otherwise use Hyprland's Lua API.

local function rebind(keys, description, command)
  if type(o.rebind) == "function" then
    o.rebind(keys, description, command)
  else
    hl.unbind(keys)
    o.bind(keys, description, command)
  end
end

-- Apps and launcher
rebind("SUPER + RETURN", "Open terminal", { launch = "ghostty" })
rebind("SUPER + B", "Open browser", { launch = "zen-browser" })
rebind("SUPER + SHIFT + B", "Open private browser", "zen-browser --incognito")
rebind("SUPER + SPACE", "Application launcher", "rofi -show drun")
rebind("SUPER + D", "Application launcher", "rofi -show drun")

-- Clipboard shortcuts (Super acts as Command)
rebind("SUPER + C", "Copy", "hyprctl dispatch sendshortcut CTRL, C")
rebind("SUPER + V", "Paste", "hyprctl dispatch sendshortcut CTRL, V")

-- Split direction for the terminal launcher helper
rebind("SUPER + Z", "Set horizontal split", "mkdir -p ~/.cache && echo h > ~/.cache/hypr-split-mode")
rebind("SUPER + X", "Set vertical split", "mkdir -p ~/.cache && echo v > ~/.cache/hypr-split-mode")
rebind("SUPER + E", "Toggle split", "hyprctl dispatch layoutmsg togglesplit")

-- Window controls
rebind("SUPER + W", "Close window", "hyprctl dispatch killactive")
rebind("SUPER + F", "Toggle fullscreen", "hyprctl dispatch fullscreen 0")
rebind("SUPER + SHIFT + V", "Toggle floating", "hyprctl dispatch togglefloating")

-- Focus with Alt + hjkl
rebind("ALT + H", "Focus left", "hyprctl dispatch movefocus l")
rebind("ALT + J", "Focus down", "hyprctl dispatch movefocus d")
rebind("ALT + K", "Focus up", "hyprctl dispatch movefocus u")
rebind("ALT + L", "Focus right", "hyprctl dispatch movefocus r")

-- Focus and move windows with arrow keys / Super + hjkl
rebind("SUPER + LEFT", "Focus left", "hyprctl dispatch movefocus l")
rebind("SUPER + RIGHT", "Focus right", "hyprctl dispatch movefocus r")
rebind("SUPER + UP", "Focus up", "hyprctl dispatch movefocus u")
rebind("SUPER + DOWN", "Focus down", "hyprctl dispatch movefocus d")
rebind("SUPER + SHIFT + H", "Move window left", "hyprctl dispatch movewindow l")
rebind("SUPER + SHIFT + J", "Move window down", "hyprctl dispatch movewindow d")
rebind("SUPER + SHIFT + K", "Move window up", "hyprctl dispatch movewindow u")
rebind("SUPER + SHIFT + L", "Move window right", "hyprctl dispatch movewindow r")

-- Workspaces (key names are used because Omarchy's Lua bind helper does not parse code:N)
for workspace = 1, 10 do
  local key = workspace == 10 and "0" or tostring(workspace)
  rebind("SUPER + " .. key, "Workspace " .. workspace, "hyprctl dispatch workspace " .. workspace)
  rebind("SUPER + SHIFT + " .. key, "Move window to workspace " .. workspace,
    "hyprctl dispatch movetoworkspace " .. workspace)
end
rebind("SUPER + TAB", "Next workspace", "hyprctl dispatch workspace e+1")
rebind("SUPER + SHIFT + TAB", "Previous workspace", "hyprctl dispatch workspace e-1")

-- Resize windows with Super + Ctrl + hjkl.
rebind("SUPER + CTRL + H", "Resize left", "hyprctl dispatch resizeactive -20 0")
rebind("SUPER + CTRL + J", "Resize down", "hyprctl dispatch resizeactive 0 20")
rebind("SUPER + CTRL + K", "Resize up", "hyprctl dispatch resizeactive 0 -20")
rebind("SUPER + CTRL + L", "Resize right", "hyprctl dispatch resizeactive 20 0")
-- Mouse and media keys
rebind("SUPER + mouse:272", "Move window", "hyprctl dispatch movewindow")
rebind("SUPER + mouse:273", "Resize window", "hyprctl dispatch resizewindow")
rebind("SUPER + mouse_down", "Next workspace", "hyprctl dispatch workspace e+1")
rebind("SUPER + mouse_up", "Previous workspace", "hyprctl dispatch workspace e-1")
rebind("XF86AudioRaiseVolume", "Volume up", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")
rebind("XF86AudioLowerVolume", "Volume down", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
rebind("XF86AudioMute", "Mute output", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
rebind("XF86AudioMicMute", "Mute microphone", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
rebind("XF86MonBrightnessUp", "Brightness up", "brightnessctl set 5%+")
rebind("XF86MonBrightnessDown", "Brightness down", "brightnessctl set 5%-")
rebind("XF86AudioPlay", "Play or pause", "playerctl play-pause")
rebind("XF86AudioNext", "Next track", "playerctl next")
rebind("XF86AudioPrev", "Previous track", "playerctl previous")

-- Screenshots and lock screen
rebind("SUPER + P", "Select screenshot area", "grim -g \"$(slurp)\" - | wl-copy")
rebind("SUPER + PRINT", "Save screenshot", "mkdir -p ~/Pictures && grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png")
rebind("SUPER + ALT + L", "Lock screen", "omarchy-lock-screen")

-- Reapply display layout when the laptop lid changes
rebind("switch:on:Lid Switch", "Apply monitor layout", "~/.config/hypr/scripts/apply-monitor-layout.sh")
rebind("switch:off:Lid Switch", "Apply monitor layout", "~/.config/hypr/scripts/apply-monitor-layout.sh")
