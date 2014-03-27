# use vim as an editor
export EDITOR=vim

# set apollo base dir
export APOLLO_BASE_DIR='/home/chris/www/Apollo'

# aliases
if [[ -e ~/.aliases ]]; then
  source ~/.aliases
fi

if [[ $(uname) == 'Linux' ]]; then
  #disable bell
  xset -b

  function mail() {
    cp ~/.mutt/gpg/$1.gpg ~/.mutt/gpg/pass.gpg
    mutt
  }
fi

# oh-my-zsh options:
ZSH=~/.oh-my-zsh
ZSH_THEME='robbyrussell'
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
fi

# PATH:
if [[ $(uname) == 'Darwin' ]]; then
  export PATH=/usr/local/bin:/usr/local/sbin:~/.rbenv/bin:~/.rbenv/shims:/usr/bin:/bin:/usr/sbin:/sbin
  eval "$(rbenv init -)"
else
  export PATH=~/.gem/ruby/2.1.0/bin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin
fi


