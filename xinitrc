#!/bin/sh
# startup script for DM

xprofile="${HOME}/.xprofile"

[ -x "${xprofile}" ] && . "${xprofile}"

[ X"${1}" = X"default" ] && exec start-lumina-desktop

exec "$@"
