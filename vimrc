set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'jlanzarotta/bufexplorer'
Plugin 'scrooloose/nerdcommenter'
Plugin 'kien/ctrlp.vim'
Plugin 'kchmck/vim-coffee-script'
Plugin 'digitaltoad/vim-jade'
Plugin 'pangloss/vim-javascript'
Plugin 'wavded/vim-stylus'
call vundle#end()

syntax on
filetype plugin on
set hidden
set nobackup
set noswapfile
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
set visualbell
set noerrorbells

autocmd BufEnter * set cc=80 tw=0 sw=2 sts=2 ts=2 nospell
autocmd BUfEnter * hi ColorColumn ctermbg=16

" ctrlp settings
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 0
let g:ctrlp_custom_ignore = '\v[\/]\.git$'

" set tabs to 4 spaces for specific projects
autocmd BufEnter ~/www/Cisco/ApolloHubUser/*,~/www/Cisco/ApolloHubAdmin/*,~/www/Cisco/ApolloInstallBase/*,~/www/Cisco/ApolloSupportCases/* set sw=4 sts=4 ts=4

" enable spell checker for mail messages
autocmd BufEnter /tmp/* set cc=72 tw=72 spell spelllang=en_us

" Display extra whitespace
set list listchars=tab:»·,trail:·

colorscheme smyck
