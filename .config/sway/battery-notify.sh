#!/bin/bash

LAST_STATE=""
while true; do
    PERCENT=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "0")
    STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")
    
    if [[ "$STATUS" == "Discharging" && "$PERCENT" -le 15 && "$LAST_STATE" != "critical" ]]; then
        notify-send -u critical "Battery Low" "Battery at $PERCENT% - plug in soon!"
        LAST_STATE="critical"
    elif [[ "$STATUS" == "Discharging" && "$PERCENT" -le 20 && "$LAST_STATE" != "warning" ]]; then
        notify-send -u normal "Battery Warning" "Battery at $PERCENT%"
        LAST_STATE="warning"
    elif [[ "$PERCENT" -ge 25 ]]; then
        LAST_STATE=""
    fi
    sleep 60
done