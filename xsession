#!/bin/sh
# .xsession

# setup XDG_*
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_CONFIG_DIRS="/etc/xdg:/usr/local/etc/xdg"
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CURRENT_DESKTOP=Xmonad
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_SESSION_COOKIE="$(hostname -s)-$(date +'%s').$$-123456789"

# start dbus
eval $(dbus-launch)

# start ibus xim
ibus-daemon --xim --daemonize --replace

# load common X setup 
xprofile="${HOME}/.xprofile"
[ -x "${xprofile}" ] && . "${xprofile}"

# Set up an icon tray
stalonetray &

# apps
xscreensaver -no-splash &

# a power manager
#xfce4-power-manager &

# WIFI manager
# [ -x /usr/bin/nm-applet ] && nm-applet --sm-disable &

# finally start the WM
exec xmonad
