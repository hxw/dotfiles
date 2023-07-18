#!/bin/sh
# find all .git directories and update the hooks

src="${0%/*}")/git/hooks"

dir="${1}"
[ -z "${dir}" ] && dir="${HOME}"

find "${dir}" -type d -name '.git' -print -exec cp -p "${src}"/* '{}/hooks/' ';'
