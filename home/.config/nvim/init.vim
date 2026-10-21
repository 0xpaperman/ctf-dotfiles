" Neovim reuses the Vim setup: same runtime dir, same plugins, same vimrc.
" Edit ~/.vimrc, not this file. Vim-only lines there are wrapped in
" `if !has('nvim')`.
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
