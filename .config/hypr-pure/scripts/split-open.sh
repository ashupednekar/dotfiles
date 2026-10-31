#!/usr/bin/env bash
# Persistent split-direction terminal open.
# Super+Z sets horizontal mode, Super+X sets vertical mode.
# Super+Enter calls this — splits in the last set direction every time.
#
# Hyprland 0.56+ can be configured in Lua, where `hyprctl dispatch <args>` is
# parsed as Lua and the classic dispatcher syntax fails. Prefer the Lua
# dispatcher form when a Lua config is present, otherwise use the classic one.
set -uo pipefail

MODE=$(cat "$HOME/.cache/hypr-split-mode" 2>/dev/null || echo "none")

preselect() {
  local direction="$1"

  if [[ -f "$HOME/.config/hypr/hyprland.lua" ]]; then
    hyprctl dispatch "hl.dsp.layout(\"preselect $direction\")" >/dev/null 2>&1 || true
  else
    hyprctl dispatch layoutmsg "preselect $direction" >/dev/null 2>&1 || true
  fi
}

case "$MODE" in
  h) preselect r ;;
  v) preselect d ;;
esac

CWD=$(omarchy-cmd-terminal-cwd 2>/dev/null || pwd)
[[ -d "$CWD" ]] || CWD="$HOME"

# Launch directly instead of going through `hyprctl dispatch exec`, which is
# also Lua-only on Lua-configured Hyprland. `setsid` matches Omarchy's own
# terminal launcher so the app owns its session and survives the keybind shell.
if command -v uwsm-app >/dev/null 2>&1; then
  exec setsid uwsm-app -- ghostty --working-directory="$CWD"
fi

exec setsid ghostty --working-directory="$CWD"
