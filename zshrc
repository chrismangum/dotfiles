alias tmux="TERM=xterm-256color; tmux"

if [[ $(uname) == 'Darwin' ]]; then
  alias pgstart="pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start"
  alias pgstop="pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log stop"
  alias find="gfind"
  alias bower="noglob bower"
  alias tar="gtar"
else
  alias weechat="weechat-curses"
  alias xlock="xscreensaver-command -lock"
  #safety nets:
  alias rm='rm -I --preserve-root'
  alias chown='chown --preserve-root'
  alias chmod='chmod --preserve-root'
  alias chgrp='chgrp --preserve-root'
fi

#git aliases
alias ga='git add'
alias gau='git add -u'
alias gaa='git add -A'
alias gc='git commit'
alias gcm='git commit -m'
alias gd='git diff'
alias gdc='git diff --cached'
alias gf='git fetch; git status'
alias gl='git log'
alias glg='git log --stat'
alias glp='git log -p'
alias gpl='git pull'
alias gp='git push origin master'
alias gpd='git push origin develop'
alias gst='git status'
alias gss='git status -s'

if [[ $(uname) == 'Linux' ]]; then
  #disable bell
  xset -b

  function mail() {
    cp ~/.mutt/gpg/$1.gpg ~/.mutt/gpg/pass.gpg
    mutt
  }
  function gen_flac_tags() {
    for i in *.flac; do
      metaflac --set-tag="TRACKNUMBER=$(echo $i | cut -d " " -f 1)" "$i"
      metaflac --set-tag="TITLE=$(echo $(basename "$i" .flac) | sed -r 's/[0-9]{2} //')" "$i"
    done

    metaflac --set-tag="ALBUM=$(basename "$(pwd)")" *.flac
    metaflac --set-tag="ARTIST=$(basename "$(dirname "$(pwd)")")" *.flac
  }
fi

#set apollo base dir
export APOLLO_BASE_DIR="/home/chris/www/Apollo"

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
if [[ $(uname) == 'Darwin' ]]; then
  ZSH_THEME="robbyrussell"
else
  ZSH_THEME="custom"
fi
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment this to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(osx web-search)

source $ZSH/oh-my-zsh.sh
alias ls="ls --color"

# Customize to your needs...
if [[ $(uname) == 'Darwin' ]]; then
  export PATH="/usr/local/bin:/usr/local/sbin:/usr/local/Cellar/coreutils/8.21/libexec/gnubin:$HOME/.rbenv/bin:$HOME/.rbenv/shims:/usr/bin:/bin:/usr/sbin:/sbin"
  eval "$(rbenv init -)"
else
  export PATH=/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin
fi


