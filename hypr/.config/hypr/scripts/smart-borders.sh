#!/bin/bash

# Smart borders - hide borders when only one window is open per workspace

function handle {
    case $1 in
        workspace*|openwindow*|closewindow*|movewindow*)
            # Get the active workspace
            active_workspace=$(hyprctl activeworkspace -j | jq -r '.id')
            
            # Count non-floating windows in active workspace
            window_count=$(hyprctl clients -j | jq "[.[] | select(.workspace.id == $active_workspace and .floating == false)] | length")
            
            # Set border size based on window count
            if [ "$window_count" -le 1 ]; then
                hyprctl keyword general:border_size 0 >/dev/null 2>&1
            else
                hyprctl keyword general:border_size 1 >/dev/null 2>&1
            fi
            ;;
    esac
}

# Listen to Hyprland socket for events
socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    handle "$line"
done
