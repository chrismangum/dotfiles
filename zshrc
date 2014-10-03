# use vim as an editor
export EDITOR=vim

# set apollo base dir
export APOLLO_BASE_DIR=$HOME/Cisco/Apollo

# aliases
if [[ -e ~/.aliases ]]; then
  source ~/.aliases
fi

function mail() {
  cp ~/.mutt/gpg/$1.gpg ~/.mutt/gpg/pass.gpg
  mutt
}

# oh-my-zsh options:
ZSH=~/.oh-my-zsh
ZSH_THEME='custom'
DISABLE_AUTO_TITLE='true'
DISABLE_CORRECTION='true'

# oh-my-zsh plugins:
# format: plugins=(rails git textmate ruby lighthouse)
if [[ $(uname) == 'Linux' ]]; then
  plugins=(vi-mode)
fi

source $ZSH/oh-my-zsh.sh

# modifications to vi mode:
if [[ $(uname) == 'Linux' ]]; then
  bindkey '^?' backward-delete-char
  bindkey '^W' backward-kill-word
  bindkey '^R' history-incremental-search-backward
  bindkey '^F' history-incremental-search-forward
fi

# PATH:
export PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/sbin:/usr/sbin
if [[ $(uname) == 'Darwin' ]]; then
  export PATH=~/bin:$PATH
fi
