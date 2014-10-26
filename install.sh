#!/bin/bash
set -e

#create symlinks
stow -v alsa fonts git i3 mutt rtorrent scripts tmux urlview vim xorg yaourt zsh

#install fonts
fc-cache -vf $HOME/.fonts

#install vim plugins
if [[ ! -d ~/.vim/bundle ]]; then
  mkdir -p ~/.vim/bundle
  git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  vim +PluginInstall +qall
fi
