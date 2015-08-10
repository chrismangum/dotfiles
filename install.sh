#!/bin/bash
set -e

if [[ ! -d ~/.config/systemd/user ]]; then
  mkdir -pv ~/.config/systemd/user
fi

#create symlinks
stow -v alsa bash cygwin cups fonts git i3 mutt redshift rtorrent scripts tmux tsocks urlview vim xorg yaourt

#install fonts
if [[ -x fc-cache ]]; then
  fc-cache -vf $HOME/.fonts
fi

#install vim plugins
if [[ ! -d ~/.vim/bundle ]]; then
  mkdir -p ~/.vim/bundle
  git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  vim +PluginInstall +qall
fi
