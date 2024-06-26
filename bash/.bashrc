uname=$(uname)
# If not running interactively, don't do anything
[[ $uname == 'Linux' && $- != *i* ]] && return

# start ssh-agent
eval $(keychain -q --eval)

# ubuntu:
if [[ -e /usr/lib/git-core/git-sh-prompt ]]; then
  source /usr/lib/git-core/git-sh-prompt
else
  source ~/scripts/git-prompt.sh
fi

# pass bash completion:
if [[ -e /usr/share/bash-completion/completions/pass ]]; then
  source /usr/share/bash-completion/completions/pass
fi

# artifactory
if [[ -e ~/www/sg1_artifactory/token.sh ]]; then
  source ~/www/sg1_artifactory/token.sh
fi

# PS1 colors:
txtcyn='\e[0;36m'
bldblu='\e[1;34m'
txtrst='\e[0m'

export EDITOR=vim
export GREP_COLORS='ms=01;29'
export PS1="\[$txtcyn\][\w]\$(__git_ps1 '[\[$bldblu\]%s\[$txtcyn\]]')\[$txtrst\]$ "
export LESS="$LESS -R -Q"

if [[ $TERM != linux && $TERM != *-256color ]]; then
  export TERM=$TERM-256color
fi

# wsl:
if [[ -e /proc/version ]] && grep -q Microsoft /proc/version; then
  cisco_dir=/mnt/c/Users/chris/Cisco
else
  cisco_dir=$HOME/Cisco
fi

function mongoCreds() {
  local env=$1
  local field=$2
  echo -n "$(cat /etc/mongorc.json | jq '.'['"'$env'"']'.'$field)"
}

function awsMongoCreds() {
  cat "/home/chris/Cisco/terraform/secrets/$1/ironbank_secrets_mapping.json" | jq -r '.REPLACE_MONGO_MAIN_USER | split(":") | .['"$2]"
}

function awsMongoDomain() {
  cat "/home/chris/Cisco/terraform/secrets/$1/ironbank_secrets_mapping.json" | jq -r '.REPLACE_MONGO_DOMAIN'
}

function awsMongo() {
  database=${2:-cp-ironbank}
  awsMongoCreds $1 1; mongosh "mongodb+srv://$(awsMongoDomain $1)/$database" --username $(awsMongoCreds $1 0)
}

function apollo_mongo() {
  local ns=${1:-ironbank-dev}
  mongosh "mongodb://swtg-qa-mongo-2a.cisco.com:27017,swtg-qa-mongo-2b.cisco.com:27017,swtg-qa-mongo-2c.cisco.com:27017/$ns?replicaSet=apollo" --username $(mongoCreds $ns username) --password $(mongoCreds $ns password)
}

function rtplab_mongo() {
  local ns=${1:-tac-forms-dev}
  mongosh "mongodb://rtplab-mongo-1a.cisco.com:27017,rtplab-mongo-1b.cisco.com:27017,rtplab-mongo-1c.cisco.com:27017,rtplab-mongo-1d.cisco.com:27017,rtplab-mongo-1e.cisco.com:27017/$ns?replicaSet=rs0" --username $(mongoCreds $ns username) --password $(mongoCreds $ns password)
}

alias cal='ncal -C'
alias cdds='cdc cx-diagnostics-service'
alias cdia='cdc ironbank-auth'
alias cdiau='cdc ironbank-audit-utils'
alias cdib='cdc banker'
alias cdic='cdc counter'
alias cdicu='cdc ironbank-collection-utils'
alias cdil='cdc ironbank-libraries'
alias cdim='cdc migrator'
alias cdis='cdc ironbank'
alias cdssa='cdc CLIAnalyzer'
alias cdts='cdc tac-forms-service'
alias cdtu='cdc tac-forms-ui'
alias cdui='cdc IronBankApp'
alias cduia='cdc IronBankApp/src/app'
alias docker='podman'
alias ffmpeg='ffmpeg -hide_banner'
alias fly='fly -t swtg'
alias ga='git add'
alias gaa='git add -A'
alias gap='git add -p'
alias gau='git add -u'
alias gc='git commit -n'
alias gch='git checkout'
alias gcm='gc -m'
alias gd='git diff -w'
alias gdc='gd --cached'
alias gf='git fetch; git status'
alias gl='git log -w'
alias glg='gl --stat'
alias glp='gl -p'
alias gp='git push'
alias gpl='git pull'
alias grep='grep --color=auto --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=bower_components --exclude-dir=vendor --exclude-dir=dist --exclude-dir=build --exclude-dir=coverage'
alias gst='git status'
alias l='ls -lah'
alias ll='ls -lh'
alias ls='ls --color=auto'
alias pino='pino-pretty -t --messageKey message --ignore loggerName,loggerSource,contextMap'
alias pyserver='python3 -m http.server 3001'
alias xlock='gtklock -d'
alias xsleep='xlock; sleep 2; systemctl suspend'

# atlas clusters:
alias taco_mongo="awsMongo ib-use1-taco-prd"
alias dev_mongo="awsMongo cluster01_usw2_cx-nprd-dev"
alias perf_us_mongo="awsMongo cluster01_usw2_cx-nprd-performance"
alias perf_eu_mongo="awsMongo cluster01_euc1_cx-nprd-performance"
alias perf_aus_mongo="awsMongo cluster01_aps2_cx-nprd-performance"
alias prod_us_mongo="awsMongo cluster01_usw2_cx-prd-cxc"
alias prod_eu_mongo="awsMongo cluster01_euc1_cx-prd-cxc"
alias prod_aus_mongo="awsMongo cluster01_aps2_cx-prd-cxc"

# reduce mouse accel for sc2:
# alias get_pointer_id="xinput list | grep -Po 'Logitech M325\s+id=\d+.+pointer' | grep -Po '(?<==)\d+'"
alias get_pointer_id='for i in $(xinput list | grep -Po "Viper Mini\s+id=\d+.+pointer" | grep -Po "(?<==)\d+"); do xinput list-props $i | grep -q "libinput Accel Speed (" && echo $i; done'
function set_accel() {
  xinput --set-prop $(get_pointer_id) 'libinput Accel Speed' -0.5
}
function show_accel() {
  xinput list-props $(get_pointer_id) | grep 'libinput Accel Speed (' | cut -d ':' -f 2 | perl -pe 's/^\s*//'
}

# radio stations
alias wcpe='mpv http://audio-mp3.ibiblio.org:8000/wcpe.mp3 --volume=50'
alias wncu='mpv https://wncu.streamguys1.com/live --volume=50'
alias wunc='mpv https://edg-iad-wunc-ice.streamguys1.com/wunc-128-mp3.m3u --volume=50'

# safety nets:
alias chgrp='chgrp --preserve-root'
alias chmod='chmod --preserve-root'
alias chown='chown --preserve-root'
alias rm='rm -I --preserve-root'

# history
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=100000
export HISTFILESIZE=100000
export PROMPT_COMMAND='history -a'

source ~/.kube/bash_config.sh

function cdc() {
  cd $cisco_dir/$1
}

function ffmpegSplice() {
  ffmpeg -i $1 -ss 0 -c copy -t $2 cut1.mp4
  ffmpeg -i $1 -ss $3 -c copy cut2.mp4
  printf "file 'cut1.mp4'\nfile 'cut2.mp4'" > ffmpeg_concat.txt
  ffmpeg -f concat -i ffmpeg_concat.txt -c copy result.mp4
  rm cut1.mp4 cut2.mp4 ffmpeg_concat.txt
}

function dockerNuke() {
  docker stop $(docker ps -a -q);
  docker rm $(docker ps -a -q) --force;
  docker rmi $(docker images -q) --force;
}

function tmpv() {
  mpv https://twitch.tv/$1
}

# PATH:
export PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/sbin:/usr/sbin

# add snap binaries to path
if [[ -d /snap/bin ]]; then
  export PATH="$PATH:/snap/bin"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
