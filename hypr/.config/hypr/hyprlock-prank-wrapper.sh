#!/bin/bash
# Hyprlock prank wrapper - auto-fails after 3 seconds of typing

# Path to prank config
PRANK_CONFIG="$HOME/.config/hypr/hyprlock-prank.conf"

while true; do
    hyprlock -c "$PRANK_CONFIG" &
    HYPRLOCK_PID=$!
    
    # Wait 3 seconds for any input
    sleep 3
    
    # If hyprlock still running (no unlock), kill it and restart
    # This simulates "auto-submit" of whatever they typed
    if kill -0 $HYPRLOCK_PID 2>/dev/null; then
        kill $HYPRLOCK_PID 2>/dev/null
        sleep 0.5
    fi
done