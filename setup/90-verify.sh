#!/usr/bin/env bash
# Check the result. Reports problems rather than failing on the first one.
source "$(dirname "$0")/../lib/common.sh"
set +e

log "Verifying"
check() { local name="$1"; shift; if "$@" >/dev/null 2>&1; then ok "$name"; else warn "$name FAILED"; fi; }

check "zshrc parses"        zsh -n "$HOME/.zshrc"
check "pwntools imports"    "$VENV/bin/python" -c 'import pwnlib'
check "gcc works"           bash -c 'echo "int main(){return 0;}" | gcc -x c - -o /tmp/_t && rm -f /tmp/_t'
check "gdb starts"          gdb -batch -ex quit
check "pwndbg loads"        bash -c 'gdb -batch -ex quit 2>&1 | grep -q "loaded [0-9]* pwndbg commands"'
check "finishn defined"     bash -c 'gdb -batch -ex "help user-defined" 2>&1 | grep -q finishn'
check "vim-surround"        test -d "$HOME/.vim/plugged/vim-surround"
for cmd in one_gadget seccomp-tools fzf nvim r2 tmux; do check "$cmd" command -v "$cmd"; done
