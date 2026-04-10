#!/usr/bin/env bash
# Super+Z sets below mode, Super+X sets right mode.
# Super+Enter calls this — applies preselect then opens terminal atomically.
MODE=$(cat ~/.cache/hypr-split-mode 2>/dev/null || echo "none")

case "$MODE" in
  v) hyprctl dispatch layoutmsg "preselect d" ;;
  h) hyprctl dispatch layoutmsg "preselect r" ;;
esac

rm -f ~/.cache/hypr-split-mode

CWD=$(omarchy-cmd-terminal-cwd 2>/dev/null || pwd)
hyprctl dispatch exec "uwsm app -- ghostty --working-directory=$CWD"
