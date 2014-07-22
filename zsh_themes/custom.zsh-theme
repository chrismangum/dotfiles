
function custom_prompt_info() {
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
  ret="$ZSH_THEME_GIT_PROMPT_PREFIX"
  if isnt_clean; then
    ret+="%{$fg[red]%}"
  elif isnt_synced; then
    ret+="%{$fg[yellow]%}"
  else
    ret+="%{$fg[green]%}"
  fi
  ret+="${ref#refs/heads/}$ZSH_THEME_GIT_PROMPT_SUFFIX"
  echo "$ret"
}

function isnt_clean() {
  local SUBMODULE_SYNTAX=''
  local GIT_STATUS=''
  if [[ $POST_1_7_2_GIT -gt 0 ]]; then
    SUBMODULE_SYNTAX="--ignore-submodules=dirty"
  fi
  if [[ "$DISABLE_UNTRACKED_FILES_DIRTY" == "true" ]]; then
    GIT_STATUS=$(command git status -s ${SUBMODULE_SYNTAX} -uno 2> /dev/null | tail -n1)
  else
    GIT_STATUS=$(command git status -s ${SUBMODULE_SYNTAX} 2> /dev/null | tail -n1)
  fi
  if [[ -n $GIT_STATUS ]]; then
    return 0
  else
    return 1
  fi
}

function isnt_synced() {
  remote=${$(command git rev-parse --verify ${hook_com[branch]}@{upstream} --symbolic-full-name 2>/dev/null)/refs\/remotes\/}
  if [[ -n ${remote} ]] ; then
    ahead=$(command git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
    behind=$(command git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)
    if [ $ahead -gt 0 ] || [ $behind -gt 0 ]; then
      return 0
    fi
  fi
  return 1
}

PROMPT='%{$fg[cyan]%}[%~]%{$reset_color%}$ '
RPROMPT='$(custom_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[cyan]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[cyan]%}]%{$reset_color%}"
#ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}$"
#ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}$"
