# Shared helpers, sourced by install.sh, link.sh and every setup/*.sh.

set -euo pipefail

# cloud-init runs scripts with no HOME set, which breaks every "$HOME/..."
# under `set -u`. Pin it before anything uses it.
export HOME="${HOME:-/root}"
export DEBIAN_FRONTEND=noninteractive

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="$HOME/ctf-venv"

log()  { printf '\033[1;34m[*]\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m[+]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
