#!/usr/bin/env bash
# pwndbg. Installed with --update so its installer leaves ~/.gdbinit alone:
# that file belongs to this repo, and loads pwndbg itself.
source "$(dirname "$0")/../lib/common.sh"

# Success is recorded by a marker written only after setup.sh completes, not
# by the directory existing: a run that was killed halfway leaves a partial
# ~/pwndbg behind, and that must be retried rather than skipped forever.
marker="$HOME/pwndbg/.installed-by-dotfiles"
if [ -f "$marker" ]; then
  ok "pwndbg already installed, skipping"
  exit 0
fi

log "Installing pwndbg"
rm -rf "$HOME/pwndbg"
if git clone -q --depth 1 https://github.com/pwndbg/pwndbg "$HOME/pwndbg" \
   && ( cd "$HOME/pwndbg" && ./setup.sh --update ); then
  touch "$marker"
  ok "pwndbg installed"
else
  rm -rf "$HOME/pwndbg"
  warn "pwndbg install failed - gdb still works, just without the plugin"
  exit 1
fi
