# .zshrc      -*- mode: shell-script -*-

# notes:
# if the file ~/bin/@ADD-TO-PATH exists, any lines that are directories
# will be added to the PATH

# determine if root user
is_root=no
[[ X"0" = X"$(id -u)" ]] && is_root=yes

# Tab completion
autoload -U compinit
compinit

# Tab completion from both ends
setopt completeinword

# Tab completion case-insensitive
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Better completion for killall
zstyle ':completion:*:killall:*' command 'ps -u $USER -o cmd'

# Changes the definition of "word", e.g. with ^W
autoload select-word-style

# Remove Emacs Backups
alias reb='find . -name "*~" -print -delete'

# Editor aliases
if [[ -x "$(whence eie)" ]]
then
  alias edit="eie --no-frame"
  alias ed="eie --no-wait"
  export EDITOR="eie"
else
  # search for an editor
  for e in mg emacs jove vim vi
  do
    if [[ -x "$(whence "${e}")" ]]
    then
      alias edit="${e}"
      alias ed="${e}"
      export EDITOR="${e}"
      break
    fi
  done
fi

# For less
pager=$(which less)
if [[ -x "${pager}" ]]
then
  export PAGER=${pager}
  export LESS="-iR"
fi
unset pager

# to show C definitions
# cdefs [gcc|clang90|…]
cdefs() {
  local c
  c="${1}"; shift
  [ -z "${c}" ] && c=cc
  ${c} -dM -E - < /dev/null
}

# make a directory and change to it
function mkcd {
  local dir
  dir="${1}"; shift

  if [[ -z "${dir}" ]]
  then
    pwd
  elif [[ -d "${dir}" ]]
  then
    cd "${dir}" || return 1
  elif [[ -f "${dir}" ]]
  then
   echo A file of that name already exists
   return 1
  else
    mkdir -p "${dir}"
    cd "${dir}" || return 1
  fi
  return 0
}

# remove items from PATH
function pathrm {
  local item p pa

  pa=(${(s/:/)PATH})
  for item in "${@}"
  do
    pa=("${pa[@]:#${item}}")
  done

  p=
  for item in "${pa[@]}"
  do
    [[ -n "${item}" ]] && p="${p}:${item}"
  done
  PATH="${p:1}"
}

# convert a directory to an absolute path
function absolute_path {
  if [[ -d "${1}" ]]
  then
    (cd "${1}" ; pwd)
  else
    echo ""
  fi
}

# add items to front of PATH
# move existing items to front of PATH
function pathfront {
  local item p
  pathrm "${@}"

  p=
  for item in "${@}"
  do
    item=$(absolute_path "${item}")
    pathrm "${item}"
    [[ -n "${item}" ]] && p="${p}:${item}"
  done
  PATH="${p:1}:${PATH}"
}

# show path
alias path='echo ${PATH}'

# append the @ADD-TO-PATH entries to the path
# only if they resolve to directories
if [[ -f "${HOME}/bin/@ADD-TO-PATH" ]]
then
  while read line
  do
    [[ -z "${line}" ]] && continue
    [[ X"${line#\#}" != X"${line}" ]] && continue
    [[ X"${line#/}" = X"${line}" ]] && line=$(absolute_path "${HOME}/bin/${line}")
    [[ -d "${line}" ]] && pathfront "${line}"
  done < "${HOME}/bin/@ADD-TO-PATH"
  unset line
fi

# put user's main bin directory first
[[ -d "${HOME}/bin" ]] && pathfront "${HOME}/bin"

# autopushd so cd -<tab> is useful
setopt autopushd

# Enables all sorts of extended globbing:
#   ls */.txt       find all text files
#   ls -d *(D)      show all files including those starting with "."
# Note:  man zshexpn   -> section "FILENAME GENERATION".
setopt extendedglob
unsetopt caseglob

# save comments in history / ignore space prefixed commands
setopt interactivecomments
setopt histignorespace

# remove history lines by number
# -1 to remove the most recent command
# bigs: cannot remove multi-line commands
rmh() {
  local line_number HISTORY_IGNORE replace

  line_number="${1}"

  # backslashes quote the resulting command '(b)'
  HISTORY_IGNORE="${(b)$(fc -l -n "${line_number}" "${line_number}")}"

  # fiilter shell history file and rewrite
  fc -W

  # replace history command and run in current shell
  replace="fc -p '${HISTFILE}' '${HISTSIZE}' '${SAVEHIST}'"
  eval ${replace}

  printf 'run this command in shells associated with this one: %s\n' "${replace}"
}

# prevent certain commands from being written to history
zshaddhistory() {
  case "${1}" in
    (rmh *)
      return 1
      ;;
    (*)
      return 0
      ;;
  esac
}



# Type ".." instead of "cd ..", "/usr/include" instead of "cd /usr/include"
setopt auto_cd

# Change the prompt
#PS1='[%T] %n@%m %2~ %# '

# colours: black red green yellow blue magenta cyan white
PS1='%F{magenta}%B[%T]%b%f %F{green}%B%n@%m%b%f %F{cyan}%B%2~ %#%b%f '


# Display CPU usage stats for commands taking more than 10 seconds
REPORTTIME=10

# set if system supports jails or in VM
in_jail=no

# OS specific items
os="$(uname -s)"
case "${os}" in
  (Linux)
    [ X"$(grep -c hypervisor /proc/cpuinfo)" != X"0" ] && in_jail=yes
    eval $(dircolors)
    alias ls='ls -F --color=auto'
    alias ll='ls -l'
    alias la='ls -a'
    alias lc='ls -C'
    case "${is_root}" in
      (yes)
        alias diff='diff -u'
        ;;
      (no)
        alias diff='diff -urN'
        ;;
    esac

    alias acs='apt-cache search'
    alias aw='apt-cache show'

    alias alp='netstat -plunt'
    alias alps='netstat -plut --numeric-host'

    function dq {
      dpkg-query -W --showformat='${Installed-Size} ${Package} ${Status}\n' | grep -v deinstall | sort -n | awk '{print $1" "$2}'
    }
    export TIME_STYLE='posix-long-iso'
    ;;

  (FreeBSD|DragonFly)
    sysctl_jailed=security.jail.jailed
    [ X"${os}" = X"DragonFly" ] && sysctl_jailed=jail.jailed
    [ -n "${sysctl_jailed}" ] && [ X"$(sysctl -n "${sysctl_jailed}")" = X"1" ] && in_jail=yes
    if [[ "${TERM}" =~ "^rxvt" ]]
    then
      TERM=rxvt-unicode-256color
    fi
    alias toor='exec su -l toor'
    alias ls='ls -GF -D %Y-%m-%d\ %H:%M'
    alias ll='ls -l -D %Y-%m-%d\ %H:%M'
    alias la='ls -la -D %Y-%m-%d\ %H:%M'
    alias lc='ls -C -D %Y-%m-%d\ %H:%M'

    alias alp="netstat -an |grep --colour=never '\(^Proto.*\|LISTEN\|^udp\)'"
    alias alps="netstat -aS |grep --colour=never '\(^Proto.*\|LISTEN\|^udp\)'"

    alias iotop='top -m io -o total'

    case "${is_root}" in
      (yes)
        export DIFF_OPTIONS=-u
        ;;
      (no)
        export DIFF_OPTIONS=-urN
        ;;
    esac

    [ X"${os}" = X"FreeBSD" ] && export GREP_OPTIONS=--colour=auto
    export IFCONFIG_FORMAT=inet:cidr,inet6:cidr
    ;;

  (NetBSD|OpenBSD)
    if [[ "${TERM}" =~ "^rxvt" ]]
    then
      TERM=rxvt-256color
    fi
    alias toor='exec su -l toor'
    alias ls='ls -F'
    alias ll='ls -l'
    alias la='ls -la'
    alias lc='ls -CF'
    alias grep='grep --colour=auto'

    alias alp="netstat -an |grep --colour=never '\(^Proto.*\|LISTEN\|^udp\)'"
    alias alps="netstat -aS |grep --colour=never '\(^Proto.*\|LISTEN\|^udp\)'"

    case "${is_root}" in
      (yes)
        export DIFF_OPTIONS=-u
        ;;
      (no)
        export DIFF_OPTIONS=-urN
        ;;
    esac
    ;;

  (*)
    ;;
esac

# Single history for all open shells
# but separate history file for jailed shell
# use short hostname as domain may be changed by DHCP
hf="${HOME}/.zhistory"
if [ X"${in_jail}" = X"yes" ]
then
  hf="${hf}.$(hostname -s)"
fi

# separate history for tmux windows
if [ -n "${TMUX_PANE}" ]
then
  t_name="$(  tmux list-windows -F '#{window_name}' -f '#{==:#{pane_id},'"${TMUX_PANE}"'}')"
  hf="${hf}.${t_name}"
  unset t_name
fi

HISTFILE="${hf}"
HISTSIZE=SAVEHIST=10000
setopt inc_append_history
setopt share_history
setopt extended_history
setopt hist_ignore_all_dups


# access the zkbd setup since it is in a versioned directory
function zkbd() {
  local p f
  for p in /usr /usr/local /usr/pkg
  do
    for f in "${p}/share/zsh/${ZSH_VERSION}/functions/Misc/zkbd" "${p}/share/zsh/functions/Misc/zkbd" \
             "${p}/share/zsh/${ZSH_VERSION}/functions/zkbd"      "${p}/share/zsh/functions/zkbd"
    do
      if [[ -f "${f}" ]]
      then
        zsh "${f}"
        break
      fi
    done
  done
}

# set up GPG_TTY for an ssh connection
if [ -n "${SSH_TTY}" ] && [ -n "${SSH_CONNECTION}" ]
then
  export GPG_TTY="${SSH_TTY}"
  #s="${HOME}/.gnupg/S.gpg-agent.ssh"
  #[ -S "${s}" ] && export SSH_AUTH_SOCK="${s}"
  #unset s
fi

# turn caps lock into compose (if running under X)
if which setxkbmap > /dev/null 2>&1
then
  [ -n "${DISPLAY}" ] && setxkbmap -option compose:caps -option shift:both_capslock_cancel
fi

# set up default function key map - if zkbd has been run
termfile="${HOME}/.zkbd/${TERM}-${${DISPLAY:t}:-${VENDOR}-${OSTYPE}}"
# if no os specific, try for a general one
[[ -e "${termfile}" ]] || termfile="${HOME}/.zkbd/${TERM}"
if [[ -e "${termfile}" ]]
then
  source "${termfile}"
  # [[ -n "${key[F1]}" ]] && bindkey "${key[F1]}" x
  # [[ -n "${key[F2]}" ]] && bindkey "${key[F2]}" x
  # [[ -n "${key[F3]}" ]] && bindkey "${key[F3]}" x
  # [[ -n "${key[F4]}" ]] && bindkey "${key[F4]}" x
  # [[ -n "${key[F5]}" ]] && bindkey "${key[F5]}" x
  # [[ -n "${key[F6]}" ]] && bindkey "${key[F6]}" x
  # [[ -n "${key[F7]}" ]] && bindkey "${key[F7]}" x
  # [[ -n "${key[F8]}" ]] && bindkey "${key[F8]}" x
  # [[ -n "${key[F9]}" ]] && bindkey "${key[F9]}" x
  # [[ -n "${key[F10]}" ]] && bindkey "${key[F10]}" x
  # [[ -n "${key[F11]}" ]] && bindkey "${key[F11]}" x
  # [[ -n "${key[F12]}" ]] && bindkey "${key[F12]}" x
  [[ -n "${key[Backspace]}" ]] && bindkey "${key[Backspace]}" backward-delete-char
  [[ -n "${key[Insert]}" ]] && bindkey "${key[Insert]}" yank
  [[ -n "${key[Home]}" ]] && bindkey "${key[Home]}" beginning-of-line
  [[ -n "${key[PageUp]}" ]] && bindkey "${key[PageUp]}" history-incremental-search-backward
  [[ -n "${key[Delete]}" ]] && bindkey "${key[Delete]}" delete-char
  [[ -n "${key[End]}" ]] && bindkey "${key[End]}" end-of-line
  [[ -n "${key[PageDown]}" ]] && bindkey "${key[PageDown]}" history-incremental-search-forward
  [[ -n "${key[Up]}" ]] && bindkey "${key[Up]}" up-line-or-history
  [[ -n "${key[Left]}" ]] && bindkey "${key[Left]}" backward-char
  [[ -n "${key[Down]}" ]] && bindkey "${key[Down]}" down-line-or-history
  [[ -n "${key[Right]}" ]] && bindkey "${key[Right]}" forward-char
  [[ -n "${key[Menu]}" ]] && bindkey "${key[Menu]}" list-choices
fi
unset termfile

# Setup XDG for console session if not already set by X session manager
[ -z "${XDG_CACHE_HOME}" ] && export XDG_CACHE_HOME="${HOME}/.cache"
[ -z "${XDG_CONFIG_DIRS}" ] && export XDG_CONFIG_DIRS="/etc/xdg:/usr/local/etc/xdg"
[ -z "${XDG_CONFIG_HOME}" ] && export XDG_CONFIG_HOME="${HOME}/.config"
[ -z "${XDG_CURRENT_DESKTOP}" ] && export XDG_CURRENT_DESKTOP=NONE
[ -z "${XDG_DATA_DIRS}" ] && export XDG_DATA_DIRS="/usr/local/share:/usr/share"
[ -z "${XDG_DATA_HOME}" ] && export XDG_DATA_HOME="${HOME}/.local/share"
[ -z "${XDG_SESSION_TYPE}" ] && export XDG_SESSION_TYPE=console
[ -z "${XDG_SESSION_CLASS}" ] && export XDG_SESSION_CLASS=user

# set cookie if using non-XDG aware display manager
[ -z "${XDG_SESSION_COOKIE}" ] && export XDG_SESSION_COOKIE="$(hostname -s)-$(date +'%s').$$-123456789"


# Source any machine specific aliases, or settings
if [[ -e "${HOME}/.zsh_local" ]]
then
  source "${HOME}/.zsh_local"
fi

# clean up
unset is_root
