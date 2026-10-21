#!/usr/bin/env bash
# Python venv with pwntools and friends. ~/.zshrc activates it on login.
source "$(dirname "$0")/../lib/common.sh"

if [ ! -d "$VENV" ]; then
  log "Creating Python venv at ~/ctf-venv"
  python3 -m venv "$VENV"
fi

log "Installing Python packages"
"$VENV/bin/pip" install --quiet --upgrade pip || warn "pip self-upgrade failed"
"$VENV/bin/pip" install --quiet \
  pwntools ropper angr requests pycryptodome z3-solver ropgadget pwninit-py
ok "pwntools $("$VENV/bin/python" -c 'import pwnlib; print(pwnlib.__version__)') installed"
