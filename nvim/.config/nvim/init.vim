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
" Colorschemes
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'folke/tokyonight.nvim', { 'as': 'tokyonight' }
Plug 'rebelot/kanagawa.nvim', { 'as': 'kanagawa' }
call plug#end()

" Disable Mouse
set mouse=

set cc=79
set cursorline
set guicursor=
set ignorecase smartcase
set number
set t_Co=256

" 2 Spaces Indentation
set expandtab
set shiftwidth=2

" Tab Indentation
" set tabstop=4
" set shiftwidth=4

" Colors
colorscheme smyck

autocmd VimResume,BufEnter * checktime

let g:ctrlp_custom_ignore = {
  \ 'dir':  'node_modules\|\.git\|dist\|coverage\|build\|target',
  \ }
