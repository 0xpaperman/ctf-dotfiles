#!/usr/bin/env bash
# SSH forwards the client's LC_ALL/LANG. If that locale isn't generated here,
# the shell falls back to POSIX and the prompt's box-drawing characters come
# out as mojibake. Generate the common ones and default to UTF-8.
source "$(dirname "$0")/../lib/common.sh"

log "Configuring UTF-8 locale"
sed -i 's/^# *\(en_AU.UTF-8\|en_US.UTF-8\|en_GB.UTF-8\)/\1/' /etc/locale.gen
locale-gen >/dev/null 2>&1 || warn "locale-gen had errors"
update-locale LANG=C.UTF-8 LC_ALL=
ok "locales generated (en_AU, en_US, en_GB + C.UTF-8)"
