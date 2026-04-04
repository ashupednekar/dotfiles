#!/bin/bash

LAST_LID_STATE="open"

check_external_monitor() {
    swaymsg -t get_outputs | jq -r '.[] | select(.name!="eDP-1") | .name' | head -1
}

set_clamshell_mode() {
    swaymsg output eDP-1 disable
    swaymsg output DP-8 position 0 0
}

set_lid_open_mode() {
    swaymsg output eDP-1 enable
    swaymsg output DP-8 position 1536 0
}

while true; do
    LID_STATE=$(cat /proc/acpi/button/lid/LID0/state 2>/dev/null | awk '{print $2}')
    
    if [[ "$LID_STATE" == "closed" && "$LAST_LID_STATE" == "open" ]]; then
        EXTERNAL=$(check_external_monitor)
        if [[ -n "$EXTERNAL" ]]; then
            set_clamshell_mode
            swaylock -f
        else
            swaylock -f
            sleep 1
            systemctl suspend
        fi
    elif [[ "$LID_STATE" == "open" && "$LAST_LID_STATE" == "closed" ]]; then
        set_lid_open_mode
    fi
    
    LAST_LID_STATE=$LID_STATE
    sleep 2
done