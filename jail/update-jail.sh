#!/bin/sh
# update or upgrade a jail's userland

ERROR() {
  printf 'error: '
  printf "${@}"
  printf '\n'
  exit 1
}

VERBOSE() {
  [ X"${verbose}" = X"no" ] && return 0
  printf "${@}"
  printf '\n'
}

USAGE() {
  if [ -n "${1}" ]
  then
    printf 'error: '
    printf "${@}"
    printf '\n'
  fi
  echo usage: "${0##*/}" '<options>' jails...
  echo '       --help                 -h            this message'
  echo '       --verbose              -v            more messages'
  echo '       --yes                  -y            answer yes to all prompts'
  echo '       --prefix=DIR           -p DIR        jail chroot directory prefix ['"${prefix}"']'
  echo '       --conf=FILE            -c FILE       freebsd-update configuration file ['"${conf}"']'
  echo '       --upgrade=VERSION      -u VERSION    freebsd-update upgrade to new version'
  echo '       --debug                -D            show debug information'
  exit 1
}

GetYN() {
  local yorn junk
  while :
  do
    read -p "${*} [y/n] ? " yorn junk
    case "${yorn}" in
      [yY]|[yY][eE][sS])
        return 0
        ;;
      [nN]|[nN][oO])
        return 1
        ;;
      *)
        echo Please answer yes or no
        ;;
    esac
  done
}


# main program
verbose=no
debug=no
prompt=yes
prefix=/jails
conf='/etc/jail-update.conf'
upgrade_to=''

# parse options
while getopts :hvyp:c:u:D-: option
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

    (y|yes)
      prompt=no
      ;;

    (p|prefix)
      prefix="${OPTARG}"
      ;;

    (c|conf)
      conf="${OPTARG}"
      ;;

    (u|upgrade)
      upgrade_to="${OPTARG}"
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
#[ ${#} -ne 0 ] && USAGE 'extraneous arguments: %s' "${*}"
[ "${#}" -eq 0 ] && USAGE 'missing jail name arguments: %s' "$*"

# enable debugging
[ X"${debug}" = X"yes" ] && set -x

# process all jails
for name in "${@}"
do
  j="${prefix}/${name}"

  VERBOSE 'jail chroot: %s' "${j}"

  [ -d "${j}" ] || ERROR 'missing jail chroot: %s' "${j}"

  #version="$(jexec -l "${name}" freebsd-version)"
  version="$(chroot "${j}" freebsd-version)"

  printf 'current version: %s\n' "${version}"

  # upgrade to new OS version
  if [ -n "${upgrade_to}" ]
  then
    if [ X"${version%-p*}" = X"${upgrade_to%-p*}" ]
    then
      printf 'already upgraded\n'
      continue
    fi
    if [ X"${prompt}" = X"no" ] || GetYN "upgrade the jail at: ${j} to: ${upgrade_to}"
    then
      printf 'upgrading jail: %s\n' "${j}"
      opts=''
      [ X"${prompt}" = X"no" ] && opts='--not-running-from-cron'
      freebsd-update -f "${conf}" -b "${j}" --currently-running "${version}" ${opts} -r "${upgrade_to}" upgrade
      for i in 1 2 3
      do
        printf 'installing upgrades: %d of 3 for: %s\n' "${i}" "${j}"
        freebsd-update -f "${conf}" -b "${j}" --currently-running "${version}" ${opts} install
      done
    fi

  # just update to highest available patch level
  elif [ X"${prompt}" = X"no" ] || GetYN "update the jail at: ${j}"
  then
    printf 'updating jail: %s\n' "${j}"
    opts=''
    [ X"${prompt}" = X"no" ] && opts='--not-running-from-cron'
    freebsd-update -f "${conf}" -b "${j}" --currently-running "${version}" ${opts} fetch install
  fi

done
