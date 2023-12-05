#!/bin/sh
# install compare update


list_sed=''
list_copy=''
list_x11=''
list_x11_sed=''

SED() {
  list_sed="${list_sed} $*"
}

COPY() {
  list_copy="${list_copy} $*"
}

X11() {
  list_x11="${list_x11} $*"
}

X11_SED() {
  list_x11_sed="${list_x11} $*"
}

CAT() {
  local f
  rm -f "${2}"
  printf '! .%s\n\n' "${2}" >> "${2}"
  for f in "${src}/${1}"/*.res
  do
    cat "${f}" >> "${2}"
    printf '\n\n\n' >> "${2}"
  done
}

# list the files to install
# SED  substitutes @NAME@ type of entries
# COPY just copies the file

SED git/config
COPY git/global-ignore
COPY git/global-attributes

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
X11 xmonad/config.hs
X11 xmonad/build
X11_SED dunst/dunstrc
X11 xprofile
X11 Xresources
X11 xsession

# end of list
# ===========


ERROR() {
  printf 'error: '
  printf "${@}"
  printf '\n'
  exit 1
}

VERBOSE() {
  [ X"${verbose}" = X"yes" ] && printf "$@"
}

USAGE() {
  if [ -n "${1}" ]
  then
    printf 'error: '
    printf "${@}"
    printf '\n'
  fi
  cat <<EOF
usage: ${0##*/} <options>
       --help             -h         this message
       --verbose          -v         more messages
       --prefix=<dir>     -p <dir>   set installation directory [${prefix}]
       --non-interactive  -n         no interactive input
       --bin              -b         also include bin/* to ${HOME}/bin
       --copy             -c         copy files, default is to diff -u
       --suppress         -s         suppress dotfiles
       --x11              -x         also install X11 configs
       --debug            -D         show debug information
EOF
  exit 1
}


# main program
verbose=no
debug=no
prefix="${HOME}"
interactive=yes
dotfiles=yes
bin=no
copy='diff -su'
x11=no
src=$(dirname "$0")

# parse options
while getopts :hvnbcp:sxD-: option
do
  # convert long options
  if [ X"${option}" = X"-" ]
  then
    option="${OPTARG%%=*}"
    OPTARG="${OPTARG#${option}}"
    OPTARG="${OPTARG#=}"
  fi
  case "${option}" in
    (v|verbose)
      verbose=yes
      ;;

    (n|non-interactive)
      interactive=no
      ;;

    (b|bin)
      bin=yes
      ;;

    (c|copy)
      copy='cp -p'
      ;;

    (p|prefix)
      prefix="${OPTARG}"
      ;;

    (s|suppress)
      dotfiles=no
      ;;

    (x|x11)
      x11=yes
      ;;

    (--)
      break
      ;;

    (D|debug)
      debug=yes
      ;;

    (h|help)
      USAGE
      ;;

    ('?')
      USAGE 'invalid option: -%s' "${OPTARG}"
      ;;

    (*)
      USAGE 'invalid option: --%s' "${option}"
      ;;
  esac
done

shift $((OPTIND - 1))

# verify arguments
[ ${#} -ne 0 ] && USAGE 'extraneous arguments: %s' "${*}"

# enable debugging
[ X"${debug}" = X"yes" ] && set -x

printf 'this will install the files to: %s\n' "${prefix}"

# set to an '#' if do not have the item
# to allow commenting out lines in scripts
have_home=
[ -z "${prefix}" ] && have_home='#'

tempfile=
cleanup() {
  [ -z "${tempfile}" ] || rm -f "${tempfile}"
  rm -f Xresources Xdefaults
}
trap cleanup INT EXIT

# create temporary files
CAT Xresources.d Xresources
CAT Xdefaults.d  Xdefaults

interact() {
  local junk
  [ X"${interactive}" != X"yes" ] && return
  if ! read -p 'Enter to "'"${copy}"'" or Ctrl-C to abort: ' junk
  then
    echo
    exit 1
  fi
}

# use sed to substitute some @VAR@ by local values
for f in ${list_sed}
do
  tf="$(printf '%s' -- "${f}" | tr '/' '__')"
  if ! tempfile="$(mktemp -q "/tmp/${tf}.XXXXXXXX")"
  then
    ERROR 'cannot create temp file for "%s"' "${f}"
  fi

  cfg='.config/'
  [ X"${f}" = X"${f%/*}" ] && cfg='.'
  d="${prefix}/${cfg}${f}"

  printf '\033[1;31mSubstitute "%s" to "%s"\033[0m\n' "${f}" "${d}"

  sed "s,@HOME@,${prefix}/,g;
       s,@HAVE_HOME@,${have_home},g;
      " "${src}/${f}" > "${tempfile}"
  interact
  ${copy} "${tempfile}" "${d}"
  rm -f "${tempfile}"
  tempfile=
done

if [ X"${dotfiles}" = X"yes" ]
then

  # files that are just copied
  for f in ${list_copy}
  do
    cfg='.config/'
    [ X"${f}" = X"${f%/*}" ] && cfg='.'
    d="${prefix}/${cfg}${f}"

    printf '\033[1;34mCopy "%s" to "%s"\033[0m\n' "${f}" "${d}"
    interact
    ${copy} "${src}/${f}" "${d}"
  done

  # desktop files to .local
  dst="${HOME}/.local/share/applications/"
  mkdir -p "${dst}"

  for f in "${src}"/*.desktop
  do
    bn="${f##*/}"
    [ -e "/usr/local/share/applications/${bn}" ] && continue
    [ -e "/usr/share/applications/${bn}" ] && continue
    printf '\033[1;35mCopy "%s" to "%s"\033[0m\n' "${bn}" "${dst}"
    interact
    ${copy} "${f}" "${dst}"
done
fi

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

  for f in ${list_x11_sed}
  do
    tf="$(printf '%s' -- "${f}" | tr '/' '__')"
    if ! tempfile="$(mktemp -q "/tmp/${tf}.XXXXXXXX")"
    then
      ERROR 'cannot create temp file for "%s"' "${f}"
    fi

    cfg='.config/'
    [ X"${f}" = X"${f%/*}" ] && cfg='.'
    d="${prefix}/${cfg}${f}"

    printf '\033[1;31mSubstitute "%s" to "%s"\033[0m\n' "${f}" "${d}"

    sed "s,@HOME@,${prefix}/,g;
         s,@HAVE_HOME@,${have_home},g;
      "  "${src}/${f}" > "${tempfile}"
    interact
    ${copy} "${tempfile}" "${d}"
    rm -f "${tempfile}"
    tempfile=
  done
fi

# handle bin files
if [ X"${bin}" = X"yes" ]
then
  for f in "${src}/bin"/[a-zA-Z0-9]*
  do
    d="${prefix}/bin/${f##*/}"
    [ -f "${d}" ] || continue
    printf '\033[1;34mCopy "%s" to "%s"\033[0m\n' "${f}" "${d}"
    interact
    ${copy} "${src}/${f}" "${d}"
  done
fi
