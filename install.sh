#!/bin/sh
# install compare update


list_sed=''
list_copy=''
list_x11=''

SED() {
  list_sed="${list_sed} $*"
}

COPY() {
  list_copy="${list_copy} $*"
}

X11() {
  list_x11="${list_x11} $*"
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
#COPY tcshrc
COPY zshrc
COPY lesskey

# X11 files to be copied to ${HOME}
X11 xbindkeysrc
X11 XCompose
X11 Xdefaults
X11 xinitrc
X11 xmobarrc
X11 xmonad/xmonad.hs
X11 xprofile
X11 Xresources
X11 xsession

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
  echo '       --copy             -c         copy files, default is to diff -u'
  echo '       --x11              -x         also install X11 configs'
  echo '       --debug            -D         show debug information'
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
copy='diff -su'
x11=no
wait=yes
src=$(dirname "$0")

getopt=
case "$(uname)" in
  (FreeBSD|DragonFly)
    getopt=/usr/local/bin/getopt
    ;;
  (NetBSD)
    getopt=/usr/pkg/bin/getopt
    ;;
  (OpenBSD)
    getopt=/usr/local/bin/gnugetopt
    ;;
  (Darwin)
    getopt=/usr/local/opt/gnu-getopt/bin/getopt
    ;;
  (Linux)
    getopt=/usr/bin/getopt
    ;;
  (*)
    ERROR 'OS: %s is not supported' "$(uname)"
    ;;
esac
[ -x "${getopt}" ] || ERROR 'getopt: "%s" is not executable or not installed' "${getopt}"

args=$(${getopt} -o hvp:ncxD --long=help,verbose,prefix:,non-interactive,copy,x11,debug -- "$@") ||exit 1

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

    -c|--copy)
      copy='cp -p'
      shift
      ;;

    -p|--prefix)
      prefix=$2
      shift 2
      ;;

    -x|--x11)
      x11=yes
      shift
      ;;

    -D|--debug)
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

# set to an '#' if do not have the item
# to allow commenting out lines in scripts
have_home=
[ -z "${prefix}" ] && have_home='#'

tempfile=
cleanup() {
  [ -z "${tempfile}" ] || rm -f "${tempfile}"
}
trap cleanup INT EXIT

interact() {
  local junk
  [ X"${interactive}" != X"yes" ] && return
  read -p 'Enter to "'"${copy}"'" or Ctrl-C to abort: ' junk
  if [ $? -ne 0 ]
  then
    echo
    exit 1
  fi
}

# use sed to substitute some @VAR@ by local values
for f in ${list_sed}
do
  tempfile=$(mktemp -q /tmp/${f}.XXXXXXXX)
  if [ $? -ne 0 ]
  then
    ERROR 'cannot create temp file for "%s"' "${f}"
  fi

  d="${prefix}/.${f}"

  printf '\033[1;31mSubstitute "%s" to "%s"\033[0m\n' "${f}" "${d}"

  sed "s,@HOME@,${prefix}/,g;
       s,@HAVE_HOME@,${have_home},g;
      " "${src}/${f}" > "${tempfile}"
  interact
  ${copy} "${tempfile}" "${d}"
  rm -f "${tempfile}"
  tempfile=
done

# file that are just copied
for f in ${list_copy}
do
  d="${prefix}/.${f}"
  printf '\033[1;34mCopy "%s" to "%s"\033[0m\n' "${f}" "${d}"
  interact
  ${copy} "${src}/${f}" "${d}"
done

# desktop files to .local
dst="${HOME}/.local/share/applications/"
mkdir -p "${dst}"

for f in "${src}"/*.desktop
do
  bn=$(basename "${f}")
  [ -e "/usr/local/share/applications/${bn}" ] && continue
  [ -e "/usr/share/applications/${bn}" ] && continue
  printf '\033[1;35mCopy "%s" to "%s"\033[0m\n' "${bn}" "${dst}"
  interact
  ${copy} "${f}" "${dst}"
done

# update less configuration
lesskey

# handle X11 files
if [ X"${x11}" = X"yes" ]
then
  for f in ${list_x11}
  do
    d="${prefix}/.${f}"
    printf '\033[1;32mCopy "%s" to "%s"\033[0m\n' "${f}" "${d}"
    interact
    ${copy} "${src}/${f}" "${d}"
  done
fi
