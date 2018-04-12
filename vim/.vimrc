
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" Plugins
Plugin 'gmarik/Vundle.vim'
Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-surround'
" Syntax
Plugin 'digitaltoad/vim-jade'
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'
Plugin 'leafgarland/typescript-vim'
call vundle#end()

syntax on
filetype plugin indent on
set autoindent                    " align the new line indent with the previous line
" set expandtab                     " insert spaces when hitting TABs
set number
set relativenumber
set ignorecase smartcase
set hlsearch
set cursorline
set incsearch
set visualbell noerrorbells
set ruler
" set list listchars=tab:»·,trail:· " show extra space characters
set nofoldenable
set shiftround                    " round indent to multiple of 'shiftwidth'
set shiftwidth=4                  " operation >> indents 4 columns; << unindents 4 columns
" set softtabstop=4                 " insert/delete 4 spaces when hitting a TAB/BACKSPACE
set tabstop=4                     " a hard TAB displays as 4 columns
set wildmenu                      " enable bash style tab completion
set wildmode=list:longest,full

set autoread
set hidden
set noswapfile nobackup nowritebackup
set nojoinspaces
set pastetoggle=<F3>
set showcmd
set t_Co=256

colorscheme smyck
highlight ColorColumn  ctermbg=16
highlight CursorLine   ctermbg=236
highlight CursorLineNr ctermbg=236 ctermfg=240
highlight SpellBad     ctermbg=0   ctermfg=1
highlight StatusLine   ctermbg=235 ctermfg=2
highlight StatusLineNC ctermbg=235 ctermfg=240
highlight TabLineFill  ctermbg=2   ctermfg=16
highlight VertSplit    ctermbg=2   ctermfg=16

" default cc / tw
set cc=100 tw=0

autocmd FileType html setlocal cc=0
" enable spell checker for mail / commit messages
autocmd BufNewFile,BufRead /tmp/*,COMMIT_EDITMSG setlocal cc=72 tw=72 spell spelllang=en_us

" ctrlp settings
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 0
let g:ctrlp_custom_ignore = 'node_modules\|git\|build\|coverage'

" jsx settings
let g:jsx_ext_required = 0
