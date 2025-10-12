#!/usr/bin/env bash

# Script to highlight the focused monitor's Polybar with a colored border
# Monitors focus changes and updates bar colors via IPC hooks

CACHE_DIR="/tmp/polybar-focus"
mkdir -p "$CACHE_DIR"

LAST_FOCUSED_MONITOR=""

# Function to get the monitor that contains the mouse cursor
get_focused_monitor() {
    # Get mouse cursor position
    local mouse_pos=$(xdotool getmouselocation --shell 2>/dev/null)

    if [ -z "$mouse_pos" ]; then
        return
    fi

    local mouse_x=$(echo "$mouse_pos" | grep "^X=" | cut -d'=' -f2)
    local mouse_y=$(echo "$mouse_pos" | grep "^Y=" | cut -d'=' -f2)

    if [ -z "$mouse_x" ] || [ -z "$mouse_y" ]; then
        return
    fi

    # Find which monitor contains the mouse cursor
    xrandr --query | grep " connected" | while read line; do
        local monitor=$(echo $line | cut -d" " -f1)
        local geometry=$(echo $line | grep -oP '\d+x\d+\+\d+\+\d+')
        if [ -n "$geometry" ]; then
            local mon_x=$(echo $geometry | cut -d'+' -f2)
            local mon_y=$(echo $geometry | cut -d'+' -f3)
            local mon_w=$(echo $geometry | cut -d'x' -f1)
            local mon_h=$(echo $geometry | cut -d'x' -f2 | cut -d'+' -f1)

            if [ $mouse_x -ge $mon_x ] && [ $mouse_x -lt $((mon_x + mon_w)) ] && \
               [ $mouse_y -ge $mon_y ] && [ $mouse_y -lt $((mon_y + mon_h)) ]; then
                echo $monitor
                return
            fi
        fi
    done
}

# Function to update the focused monitor display files
update_focus_cache() {
    local focused_monitor="$1"

    # Get list of all monitors
    mapfile -t ALL_MONITORS < <(xrandr --query | grep " connected" | cut -d" " -f1)

    for monitor in "${ALL_MONITORS[@]}"; do
        if [ "$monitor" = "$focused_monitor" ]; then
            # Write formatted output for focused monitor
            echo "%{F#2E3440}%{B#88C0D0}  ${monitor}  %{B-}%{F-}" > "$CACHE_DIR/${monitor}-display"
        else
            # Clear display for non-focused monitors
            echo "" > "$CACHE_DIR/${monitor}-display"
        fi
    done
}

echo "Focus monitor indicator started. Watching for focus changes..."

# Initialize display files
mapfile -t ALL_MONITORS < <(xrandr --query | grep " connected" | cut -d" " -f1)
for monitor in "${ALL_MONITORS[@]}"; do
    echo "" > "$CACHE_DIR/${monitor}-display"
done

# Wait for polybar to fully start
sleep 1

# Get initial focused monitor and trigger update
INITIAL_MONITOR=$(get_focused_monitor)
if [ -n "$INITIAL_MONITOR" ]; then
    echo "Initial focused monitor: $INITIAL_MONITOR"
    update_focus_cache "$INITIAL_MONITOR"
    LAST_FOCUSED_MONITOR="$INITIAL_MONITOR"
fi

# Monitor mouse position changes (poll every 500ms)
while true; do
    sleep 0.5

    CURRENT_MONITOR=$(get_focused_monitor)

    if [ -n "$CURRENT_MONITOR" ] && [ "$CURRENT_MONITOR" != "$LAST_FOCUSED_MONITOR" ]; then
        echo "Focus changed to monitor: $CURRENT_MONITOR"
        update_focus_cache "$CURRENT_MONITOR"
        LAST_FOCUSED_MONITOR="$CURRENT_MONITOR"
    fi
done
