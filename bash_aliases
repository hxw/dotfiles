# .bash_aliases -*- mode: shell-script -*-

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
elif which jove > /dev/null 2>&1
then
  alias edit="jove"
  alias ed="jove"
  export EDITOR="jove"
fi

# give lynx a custom configuration
alias lynx='lynx -nopause'

# this is a quick fix for lxterminal tab names
if [ -z "${PROMPT_COMMAND}" ]
then
  cd
  PROMPT_COMMAND='echo -ne "\033]0;${PWD/${HOME}/~}\007"'
fi

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

# remove items from PATH
pathrm()
{
  local item pa p IFS old_ifs
  old_ifs="${IFS}"
  IFS=':'
  pa=(${PATH})
  IFS="${old_ifs}"

  for item in $@
  do
    pa=("${pa[@]/${item}/}")
  done

  p=
  for item in "${pa[@]}"
  do
    [ -n "${item}" ] && p="${p}:${item}"
  done
  pa="${pa[@]}"
  PATH="${p:1}"
}

# add items to front of PATH
# move existing items to front of PATH
pathfront()
{
  local item p
  pathrm "$@"

  p=
  for item in $@
  do
    [ -n "${item}" ] && p="${p}:${item}"
  done
  PATH="${p:1}:${PATH}"
}

# include machine specific aliases
if [ -f ~/.bash_aliases_extra ]; then
    . ~/.bash_aliases_extra
fi
