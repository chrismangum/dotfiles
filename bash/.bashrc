uname=$(uname)
# If not running interactively, don't do anything
[[ $uname == 'Linux' && $- != *i* ]] && return

source /usr/share/git/completion/git-prompt.sh

# PS1 colors:
txtcyn='\e[0;36m'
bldblu='\e[1;34m'
txtrst='\e[0m'

export APOLLO_BASE_DIR=$HOME/Cisco/Apollo
export EDITOR=vim
export GREP_COLOR='1;32'
export PS1="\[$txtcyn\][\w]\$(__git_ps1 '[\[$bldblu\]%s\[$txtcyn\]]')\[$txtrst\]$ "
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

alias apollo_mongo='mongo swtgdev-mongo-1.cisco.com/db'
alias arcnew="arc diff --reviewers '#apollo' --create"
alias arcpre='arc diff --preview'
alias arcupd='arc diff --update'
alias away='setJabberStatus away'
alias avail='setJabberStatus available'
alias cdap='cd ~/Cisco/Apollo'
alias cdc='cd ~/Cisco'
alias cdha='cd ~/Cisco/ApolloHubAdmin'
alias cdhu='cd ~/Cisco/ApolloHubUser'
alias cdib='cd ~/Cisco/ApolloInstallBase'
alias cdgsa='cd ~/Cisco/ApolloGoSA'
alias cdmd='cd ~/Cisco/ApolloMyDevices'
alias cdsa='cd ~/Cisco/ApolloSupportAutomation/client'
alias cdsc='cd ~/Cisco/ApolloSupportCases'
alias cdssa='cd ~/Cisco/ApolloSAStandalone'
alias cdsst='cdssa; cd build/standalone/staging'
alias cdst='cd ~/Cisco/ApolloStorage'
alias cisco_vpn='sudo openconnect --csd-wrapper=/home/chris/scripts/csd-wrapper-simple.sh --cafile=/etc/openconnect/cisco-root-CA-M1.pem rtp1-asavpn-cluster-1.cisco.com'
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
alias grep='grep --color=auto --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=bower_components --exclude-dir=vendor --exclude-dir=build'
alias gst='git status'
alias l='ls -lah'
alias ll='ls -lh'
alias ls='ls --color=auto'
alias myip='dig +short myip.opendns.com @resolver1.opendns.com'
alias pyserver='python2 -m SimpleHTTPServer 3001'
alias rename='perl-rename'
alias s='stackato'
alias snw='cdsst; nw'
alias stackato='stackato --skip-ssl-validation'
alias wcpe='mpv http://audio-mp3.ibiblio.org:8000/wcpe.mp3'
alias xlock='away; xscreensaver-command -lock'
alias xsleep='xlock; sleep 2; systemctl suspend'

if [[ $uname == *'CYGWIN'* ]]; then
  export TERM=xterm-256color
fi

# safety nets:
alias chgrp='chgrp --preserve-root'
alias chmod='chmod --preserve-root'
alias chown='chown --preserve-root'
alias rm='rm -I --preserve-root'

# history
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=100000
export HISTFILESIZE=100000
export PROMPT_COMMAND="history -a"

source ~/Desktop/.bashrc_private

function gch_cli() {
  cdsa; gch $1
  cdhu; gch $1
  cdssa; gch $1
}

function mail() {
  cp ~/.mutt/gpg/$1.gpg ~/.mutt/gpg/pass.gpg
  mutt
}

function ffmpegSplice() {
  ffmpeg -i $1 -ss 0 -c copy -t $2 cut1.mp4
  ffmpeg -i $1 -ss $3 -c copy cut2.mp4
  printf "file '$PWD/cut1.mp4'\nfile '$PWD/cut2.mp4'" > /tmp/ffmpeg_concat.txt
  ffmpeg -f concat -i /tmp/ffmpeg_concat.txt -c copy result.mp4
  rm cut1.mp4 cut2.mp4
}

function setJabberStatus() {
  purple-remote setstatus?status=$1
}

function speedtest() {
  local url='http://speedtest.wdc01.softlayer.com/downloads/test10.zip'
  local speed_bps=$(curl -o /dev/null -w '%{speed_download}' -s $url)
  local speed_mbps=$(bc <<< "scale=3; $speed_bps / 1024 / 1024 * 8")
  echo "Download: $speed_mbps Mbps"
}

# PATH:
export PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/sbin:/usr/sbin
#add java and node to cygiwn path
if [[ $uname == *'CYGWIN'* ]]; then
  export PATH=$PATH:/cygdrive/c/ProgramData/Oracle/Java/javapath:/cygdrive/c/Program\ Files/nodejs:/cygdrive/c/Users/chris/AppData/Roaming/npm
fi
