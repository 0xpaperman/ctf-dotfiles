#!/usr/bin/env bash
# Set up a fresh Ubuntu box as a CTF machine.
#
#   ./install.sh            link configs, then run every setup/*.sh in order
#   ./install.sh 30 50      run only the modules starting with 30 and 50
#
# Modules are independent: one failing doesn't stop the rest, and the
# summary at the end lists anything that needs a rerun.
source "$(dirname "$0")/lib/common.sh"

[ "$(id -u)" -eq 0 ] || { echo "Run as root."; exit 1; }

# Configs first: later steps read them (vim-plug reads ~/.vimrc, and
# pwndbg must find the repo's ~/.gdbinit already in place).
bash "$DOTFILES/link.sh"

failed=()
for module in "$DOTFILES"/setup/*.sh; do
  name="$(basename "$module")"
  if [ $# -gt 0 ]; then
    match=0
    for want in "$@"; do [[ "$name" == "$want"* ]] && match=1; done
    [ "$match" -eq 1 ] || continue
  fi
  echo
  bash "$module" || failed+=("$name")
done

echo
if [ ${#failed[@]} -eq 0 ]; then
  ok "setup complete"
else
  warn "setup finished with failures: ${failed[*]}"
  warn "rerun just those with: ./install.sh $(printf '%s ' "${failed[@]%%-*}")"
  exit 1
fi
