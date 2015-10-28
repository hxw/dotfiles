#!/bin/sh
# find all .git directories and update the hooks


src="$(dirname "$0")/git-hooks"

find "${HOME}" -type d -name '.git' -print -exec cp -p "${src}"/* '{}/hooks/' ';'
