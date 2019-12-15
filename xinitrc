#!/bin/sh
# startup script for DM

xprofile="${HOME}/.xprofile"

[ -x "${xprofile}" ] && . "${xprofile}"

if [ X"${1}" = X"default" ]
then
  exec start-lumina-desktop
fi

exec "$@"
