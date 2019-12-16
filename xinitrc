#!/bin/sh
# startup script for DM

[ X"${1}" = X".xsession" ] && exec "${HOME}/.xsession"


xprofile="${HOME}/.xprofile"

[ -x "${xprofile}" ] && . "${xprofile}"

[ X"${1}" = X"default" ] && exec start-lumina-desktop

exec "$@"
