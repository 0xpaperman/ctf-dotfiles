#!/usr/bin/env bash
# vim-plug and plugins. Neovim shares ~/.vim and ~/.vimrc (see
# home/.config/nvim/init.vim), so one install serves both editors.
source "$(dirname "$0")/../lib/common.sh"

log "Installing vim-plug + plugins"
curl -fsSL --create-dirs -o "$HOME/.vim/autoload/plug.vim" \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim -es -u "$HOME/.vimrc" -i NONE -c "PlugInstall --sync" -c "qa" >/dev/null 2>&1 || true
[ -d "$HOME/.vim/plugged/vim-surround" ] || { warn "PlugInstall failed - run :PlugInstall in vim"; exit 1; }
ok "vim-surround installed"
