#!/usr/bin/env bash
# System packages from packages.txt.
source "$(dirname "$0")/../lib/common.sh"

# If a package ships a config file that already exists on the box, dpkg stops
# and asks what to do -- which, with no terminal, fails the whole install.
# Answer in advance: keep the existing file. Done via apt.conf so it also
# covers apt calls made by other installers (pwndbg's setup.sh, for one).
cat > /etc/apt/apt.conf.d/90-noninteractive << 'APT'
Dpkg::Options { "--force-confdef"; "--force-confold"; };
APT

# Finish anything a previous interrupted or failed run left half-configured.
dpkg --configure -a >/dev/null 2>&1 || true

log "Installing system packages (the slow part, ~2-3 min)"
mapfile -t pkgs < <(sed -e 's/#.*//' -e 's/[[:space:]]//g' -e '/^$/d' "$DOTFILES/packages.txt")
apt-get update -qq || warn "apt update had errors (bad/unreachable repo?) - continuing anyway"
apt-get install -y -qq "${pkgs[@]}"
ok "apt packages installed (${#pkgs[@]})"
