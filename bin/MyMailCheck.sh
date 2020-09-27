#!/bin/sh
# called after mail check

n="${1}"

printenv >/tmp/eee
date '+%F %T' >> /tmp/eee
echo n=${n} >> /tmp/eee

[ -z "${n}" ] && exit 0
[ X"0" = X"${n}" ] && exit 0


ogg123 -q "${HOME}/Sounds/morse-mail.ogg"
