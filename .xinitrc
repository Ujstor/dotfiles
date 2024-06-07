#!/bin/sh

# /etc/X11/xinit/xinitrc
#
# global xinitrc file, used by all X sessions started by xinit (startx)
#
# Start the polkit agent
/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &

# invoke global X session script
exec dwm
