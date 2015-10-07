#!/bin/bash

set -e

mkdir -pv ~/.config/systemd/user \
  ~/.local/share/xorg \

#copy and add systemd user services
cp -v systemd/.config/systemd/user/* ~/.config/systemd/user
for i in ~/.config/systemd/user/*.service; do systemctl --user enable $(basename $i); done;

#create symlinks
stow -v alsa bash cygwin cups fonts git gtk i3 mpv mutt redshift rtorrent scripts tmux tsocks \
  urlview vim xorg yaourt

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
