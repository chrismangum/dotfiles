# If not running interactively, don't do anything
[[ $(uname) == 'Linux' && $- != *i* ]] && return

source ~/scripts/git-prompt.sh

# PS1 colors:
txtcyn='\e[0;36m'
bldblu='\e[1;34m'
txtrst='\e[0m'

export APOLLO_BASE_DIR=$HOME/Cisco/Apollo
export EDITOR=vim
export GREP_COLOR='1;32'
export PS1="\[$txtcyn\][\w]\$(__git_ps1 '[\[$bldblu\]%s\[$txtcyn\]]')\[$txtrst\]$ "
export TSOCKS_CONF_FILE=$HOME/.tsocks.conf

alias cdap='cd ~/Cisco/Apollo/common/client'
alias cdc='cd ~/Cisco'
alias cdha='cd ~/Cisco/ApolloHubAdmin'
alias cdhu='cd ~/Cisco/ApolloHubUser'
alias cdib='cd ~/Cisco/ApolloInstallBase'
alias cdsa='cd ~/Cisco/ApolloSupportAutomation/client'
alias cdsc='cd ~/Cisco/ApolloSupportCases'
alias cmongo="stackato ssh -a ciscoAdmin '"'MONGO_INFO=($(cat /app/fs/apollo-hub-fs/config/mongoCfg.json | json hostname port username password db)); mongo -u ${MONGO_INFO[2]} -p ${MONGO_INFO[3]} ${MONGO_INFO[0]}/${MONGO_INFO[4]}'"'"
alias ga='git add'
alias gaa='git add -A'
alias gap='git add -p'
alias gau='git add -u'
alias gc='git commit'
alias gch='git checkout'
alias gcm='git commit -m'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gdc='git diff --cached'
alias gf='git fetch; git status'
alias glg='git log --stat'
alias glp='git log -p'
alias gp='git push'
alias gpl='git pull'
alias grep='grep --color=auto --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=bower_components --exclude-dir=vendor'
alias gst='git status'
alias l='ls -lah'
alias ll='ls -lh'
alias ls='ls --color=auto'
alias myip='dig +short myip.opendns.com @resolver1.opendns.com'
alias pyserver='python2 -m SimpleHTTPServer 3001'
alias rename='perl-rename'
alias s='stackato'
alias xlock='xscreensaver-command -lock'
if [[ $(uname) == 'Darwin' ]]; then
  alias ls='ls -G'
fi

# safety nets:
alias chgrp='chgrp --preserve-root'
alias chmod='chmod --preserve-root'
alias chown='chown --preserve-root'
alias rm='rm -I --preserve-root'
if [[ $(uname) == 'Darwin' ]]; then
  unalias rm
fi

# history
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=100000
export HISTFILESIZE=100000
export PROMPT_COMMAND="history -a"

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
