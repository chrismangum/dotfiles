#!/bin/bash
set -e

#create symlinks
stow -v bash fonts git mintty tmux vim

#install fonts
if [[ -x fc-cache ]]; then
  fc-cache -vf $HOME/.fonts
fi

#install vim colors
if [[ ! -d ~/.vim/colors ]]; then
  mkdir -p ~/.vim/colors
  curl -s -o ~/.vim/colors/smyck.vim https://raw.githubusercontent.com/hukl/Smyck-Color-Scheme/master/smyck.vim
fi

#install vim plugins
if [[ ! -d ~/.vim/bundle ]]; then
  mkdir -p ~/.vim/bundle
  git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  vim +PluginInstall +qall
fi
