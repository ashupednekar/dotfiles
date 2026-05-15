#!/usr/bin/env bash
set -euo pipefail

internal="${HYPR_INTERNAL_MONITOR:-eDP-1}"
external_scale="${HYPR_EXTERNAL_SCALE:-1.5}"
internal_scale="${HYPR_INTERNAL_SCALE:-auto}"

lid_state() {
  local state_file
  for state_file in /proc/acpi/button/lid/*/state; do
    [[ -r "$state_file" ]] || continue
    awk '{print $2}' "$state_file"
    return
  done

  echo open
}

connected_external_monitors() {
  local status_file connector
  for status_file in /sys/class/drm/card*-*/status; do
    [[ -r "$status_file" ]] || continue
    [[ "$(cat "$status_file")" == connected ]] || continue

    connector="${status_file%/status}"
    connector="${connector##*/}"
    connector="${connector#card[0-9]-}"
    connector="${connector#card[0-9][0-9]-}"

    [[ "$connector" != "$internal" ]] || continue
    [[ "$connector" != eDP-* ]] || continue
    [[ "$connector" != LVDS-* ]] || continue
    [[ "$connector" != USB-* ]] || continue

    printf '%s\n' "$connector"
  done | sort -u
}

mapfile -t externals < <(connected_external_monitors)
lid="$(lid_state)"

if (( ${#externals[@]} == 0 )); then
  hyprctl keyword monitor "$internal,preferred,0x0,$internal_scale"
  exit 0
fi

primary="${HYPR_PRIMARY_MONITOR:-${externals[0]}}"

if [[ "$lid" == closed ]]; then
  hyprctl keyword monitor "$primary,preferred,0x0,$external_scale"
  hyprctl keyword monitor "$internal,disable"
else
  hyprctl keyword monitor "$internal,preferred,0x0,$internal_scale"
  hyprctl keyword monitor "$primary,preferred,auto-right,$external_scale"
  for external in "${externals[@]}"; do
    [[ "$external" == "$primary" ]] && continue
    hyprctl keyword monitor "$external,preferred,auto-right,$external_scale"
  done
fi
