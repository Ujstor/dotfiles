#!/bin/sh

# /etc/X11/xinit/xinitrc
#
# global xinitrc file, used by all X sessions started by xinit (startx)
#
# Start the polkit agent
/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &

# Configure monitors: DP-2 (left), HDMI-0 (middle), DP-0 (right)
# Log file for debugging
LOGFILE=/tmp/xinitrc-xrandr.log
echo "=== xinitrc xrandr debug $(date) ===" > $LOGFILE

# Wait for all displays to be detected
DISPLAYS="DP-2 HDMI-0 DP-0"
MAX_WAIT=10
WAITED=0

echo "Waiting for displays..." >> $LOGFILE
while [ $WAITED -lt $MAX_WAIT ]; do
    ALL_CONNECTED=true
    for DISPLAY_NAME in $DISPLAYS; do
        if ! xrandr | grep -q "^$DISPLAY_NAME connected"; then
            ALL_CONNECTED=false
            echo "Display $DISPLAY_NAME not yet connected (waited ${WAITED}s)" >> $LOGFILE
            break
        fi
    done

    if [ "$ALL_CONNECTED" = "true" ]; then
        echo "All displays connected after ${WAITED}s" >> $LOGFILE
        break
    fi

    sleep 1
    WAITED=$((WAITED + 1))
done

echo "Running xrandr command..." >> $LOGFILE
xrandr --output DP-2 --auto --mode 2560x1440 --pos 0x0 \
       --output HDMI-0 --auto --mode 2560x1440 --pos 2560x0 \
       --output DP-0 --auto --mode 2560x1440 --pos 5120x0 --primary >> $LOGFILE 2>&1
echo "xrandr exit code: $?" >> $LOGFILE

# Disable screen saver and power management
xset s off
xset -dpms
xset s noblank

# Start window manager
exec dwm
