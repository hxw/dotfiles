# .bash_aliases

alias ll='ls -l'
alias la='ls -A'
alias lc='ls -CF'

# gnu diff does not have DIFFOPTIONS like FreeBSD so:
alias diff='diff -u'

alias reb='find . -name \*~ -print -delete'

export LESS="-iR"

if which eie > /dev/null 2>&1
then
  alias edit="eie --no-frame"
  alias ed="eie --no-wait"
  export EDITOR="eie"
elif which mg > /dev/null 2>&1
then
  alias edit="mg"
  alias ed="mg"
  export EDITOR="mg"
fi
elif which jove > /dev/null 2>&1
then
  alias edit="jove"
  alias ed="jove"
  export EDITOR="jove"
fi

# give lynx a custom configuration
alias lynx='lynx -nopause'

mkcd()
{
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

if [ -f ~/.bash_aliases_extra ]; then
    . ~/.bash_aliases_extra
fi
