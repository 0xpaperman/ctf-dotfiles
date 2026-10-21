#!/usr/bin/env bash
# zsh as the login shell, and the working directory.
source "$(dirname "$0")/../lib/common.sh"

mkdir -p "$HOME/ctf"
ok "~/ctf ready"

if [ "$(getent passwd root | cut -d: -f7)" != "/usr/bin/zsh" ]; then
  chsh -s /usr/bin/zsh root 2>/dev/null || usermod -s /usr/bin/zsh root
  ok "login shell set to zsh (takes effect next login)"
else
  ok "login shell already zsh"
fi
