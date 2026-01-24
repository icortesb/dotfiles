#!/usr/bin/env bash
# Auto-detect monitors and generate Hyprland monitor configuration

MONITOR_CONF="$HOME/.config/hypr/monitors.conf"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"

echo "==> Detecting monitors..."

# Get all connected monitors
MONITORS=$(hyprctl monitors -j | jq -r '.[].name')

if [ -z "$MONITORS" ]; then
    echo "No monitors detected, using fallback configuration"
    echo "monitor=,preferred,auto,auto" > "$MONITOR_CONF"
    exit 0
fi

# Clear existing configuration
> "$MONITOR_CONF"

# Generate monitor configuration
MONITOR_COUNT=0
PRIMARY_MONITOR=""

for MONITOR in $MONITORS; do
    # Get preferred resolution and highest refresh rate
    MONITOR_INFO=$(hyprctl monitors -j | jq -r ".[] | select(.name==\"$MONITOR\")")
    WIDTH=$(echo "$MONITOR_INFO" | jq -r '.width')
    HEIGHT=$(echo "$MONITOR_INFO" | jq -r '.height')
    
    # Get available modes and find the highest refresh rate for current resolution
    MODES=$(hyprctl monitors -j | jq -r ".[] | select(.name==\"$MONITOR\") | .availableModes[]")
    
    # Extract refresh rates for current resolution
    REFRESH_RATES=$(echo "$MODES" | grep "^${WIDTH}x${HEIGHT}@" | sed 's/.*@\([0-9.]*\)Hz/\1/' | sort -rn)
    MAX_REFRESH=$(echo "$REFRESH_RATES" | head -n1)
    
    # If no matching resolution found, use current refresh rate
    if [ -z "$MAX_REFRESH" ]; then
        MAX_REFRESH=$(echo "$MONITOR_INFO" | jq -r '.refreshRate')
    fi
    
    # Round refresh rate to nearest integer
    REFRESH=$(printf "%.0f" "$MAX_REFRESH")
    
    # Position monitors side by side
    XPOS=$((MONITOR_COUNT * WIDTH))
    
    # First monitor is primary
    if [ $MONITOR_COUNT -eq 0 ]; then
        PRIMARY_MONITOR="$MONITOR"
    fi
    
    echo "monitor = $MONITOR,${WIDTH}x${HEIGHT}@${REFRESH},${XPOS}x0,1.0" >> "$MONITOR_CONF"
    echo "Configured: $MONITOR at ${WIDTH}x${HEIGHT}@${REFRESH}Hz (position: ${XPOS}x0)"
    
    MONITOR_COUNT=$((MONITOR_COUNT + 1))
done

echo "==> Generated $MONITOR_CONF with $MONITOR_COUNT monitor(s)"

# Update hyprpaper configuration with primary monitor
if [ -n "$PRIMARY_MONITOR" ]; then
    cat > "$HYPRPAPER_CONF" << EOF
wallpaper {
    monitor = $PRIMARY_MONITOR
    path = \$HOME/walls/wall1.png
    fit_mode = cover
}

splash = false
EOF
    echo "==> Updated hyprpaper.conf to use $PRIMARY_MONITOR"
fi
