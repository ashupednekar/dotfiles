#!/usr/bin/env bash
set -euo pipefail

layout_script="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/apply-monitor-layout.sh"
last_state=""

snapshot() {
  {
    for state_file in /proc/acpi/button/lid/*/state; do
      [[ -r "$state_file" ]] && cat "$state_file"
    done

    for status_file in /sys/class/drm/card*-*/status; do
      [[ -r "$status_file" ]] || continue
      printf '%s=' "${status_file%/status}"
      cat "$status_file"
    done
  } | sort
}

sleep 1
"$layout_script" || true

while true; do
  state="$(snapshot)"
  if [[ "$state" != "$last_state" ]]; then
    "$layout_script" || true
    last_state="$state"
  fi

  sleep 2
done
