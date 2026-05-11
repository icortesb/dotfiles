#!/bin/bash
# Prank lock - shows security warning on wrong password

PRANK_CONFIG="$HOME/.config/hypr/hyprlock-prank.conf"

# Run hyprlock
hyprlock -c "$PRANK_CONFIG"

# When hyprlock exits (wrong password), show big security warning
notify-send -u critical -t 8000 "
⚠ SECURITY ALERT ⚠

INCORRECT PASSWORD

⚠ Multiple failed attempts detected
Security protocol initiated - IP logged
⚠ Further attempts may trigger system lockout
" -h string:fontconfig:font=DejaVu-Sans-Bold-36 -h int:transient:1

# Restart lock
exec ~/.config/hypr/prank-lock.sh