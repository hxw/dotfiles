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
#COPY tcshrc
COPY zshrc
COPY lesskey

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

config="${prefix}/.dotfilesrc"

name=
email=
[ -f "${config}" ] && . "${config}"

if [ X"${interactive}" = X"yes" ]
then
  echo Ctrl-C to abort
  echo Enter some data for substitutions

  name=$(get "${name}" Enter full name) || exit 1
  email=$(get "${email}" Enter email address) || exit 1

  rm -f "${config}"
  echo '# .dotfilesrc' >> "${config}"
  echo '' >> "${config}"
  echo 'email='"'"${email}"'" >> "${config}"
  echo 'name='"'"${name}"'" >> "${config}"
fi

# set to an '#' if do not have the item
# to allow commenting out lines in scripts
have_home=
have_name=
have_email=
[ -z "${prefix}" ] && have_home='#'
[ -z "${name}" ] && have_name='#' && name='Full Name'
[ -z "${email}" ] && have_email='#' && email='root@localhost'

# use sed to substitute som @VAR@ by values saved in ${config}
for f in ${list_sed}
do
  d="${prefix}/.${f}"
  echo Substitute ${f} to ${d}
  sed "s,@HOME@,${prefix}/,g;
       s,@HAVE_HOME@,${have_home},g;
       s/@EMAIL@/${email}/g;
       s/@HAVE_EMAIL@/${have_email}/g;
       s/@NAME@/${name}/g;
       s/@HAVE_NAME@/${have_name}/g;
      " "${src}/${f}" > "${d}"
done

# file that are just copied
for f in ${list_copy}
do
  d="${prefix}/.${f}"
  echo Copy ${f} to ${d}
  cp -p "${src}/${f}" "${d}"
done

# desktop files to .local
dst="${HOME}/.local/share/applications/"
mkdir -p "${dst}"

for f in "${src}"/*.desktop
do
  bn=$(basename "${f}")
  [ -e "/usr/local/share/applications/${bn}" ] && continue
  [ -e "/usr/share/applications/${bn}" ] && continue
  echo Copy ${bn} to ${dst}
  cp -p "${f}" "${dst}"
done

# update less configuration
lesskey
