-- Personal Omarchy keybindings. Defaults are loaded before this file.
-- Keep this list focused on what differs from Omarchy's defaults so native
-- dispatchers (close, fullscreen, workspaces, media keys) keep working.
-- Use Omarchy's rebind helper when available; otherwise use Hyprland's Lua API.

local function rebind(keys, description, command)
  if type(o.rebind) == "function" then
    o.rebind(keys, description, command)
  else
    hl.unbind(keys)
    o.bind(keys, description, command)
  end
end

local launcher = "rofi -show drun 2>/dev/null || dmenu_run 2>/dev/null || omarchy-menu toggle apps"

-- Apps and launcher
rebind("SUPER + RETURN", "Open terminal", "~/.config/hypr/scripts/split-open.sh")
rebind("SUPER + B", "Open browser", { launch = "zen-browser" })
rebind("SUPER + SHIFT + B", "Open private browser", "zen-browser --incognito")
rebind("SUPER + SPACE", "Application launcher", launcher)
rebind("SUPER + D", "Application launcher", launcher)

-- Split direction for the terminal launcher helper
rebind("SUPER + Z", "Set horizontal split", "mkdir -p ~/.cache && echo h > ~/.cache/hypr-split-mode")
rebind("SUPER + X", "Set vertical split", "mkdir -p ~/.cache && echo v > ~/.cache/hypr-split-mode")
rebind("SUPER + E", "Toggle split", hl.dsp.layout("togglesplit"))

-- Window controls that differ from Omarchy's defaults
rebind("SUPER + SHIFT + V", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))

-- Focus with Alt + hjkl (matches the macOS setup)
rebind("ALT + H", "Focus left", hl.dsp.focus({ direction = "l" }))
rebind("ALT + J", "Focus down", hl.dsp.focus({ direction = "d" }))
rebind("ALT + K", "Focus up", hl.dsp.focus({ direction = "u" }))
rebind("ALT + L", "Focus right", hl.dsp.focus({ direction = "r" }))

-- Move windows with Super + Shift + hjkl
rebind("SUPER + SHIFT + H", "Move window left", hl.dsp.window.swap({ direction = "l" }))
rebind("SUPER + SHIFT + J", "Move window down", hl.dsp.window.swap({ direction = "d" }))
rebind("SUPER + SHIFT + K", "Move window up", hl.dsp.window.swap({ direction = "u" }))
rebind("SUPER + SHIFT + L", "Move window right", hl.dsp.window.swap({ direction = "r" }))

-- Resize windows with Super + Ctrl + hjkl
rebind("SUPER + CTRL + H", "Resize left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }))
rebind("SUPER + CTRL + J", "Resize down", hl.dsp.window.resize({ x = 0, y = 20, relative = true }))
rebind("SUPER + CTRL + K", "Resize up", hl.dsp.window.resize({ x = 0, y = -20, relative = true }))
rebind("SUPER + CTRL + L", "Resize right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }))

-- Screenshots and lock screen
rebind("SUPER + P", "Select screenshot area", "grim -g \"$(slurp)\" - | wl-copy")
rebind("SUPER + PRINT", "Save screenshot", "mkdir -p ~/Pictures && grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png")
rebind("SUPER + ALT + L", "Lock screen", "omarchy-system-lock")

-- Reapply display layout when the laptop lid changes
rebind("switch:on:Lid Switch", "Apply monitor layout", "~/.config/hypr/scripts/apply-monitor-layout.sh")
rebind("switch:off:Lid Switch", "Apply monitor layout", "~/.config/hypr/scripts/apply-monitor-layout.sh")
