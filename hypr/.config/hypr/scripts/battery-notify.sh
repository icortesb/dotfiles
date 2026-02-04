#!/usr/bin/env bash

# Battery notification script
# Monitors battery level and sends notifications when battery is low

BATTERY_PATH="/sys/class/power_supply/BAT0"
BATTERY_CAPACITY="$BATTERY_PATH/capacity"
BATTERY_STATUS="$BATTERY_PATH/status"

# Notification thresholds
CRITICAL_LEVEL=10
LOW_LEVEL=20
WARNING_LEVEL=30

# State file to track last notification
STATE_FILE="/tmp/battery-notify-state"

get_battery_level() {
    cat "$BATTERY_CAPACITY" 2>/dev/null || echo "100"
}

get_battery_status() {
    cat "$BATTERY_STATUS" 2>/dev/null || echo "Unknown"
}

send_notification() {
    local level="$1"
    local battery_level="$2"
    local urgency="$3"
    local message="$4"
    
    notify-send -u "$urgency" -i "battery-${level}" \
        "Battery ${level^}: ${battery_level}%" \
        "$message"
}

# Main monitoring loop
while true; do
    battery_level=$(get_battery_level)
    battery_status=$(get_battery_status)
    
    # Only notify if discharging
    if [ "$battery_status" = "Discharging" ]; then
        current_state=""
        
        if [ "$battery_level" -le "$CRITICAL_LEVEL" ]; then
            current_state="critical"
            if [ ! -f "$STATE_FILE" ] || [ "$(cat "$STATE_FILE")" != "$current_state" ]; then
                send_notification "critical" "$battery_level" "critical" \
                    "Battery critically low! Please connect charger immediately."
                echo "$current_state" > "$STATE_FILE"
            fi
        elif [ "$battery_level" -le "$LOW_LEVEL" ]; then
            current_state="low"
            if [ ! -f "$STATE_FILE" ] || [ "$(cat "$STATE_FILE")" != "$current_state" ]; then
                send_notification "low" "$battery_level" "normal" \
                    "Battery is running low. Please connect charger soon."
                echo "$current_state" > "$STATE_FILE"
            fi
        elif [ "$battery_level" -le "$WARNING_LEVEL" ]; then
            current_state="warning"
            if [ ! -f "$STATE_FILE" ] || [ "$(cat "$STATE_FILE")" != "$current_state" ]; then
                send_notification "warning" "$battery_level" "low" \
                    "Battery level is getting low."
                echo "$current_state" > "$STATE_FILE"
            fi
        else
            # Battery is above warning level, reset state
            rm -f "$STATE_FILE"
        fi
    else
        # Battery is charging or full, reset state
        rm -f "$STATE_FILE"
    fi
    
    # Check every 60 seconds
    sleep 60
done
