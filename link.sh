#!/usr/bin/env bash
# Symlink every file under home/ into ~, mirroring the directory layout.
# Existing real files are moved aside to <name>.bak.<timestamp> first.
# Safe to run repeatedly.
source "$(dirname "$0")/lib/common.sh"

stamp="$(date +%Y%m%d-%H%M%S)"
linked=0

while IFS= read -r -d '' src; do
  rel="${src#"$DOTFILES/home/"}"
  dst="$HOME/$rel"
  mkdir -p "$(dirname "$dst")"

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    continue                                   # already correct
  fi
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak.$stamp"
    warn "backed up existing ~/$rel to ~/$rel.bak.$stamp"
  fi
  ln -sfn "$src" "$dst"
  linked=$((linked + 1))
done < <(find "$DOTFILES/home" -type f -print0)

ok "configs linked ($linked new or changed)"
