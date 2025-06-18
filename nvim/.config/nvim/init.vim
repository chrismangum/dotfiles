call plug#begin('~/.local/share/nvim/site/plugged')
" Plugins
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'kien/ctrlp.vim'
" Syntax
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
call plug#end()

set cc=79
set cursorline
set guicursor=
set ignorecase smartcase
set number
set t_Co=256

" Indentation
set expandtab
set shiftwidth=2

" Colors
colorscheme smyck
highlight ColorColumn  ctermbg=16
highlight CursorLine   ctermbg=236 cterm=NONE
highlight CursorLineNr ctermbg=236 ctermfg=240
highlight StatusLine   ctermbg=235 ctermfg=2
highlight StatusLineNC ctermbg=235 ctermfg=240
highlight TabLineFill  ctermbg=2   ctermfg=16

let g:ctrlp_custom_ignore = {
  \ 'dir':  'node_modules\|\.git\|dist\|coverage\|build\|target',
  \ }
