call pathogen#infect()
syntax on
filetype plugin on
set number
set autoread
set ruler
set t_Co=256
set smartindent
set expandtab
set hlsearch
set incsearch
set pastetoggle=<F3>
set ignorecase
set nofoldenable
autocmd BufEnter * set sw=2 sts=2 ts=2 nospell
"set tabs to 4 spaces for specific projects
autocmd BufEnter ~/www/Apollo/*,~/www/ApolloHubUser/*,~/www/ApolloHubAdmin/* set sw=4 sts=4 ts=4
"enable spell checker for mail messages
autocmd BufEnter /tmp/* set spell spelllang=en_us
colorscheme xoria256
