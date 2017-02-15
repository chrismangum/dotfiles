uname=$(uname)
# If not running interactively, don't do anything
[[ $uname == 'Linux' && $- != *i* ]] && return

if [[ $uname == 'Linux' ]]; then
    source /usr/share/git/completion/git-prompt.sh
else
    source ~/scripts/git-prompt.sh
fi

# PS1 colors:
txtcyn='\e[0;36m'
bldblu='\e[1;34m'
txtrst='\e[0m'

export EDITOR=vim
export GREP_COLOR='1;32'
export PS1="\[$txtcyn\][\w]\$(__git_ps1 '[\[$bldblu\]%s\[$txtcyn\]]')\[$txtrst\]$ "
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

alias apollo_mongo='mongo --nodb'
alias arcnew="arc diff --reviewers '#apollo' --create"
alias arcpre='arc diff --preview'
alias arcupd='arc diff --update'
alias away='setJabberStatus away'
alias avail='setJabberStatus available'
alias cdag='cd ~/Cisco/apollo-gulp'
alias cdat='cd ~/Cisco/Atlantic-UI'
alias cdbdb='cd ~/Cisco/compose/web_ui/ui'
alias cdc='cd ~/Cisco'
alias cdcsc='cd ~/Cisco/ApolloCSCUploader'
alias cdhu='cd ~/Cisco/ApolloHubUser'
alias cdgsa='cd ~/Cisco/ApolloGoSA'
alias cdmd='cd ~/Cisco/ApolloMyDevices'
alias cdms='cd ~/Cisco/ApolloPlatformMicroServices'
alias cdrn='cd ~/Cisco/ApolloPlatformAutomation/ansible/roles/apache/files/html/docs/ReleaseNotes/sasa'
alias cdsa='cd ~/Cisco/ApolloSupportAutomation/client'
alias cdsc='cd ~/Cisco/ApolloSupportCases'
alias cdssa='cd ~/Cisco/ApolloSAStandalone'
alias cdsst='cdssa; cd build/standalone/staging'
alias cisco_vpn="sudo vpnc --no-detach /etc/vpnc/default.conf"
alias ga='git add'
alias gaa='git add -A'
alias gap='git add -p'
alias gau='git add -u'
alias gc='git commit'
alias gch='git checkout'
alias gcm='git commit -m'
alias gd='git diff -w'
alias gdc='gd --cached'
alias gf='git fetch; git status'
alias gl='git log -w'
alias glg='gl --stat'
alias glp='gl -p'
alias gp='git push'
alias gpl='git pull'
alias grep='grep --color=auto --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=bower_components --exclude-dir=vendor --exclude-dir=build'
alias gst='git status'
alias l='ls -lah'
alias ll='ls -lh'
alias ls='ls --color=auto'
alias myip='dig +short myip.opendns.com @resolver1.opendns.com'
alias pyserver='python -m http.server 3001'
alias pyserver2='python -m SimpleHTTPServer 3001'
alias rename='perl-rename'
alias sa_sync='cp -r ~/Cisco/ApolloSAStandalone/build/standalone/staging/ ~/Containers/Current/home/chris/www'
alias snw='cdsst; nw'
alias wcpe='mpv http://audio-mp3.ibiblio.org:8000/wcpe.mp3'
alias xlock='away; xscreensaver-command -lock'
alias xsleep='xlock; sleep 2; systemctl suspend'
alias wired_auth='sudo wpa_supplicant -D wired -i enp0s25 -c /etc/wpa_supplicant/wpa_supplicant-enp0s25.conf'

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

source ~/.kube/bash_config.sh

function ffmpegSplice() {
    ffmpeg -i $1 -ss 0 -c copy -t $2 cut1.mp4
    ffmpeg -i $1 -ss $3 -c copy cut2.mp4
    printf "file 'cut1.mp4'\nfile 'cut2.mp4'" > ffmpeg_concat.txt
    ffmpeg -f concat -i ffmpeg_concat.txt -c copy result.mp4
    rm cut1.mp4 cut2.mp4 ffmpeg_concat.txt
}

function gch_cli() {
    cdsa; gch $1
    cdhu; gch $1
    cdssa; gch $1
}

function mail() {
    cp ~/.mutt/gpg/$1.gpg ~/.mutt/gpg/pass.gpg
    mutt
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

function tmpv() {
    mpv https://twitch.tv/$1
}

# PATH:
export PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/sbin:/usr/sbin
#add java and node to cygiwn path
if [[ $uname == *'CYGWIN'* ]]; then
    export PATH=$PATH:/cygdrive/c/ProgramData/Oracle/Java/javapath:/cygdrive/c/Program\ Files/nodejs:/cygdrive/c/Users/chris/AppData/Roaming/npm
fi
# OS X: gnu coreutils paths:
if [[ $uname == 'Darwin' ]]; then
    export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
    export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
fi
