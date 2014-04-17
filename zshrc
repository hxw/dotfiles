# .zshrc      -*- mode: shell-script -*-

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
export LESS="-iR"

# make a directory and change to it
function mkcd {
  local dir
  dir="$1"; shift

  if [ -z "${dir}" ]
  then
    pwd
  elif [ -d "${dir}" ]
  then
    cd "${dir}"
  elif [ -f "${dir}" ]
  then
   echo A file of that name already exists
   return 1
  else
    mkdir -p "${dir}"
    cd "${dir}"
  fi
  return 0
}

# remove items from PATH
function pathrm {
  local item p pa

  pa=(${(s/:/)PATH})
  for item in $@
  do
    pa=("${pa[@]/${item}/}")
  done

  p=
  for item in "${pa[@]}"
  do
    [ -n "${item}" ] && p="${p}:${item}"
  done
  PATH="${p:1}"
}

# add items to front of PATH
# move existing items to front of PATH
function pathfront {
  local item p
  pathrm "$@"

  p=
  for item in $@
  do
    [ -n "${item}" ] && p="${p}:${item}"
  done
  PATH="${p:1}:${PATH}"
}

# show path
alias path='echo ${PATH}'

# put user's bin directory first
[ -d "${HOME}/bin" ] && pathfront "${HOME}/bin"

# Single history for all open shells
HISTFILE=~/.zhistory
HISTSIZE=SAVEHIST=10000
setopt inc_append_history
setopt share_history
setopt extended_history
setopt hist_ignore_all_dups

# Enables all sorts of extended globbing:
#   ls */.txt       find all text files
#   ls -d *(D)      show all files including those starting with "."
# Note:  man zshexpn   -> section "FILENAME GENERATION".
setopt extendedglob
unsetopt caseglob

# Save comments in history
# This is useful to remember command in your history without executing them
setopt interactivecomments

# Type ".." instead of "cd ..", "/usr/include" instead of "cd /usr/include"
setopt auto_cd

# Change the prompt
#PS1='[%T] %n@%m %2~ %# '

# colours: black red green yellow blue magenta cyan white
PS1='%F{magenta}%B[%T]%b%f %F{green}%B%n@%m%b%f %F{cyan}%B%2~ %#%b%f '


# Display CPU usage stats for commands taking more than 10 seconds
REPORTTIME=10

# OS specific items
case "$(uname -s)" in
  (Linux)
    eval $(dircolors)
    alias ls='ls -F --color=auto'
    alias ll='ls -l'
    alias la='ls -a'
    alias lc='ls -C'
    alias diff='diff -urN'

    alias acs='apt-cache search'
    alias aw='apt-cache show'

    alias alp='netstat -plunt'
    alias alps='netstat -plut --numeric-host'

    function dq {
      dpkg-query -W --showformat='${Installed-Size} ${Package} ${Status}\n' | grep -v deinstall | sort -n | awk '{print $1" "$2}'
    }
    export TIME_STYLE='posix-long-iso'
    ;;

  (FreeBSD)
    if [[ "${TERM}" =~ "^rxvt" ]]
    then
      TERM=rxvt-unicode-256color
    fi
    alias toor='exec su -l toor'
    alias ls='ls -GF'
    alias ll='ls -l'
    alias la='ls -la'
    alias lc='ls -C'

    alias alp="netstat -an |grep --colour=never '\(^Proto.*\|LISTEN\|^udp\)'"
    alias alps="netstat -aS |grep --colour=never '\(^Proto.*\|LISTEN\|^udp\)'"

    export DIFF_OPTIONS=-urN
    export GREP_OPTIONS=--colour=auto
    ;;

  (NetBSD)
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

    export DIFF_OPTIONS=-urN
    ;;

  (*)
    ;;
esac

# Source any machine specific aliases, or settings
if [[ -e "${HOME}/.zsh_local" ]]
then
  source "${HOME}/.zsh_local"
fi
