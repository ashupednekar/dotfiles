#!/usr/bin/env bash
# Super+Z (h) / Super+X (v) set split direction persistently.
# Super+Return calls this — applies preselect then opens terminal atomically.
MODE=$(cat ~/.cache/hypr-split-mode 2>/dev/null || echo "none")

case "$MODE" in
  v) hyprctl dispatch layoutmsg "preselect d" ;;
  h) hyprctl dispatch layoutmsg "preselect r" ;;
esac

CWD=$(omarchy-cmd-terminal-cwd 2>/dev/null || pwd)
hyprctl dispatch exec "uwsm app -- ghostty --working-directory=$CWD"
