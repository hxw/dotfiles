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
  echo error: $*
  exit 1
}

USAGE()
{
  [ -z "$1" ] || echo error: $*
  echo usage: $(basename "$0") '<options>'
  echo '       --help             -h         this message'
  echo '       --verbose          -v         more messages'
  echo '       --prefix=<dir>     -p <dir>   set installation directory ['"${home}"']'
  echo '       --non-interactive  -n         no interactive input'
  echo '       --debug            -d         show debug information'
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


# main program

verbose=no
prefix="${HOME}"
interactive=yes
wait=yes
src=$(dirname "$0")

getopt=/usr/local/bin/getopt
[ -x "${getopt}" ] || getopt=getopt
args=$(${getopt} -o hvp:nd --long=help,verbose,prefix:,non-interactive,debug -- "$@") ||exit 1

# replace the arguments with the parsed values
eval set -- "${args}"

while :
do
  case "$1" in
    -v|--verbose)
      verbose=yes
      shift
      ;;

    -n|--non-interactive)
      interactive=no
      shift
      ;;

    -p|--prefix)
      prefix=$2
      shift 2
      ;;

    -d|--debug)
      debug=yes
      shift
      ;;

    --)
      shift
      break
      ;;

    *)
      USAGE invalid argument $1
      ;;
  esac
done

[ $# -eq 0 ] || USAGE extraneous arguments

[ X"${debug}" = X"yes" ] && set -x

echo this will install the files to: ${prefix}
echo Ctrl-C to abort

config="${prefix}/.dotfilesrc"

name=
email=
[ -f "${config}" ] && . "${config}"

echo Enter some data for substitutions

if [ X"${interactive}" = X"yes" ]
then
  name=$(get "${name}" Enter full name) || exit 1
  email=$(get "${email}" Enter email address) || exit 1

  rm -f "${config}"
  echo '# .dotfilesrc' >> "${config}"
  echo '' >> "${config}"
  echo 'email='"'"${email}"'" >> "${config}"
  echo 'name='"'"${name}"'" >> "${config}"
fi

# use sed to substitute som @VAR@ by values saved in ${config}
for f in ${list_sed}
do
  d="${prefix}/.${f}"
  echo Substitute ${f} to ${d}
  sed "s,@HOME@,${prefix}/,g;s/@EMAIL@/${email}/g;s/@NAME@/${name}/g;" "${src}/${f}" > "${d}"
done

# file that are just copied
for f in ${list_copy}
do
  d="${prefix}/.${f}"
  echo Copy ${f} to ${d}
  cp -p "${src}/${f}" "${d}"
done
