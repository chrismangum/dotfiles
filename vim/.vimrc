
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
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-surround'
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

" default cc and indentation
set cc=100 tw=0 sw=2 sts=2 ts=2

autocmd FileType javascript,html setlocal sw=4 sts=4 ts=4
autocmd FileType html setlocal cc=0
" enable spell checker for mail / commit messages
autocmd BufNewFile,BufRead /tmp/*,COMMIT_EDITMSG setlocal cc=72 tw=72 spell spelllang=en_us

" ctrlp settings
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 0
let g:ctrlp_custom_ignore = 'node_modules\|git\|build'
