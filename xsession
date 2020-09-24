#!/bin/sh
# .xsession - startup script for XDM

# setup XDG_*
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_CONFIG_DIRS="/etc/xdg:/usr/local/etc/xdg"
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CURRENT_DESKTOP=Xmonad
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_DATA_HOME="${HOME}/.local/share"

# set cookie if using non-XDG aware display manager
[ -z "${XDG_SESSION_COOKIE}" ] && export XDG_SESSION_COOKIE="$(hostname -s)-$(date +'%s').$$-123456789"

# start dbus
#eval $(dbus-launch)
[ X"${1}" = X"with-dbus" ] || exec dbus-launch --exit-with-session "$0" with-dbus

# start ibus xim
ibus-daemon --xim --daemonize --replace

# load common X setup
xprofile="${HOME}/.xprofile"
[ -x "${xprofile}" ] && . "${xprofile}"

# Set up an icon tray
stalonetray &

# apps
xmixer -q
xscreensaver -no-splash &
oneko -tomoyo -bg pink -fg purple &
volumeicon &
xbindkeys &

# a power manager
#xfce4-power-manager &

# WIFI manager
# [ -x /usr/bin/nm-applet ] && nm-applet --sm-disable &

# finally start the WM
exec xmonad
