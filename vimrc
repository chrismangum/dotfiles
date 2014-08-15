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

" ctrlp settings
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'
set wildignore+=*.swp,*.zip
let g:ctrlp_custom_ignore = '\v[\/]\.git$'

" set tabs to 4 spaces for specific projects
autocmd BufEnter ~/www/ApolloHubUser/*,~/www/ApolloHubAdmin/*,~/www/ApolloInstallBase/*,~/www/ApolloSupportCases/* set sw=4 sts=4 ts=4

" enable spell checker for mail messages
autocmd BufEnter /tmp/* set spell spelllang=en_us

" Display extra whitespace
set list listchars=tab:»·,trail:·

colorscheme smyck
