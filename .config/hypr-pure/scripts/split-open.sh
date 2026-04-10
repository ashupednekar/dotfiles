#!/usr/bin/env bash
# Persistent split-direction terminal open.
# Super+Z sets horizontal mode, Super+X sets vertical mode.
# Super+Enter calls this — splits in the last set direction every time.
MODE=$(cat ~/.cache/hypr-split-mode 2>/dev/null || echo "none")

case "$MODE" in
  h) hyprctl dispatch layoutmsg "preselect r" ;;
  v) hyprctl dispatch layoutmsg "preselect d" ;;
esac

hyprctl dispatch exec ghostty
