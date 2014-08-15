set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" Plugins
Plugin 'gmarik/Vundle.vim'
Plugin 'jlanzarotta/bufexplorer'
Plugin 'tpope/vim-commentary'
Plugin 'kien/ctrlp.vim'
Plugin 'kchmck/vim-coffee-script'
Plugin 'digitaltoad/vim-jade'
Plugin 'pangloss/vim-javascript'
Plugin 'wavded/vim-stylus'
" Colors
Plugin 'https://bitbucket.org/chadhs/smyck.vim'
call vundle#end()

syntax on
filetype plugin indent on
set autoindent
set expandtab
set number
set ignorecase smartcase
set hlsearch
set cursorline
set incsearch
set visualbell noerrorbells
set ruler
set list listchars=tab:»·,trail:· " show extra space characters
set nofoldenable
set wildmenu                      " enable bash style tab completion
set wildmode=list:longest,full

set autoread
set hidden
set nobackup
set noswapfile
set pastetoggle=<F3>
set showcmd
set t_Co=256

colorscheme smyck

highlight ColorColumn ctermbg=16
highlight StatusLine  ctermbg=16
highlight SpellBad    ctermbg=0  ctermfg=1

autocmd BufEnter * set cc=80 tw=0 sw=2 sts=2 ts=2 nospell
" set tabs to 4 spaces for specific projects
autocmd BufEnter ~/www/Cisco/ApolloHubUser/*,~/www/Cisco/ApolloHubAdmin/*,~/www/Cisco/ApolloInstallBase/*,~/www/Cisco/ApolloSupportCases/* set sw=4 sts=4 ts=4
" enable spell checker for mail messages
autocmd BufEnter /tmp/* set cc=72 tw=72 spell spelllang=en_us

" ctrlp settings
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 0
let g:ctrlp_custom_ignore = '\v[\/]\.git$'
