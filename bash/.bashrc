source ~/scripts/git-prompt.sh

export APOLLO_BASE_DIR=$HOME/Cisco/Apollo
export EDITOR=vim
export GREP_COLOR='1;32'
export GREP_OPTIONS='--color=auto --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=bower_components --exclude-dir=vendor'
export PS1='\e[0;36m[\w]$(__git_ps1 "[\e[1;34m%s\e[0;36m]")\e[m$ '

alias ga='git add'
alias gaa='git add -A'
alias gap='git add -p'
alias gau='git add -u'
alias gc='git commit'
alias gch='git checkout'
alias gcm='git commit -m'
alias gd='git diff'
alias gdc='git diff --cached'
alias gf='git fetch; git status'
alias glg='git log --stat'
alias glp='git log -p'
alias gp='git push'
alias gpl='git pull'
alias gst='git status'
alias l='ls -lah'
alias ll='ls -lh'
alias ls='ls --color'
alias myip='dig +short myip.opendns.com @resolver1.opendns.com'
alias pyserver='python2 -m SimpleHTTPServer 3001'
alias rename='perl-rename'
alias s='stackato'
alias xlock='xscreensaver-command -lock'

#safety nets:
alias chgrp='chgrp --preserve-root'
alias chmod='chmod --preserve-root'
alias chown='chown --preserve-root'
alias rm='rm -I --preserve-root'

function mail() {
  cp ~/.mutt/gpg/$1.gpg ~/.mutt/gpg/pass.gpg
  mutt
}

function speedtest() {
  local url='http://speedtest.wdc01.softlayer.com/downloads/test10.zip'
  local speed_bps=$(curl -o /dev/null -w '%{speed_download}' -s $url)
  local speed_mbps=$(bc <<< "scale=3; $speed_bps / 1024 / 1024 * 8")
  echo "Download: $speed_mbps Mbps"
}

# PATH:
export PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/sbin:/usr/sbin
