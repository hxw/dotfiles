#!/bin/sh
# install compare update


list_sed=''
list_copy=''

SED()
{
  list_sed="${list_sed} $*"
}

COPY()
{
  list_copy="${list_copy} $*"
}

# list the files to install
# SED  substitutes @NAME@ type of entries
# COPY just copies the file

SED gitconfig
COPY git-global-ignore
COPY git-global-attributes

COPY bash_aliases
#COPY joverc
COPY mg
COPY tcshrc


# end of list
# ===========

ERROR()
{
  echo error: $* 1>&2
  exit 1
}

# get a string escaping / & for later sed substitution
# usage:  var=$(get prompt message here) || exit 1
# note: need the exit as the ERROR only terminates the $() sub-shell
get()
{
  local default prompt data
  default="$1"; shift

  read -p "$* [${default}]: " -r data
  [ -z "${data}" ] && data="${default}"
  printf '%s' "${data}" | sed 's/\\/\\\\/g;s,/,\\/,g;s,&,\\\&,g'
}


# main
# ====

echo this will install the files to: ${HOME}
echo Ctrl-C to abort

config="${HOME}/.dotfilesrc"

name=
email=
[ -f "${config}" ] && . "${config}"

echo Enter some data for substitutions

name=$(get "${name}" Enter full name) || exit 1
email=$(get "${email}" Enter email address) || exit 1

rm -f "${config}"
echo '# .dotfilesrc' >> "${config}"
echo '' >> "${config}"
echo 'email='"'"${email}"'" >> "${config}"
echo 'name='"'"${name}"'" >> "${config}"

# use sed to substitute som @VAR@ by values saved in ${config}
for f in ${list_sed}
do
  d="${HOME}/.${f}"
  echo Substitute ${f} to ${d}
  sed "s,@HOME@,${HOME}/,g;s/@EMAIL@/${email}/g;s/@NAME@/${name}/g;" "${f}" > "${d}"
done

# file that are just copied
for f in ${list_copy}
do
  d="${HOME}/.${f}"
  echo Copy ${f} to ${d}
  cp -p "${f}" "${d}"
done
