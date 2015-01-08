#!/bin/bash
set -e

#create symlinks
if [[ ! -d ~/.config ]]; then
  mkdir -v ~/.config
fi
stow -v alsa bash cups fonts git i3 mutt redshift rtorrent scripts tmux tsocks urlview vim xorg yaourt

#install fonts
fc-cache -vf $HOME/.fonts

#install vim plugins
if [[ ! -d ~/.vim/bundle ]]; then
  mkdir -p ~/.vim/bundle
  git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  vim +PluginInstall +qall
fi
