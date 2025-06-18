#!/bin/bash

set -e

mkdir -pv ~/.config/duo-sso

#create symlinks
stow -v bash duo-sso git gnupg scripts tmux nvim

#install nvim colors
if [[ ! -d ~/.config/nvim/colors ]]; then
  mkdir -p ~/.config/nvim/colors
  curl -s -o ~/.config/nvim/colors/smyck.vim https://raw.githubusercontent.com/hukl/Smyck-Color-Scheme/master/smyck.vim
fi

#install nvim plugins
if [[ ! -d ~/.local/share/nvim/site/autoload ]]; then
  mkdir -p ~/.local/share/nvim/site/autoload
  curl -s -o ~/.local/share/nvim/site/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  mkdir -p ~/.local/share/nvim/site/plugged
  nvim +PlugInstall +qall
fi
