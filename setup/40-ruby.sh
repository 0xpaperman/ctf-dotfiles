#!/usr/bin/env bash
# one_gadget and seccomp-tools.
source "$(dirname "$0")/../lib/common.sh"

log "Installing one_gadget + seccomp-tools"
gem install --silent --no-document one_gadget seccomp-tools
ok "$(one_gadget --version 2>/dev/null || echo one_gadget) installed"
