-- Personal Omarchy keybindings. Defaults are loaded first, then this file.
-- The goal is the same keymap as .config/hypr-pure/bindings.conf (macOS-like):
-- Super = Cmd, Alt = Option, Vim-style hjkl for focus/move/resize.

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
rebind("SUPER + SPACE", "Application launcher", launcher)
rebind("SUPER + D", "Application launcher", launcher)

-- Split direction for the terminal launcher helper
rebind("SUPER + Z", "Set horizontal split", "mkdir -p ~/.cache && echo h > ~/.cache/hypr-split-mode")
rebind("SUPER + X", "Set vertical split", "mkdir -p ~/.cache && echo v > ~/.cache/hypr-split-mode")
rebind("SUPER + E", "Toggle split", hl.dsp.layout("togglesplit"))

-- Window control (SUPER+W close and SUPER+F fullscreen already match pure)
rebind("SUPER + SHIFT + V", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))

-- Focus with Alt + hjkl (matches the macOS setup)
rebind("ALT + H", "Focus left", hl.dsp.focus({ direction = "l" }))
rebind("ALT + J", "Focus down", hl.dsp.focus({ direction = "d" }))
rebind("ALT + K", "Focus up", hl.dsp.focus({ direction = "u" }))
rebind("ALT + L", "Focus right", hl.dsp.focus({ direction = "r" }))

-- Move windows with Super + Shift + hjkl, same dispatcher as pure's
-- "movewindow" (swap only works when there is a neighbour to swap with).
rebind("SUPER + SHIFT + H", "Move window left", hl.dsp.window.move({ direction = "l" }))
rebind("SUPER + SHIFT + J", "Move window down", hl.dsp.window.move({ direction = "d" }))
rebind("SUPER + SHIFT + K", "Move window up", hl.dsp.window.move({ direction = "u" }))
rebind("SUPER + SHIFT + L", "Move window right", hl.dsp.window.move({ direction = "r" }))

-- Workspaces 1-10, Super+Tab cycles (same as pure)
for i = 1, 10 do
  local key = "code:" .. tostring(i + 9)
  rebind("SUPER + " .. key, "Workspace " .. i, hl.dsp.focus({ workspace = tostring(i) }))
  rebind("SUPER + SHIFT + " .. key, "Move to workspace " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
end

rebind("SUPER + TAB", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
rebind("SUPER + SHIFT + TAB", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))

-- Resize mode, same as the pure config: Super+R, then hjkl, Escape to leave.
rebind("SUPER + R", "Resize mode", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
  local function resize(x, y)
    return hl.dsp.window.resize({ x = x, y = y, relative = true })
  end

  hl.bind("h", resize(-20, 0), { repeating = true, description = "Resize left" })
  hl.bind("j", resize(0, 20), { repeating = true, description = "Resize down" })
  hl.bind("k", resize(0, -20), { repeating = true, description = "Resize up" })
  hl.bind("l", resize(20, 0), { repeating = true, description = "Resize right" })
  hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit resize mode" })
end)

-- Drop Omarchy bindings on single Super+key combos that pure does not have, so
-- nothing changes layout/geometry by accident (SUPER+L was switching layouts).
hl.unbind("SUPER + J")        -- toggle window split
hl.unbind("SUPER + L")        -- toggle workspace layout
hl.unbind("SUPER + T")        -- toggle floating/tiling (pure uses SUPER+SHIFT+V)
hl.unbind("SUPER + G")        -- toggle window grouping
hl.unbind("SUPER + O")        -- pop window out
hl.unbind("SUPER + S")        -- scratchpad
hl.unbind("SUPER + K")        -- keybindings menu
hl.unbind("SUPER + ESCAPE")   -- system menu
hl.unbind("SUPER + comma")    -- dismiss notification
hl.unbind("SUPER + SLASH")    -- monitor scaling
hl.unbind("SUPER + HOME")     -- restore window width
hl.unbind("SUPER + BACKSPACE")            -- transparency
hl.unbind("SUPER + SHIFT + BACKSPACE")    -- gaps
hl.unbind("SUPER + code:20")               -- window width nudge
hl.unbind("SUPER + code:21")
hl.unbind("SUPER + SHIFT + code:20")
hl.unbind("SUPER + SHIFT + code:21")
hl.unbind("SUPER + ALT + code:20")
hl.unbind("SUPER + ALT + code:21")
hl.unbind("SUPER + SHIFT + ALT + code:20")
hl.unbind("SUPER + SHIFT + ALT + code:21")
hl.unbind("SUPER + CTRL + code:20")
hl.unbind("SUPER + CTRL + code:21")
hl.unbind("SUPER + CTRL + SHIFT + code:20")
hl.unbind("SUPER + CTRL + SHIFT + code:21")

-- Screenshots and lock screen
rebind("SUPER + P", "Select screenshot area", "grim -g \"$(slurp)\" - | wl-copy")
rebind("SUPER + PRINT", "Save screenshot", "mkdir -p ~/Pictures && grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png")
rebind("SUPER + ALT + L", "Lock screen", "omarchy-system-lock")

-- Reapply display layout when the laptop lid changes
rebind("switch:on:Lid Switch", "Apply monitor layout", "~/.config/hypr/scripts/apply-monitor-layout.sh")
rebind("switch:off:Lid Switch", "Apply monitor layout", "~/.config/hypr/scripts/apply-monitor-layout.sh")
