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
elif [[ -x "$(whence mg)" ]]
then
  alias edit="mg"
  alias ed="mg"
  export EDITOR="mg"
elif  [[ -x "$(jove eie)" ]]
then
  alias edit="jove"
  alias ed="jove"
  export EDITOR="jove"
fi

# For less
export LESS="-iR"

# make a directory and change to it
function mkcd { mkdir -p "$1"; cd "$1"; }

# Single history for all open shells
HISTFILE=~/.zhistory
HISTSIZE=SAVEHIST=10000
setopt incappendhistory
setopt sharehistory
setopt extendedhistory

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
PS1='[%T] %n@%m:%2~%# '

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

    function dq {
      dpkg-query -W --showformat='${Installed-Size} ${Package} ${Status}\n' | grep -v deinstall | sort -n | awk '{print $1" "$2}'
    }
    export TIME_STYLE='posix-long-iso'
    ;;

  (FreeBSD)
    if [[ "${TERM}" = "rxvt-unicode" ]]
    then
      TERM=rxvt-unicode-256color
    fi
    alias toor='exec su -l toor'
    alias ls='ls -GF'
    alias ll='ls -l'
    alias la='ls -la'
    alias lc='ls -C'
    export DIFF_OPTIONS=-urN
    export GREP_OPTIONS=--colour=auto
    ;;

  (NetBSD)
    if [[ "${TERM}" = "rxvt-unicode" ]]
    then
      TERM=rxvt-256color
    fi
    alias toor='exec su -l toor'
    alias ls='ls -F'
    alias ll='ls -l'
    alias la='ls -la'
    alias lc='ls -CF'
    alias grep='grep --colour=auto'
    export DIFF_OPTIONS=-urN
    ;;

  (*)
    ;;
esac
