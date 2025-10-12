#!/usr/bin/env bash

THEME="minimal"

# Kill all existing polybar instances
killall polybar 2>/dev/null
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

CONFIG_FILE="$HOME/dwm/polybar/themes/$THEME/config.ini"
LAPTOP_CONFIG_FILE="$HOME/dwm/polybar/themes/$THEME/laptop-config.ini"

if ls /sys/class/power_supply/ 2>/dev/null | grep -q '^BAT'; then
	CONFIG_FILE=$LAPTOP_CONFIG_FILE
fi

# Check if xrandr is available and get monitor list
if command -v xrandr > /dev/null 2>&1; then
    # Get list of connected monitors
    mapfile -t MONITORS < <(xrandr --query | grep " connected" | cut -d" " -f1)
    MONITOR_COUNT=${#MONITORS[@]}

    echo "Detected $MONITOR_COUNT monitors: ${MONITORS[*]}"

    if [ $MONITOR_COUNT -eq 1 ]; then
        # Single monitor setup - launch main bar with tray
        echo "Single monitor setup - launching main polybar with tray on ${MONITORS[0]}"
        MONITOR=${MONITORS[0]} polybar main -c "$CONFIG_FILE" &
    else
        # Multi-monitor setup - tray on middle monitor (HDMI-0)
        echo "Multi-monitor setup - tray on middle monitor (HDMI-0)"

        TRAY_MONITOR="HDMI-0"

        # Launch polybar on all connected monitors
        for monitor in "${MONITORS[@]}"; do
            if [ "$monitor" = "$TRAY_MONITOR" ]; then
                # Middle monitor gets the tray
                MONITOR=$monitor polybar main -c "$CONFIG_FILE" &
                echo "Launched polybar WITH tray on $monitor (middle monitor)"
            else
                # Other monitors don't get the tray
                MONITOR=$monitor polybar secondary -c "$CONFIG_FILE" &
                echo "Launched polybar WITHOUT tray on $monitor"
            fi
        done
    fi
else
    # Fallback: launch main bar if xrandr is not available
    echo "xrandr not available - launching fallback main polybar with tray"
    polybar main -c "$CONFIG_FILE" &
fi
