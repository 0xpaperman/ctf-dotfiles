set mouse=a
if !has('nvim')
  set ttymouse=sgr      " Vim only; Neovim handles mouse encoding itself
endif
set number
set relativenumber
xnoremap <space>p "_dP
set virtualedit=onemore
nnoremap $ g$

" Reduce ESC delay (like zsh KEYTIMEOUT)
set timeoutlen=300
set ttimeoutlen=5

" Cursor styles: beam in insert, block in normal.
" Vim only -- Neovim already does this by default (see :h guicursor).
if !has('nvim')
  let &t_SI = "\e[6 q"
  let &t_EI = "\e[2 q"
  autocmd VimLeave * silent !printf "\e[2 q"
endif

" Move around in Insert mode with Ctrl + hjkl
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>

" Plugins (vim-plug is installed by setup/50-editors.sh)
if filereadable(expand('~/.vim/autoload/plug.vim'))
  call plug#begin('~/.vim/plugged')
  Plug 'tpope/vim-surround'
  call plug#end()
endif

" Handy for reading hexdumps / raw payloads
set backspace=indent,eol,start
syntax on
