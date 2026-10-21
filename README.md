# ctf-dotfiles

Turns a fresh Ubuntu 24.04 box into a CTF machine: pwntools, pwndbg,
ROPgadget, one_gadget, radare2, plus my zsh, tmux, vim/neovim and gdb configs.

The `ctf` CLI clones this repo onto each new droplet and runs `install.sh`.

## Layout

```
install.sh      link configs, then run every setup/*.sh in order
link.sh         symlink everything under home/ into ~
packages.txt    apt packages, one per line
setup/          one script per concern, run in filename order
  10-packages.sh    apt packages from packages.txt
  15-locale.sh      UTF-8 locales
  20-python.sh      ~/ctf-venv with pwntools and friends
  30-pwndbg.sh      pwndbg
  40-ruby.sh        one_gadget, seccomp-tools
  50-editors.sh     vim-plug and plugins (shared by vim and neovim)
  60-shell.sh       zsh as login shell, ~/ctf
  90-verify.sh      checks the result
home/           mirrored into ~ as symlinks
lib/common.sh   helpers shared by all of the above
```

## Usage

On a fresh box, as root:

```bash
git clone https://github.com/<you>/ctf-dotfiles ~/dotfiles
~/dotfiles/install.sh
```

Rerun particular steps by number:

```bash
~/dotfiles/install.sh 30 40       # just pwndbg and the ruby tools
```

Every script is safe to rerun. Modules don't stop each other: if one fails,
the rest still run, and the summary at the end says what to rerun.

## Changing things

Configs in `home/` are symlinked, so pulling new commits changes them on the
box immediately. From the Mac:

```bash
# edit, commit, push, then:
ctf sync            # git pull on the box, link any new files
ctf sync 50         # ...and rerun setup/50-editors.sh
```

- **Add a package:** a line in `packages.txt`.
- **Add a config file:** put it under `home/` at the path it should have
  relative to `~`. `link.sh` picks it up.
- **Add a setup step:** a new `setup/NN-name.sh`. Start it with
  `source "$(dirname "$0")/../lib/common.sh"`, and keep it safe to rerun.

## Notes

- `~/.gdbinit` belongs to this repo. pwndbg is installed with `--update` so
  its installer doesn't append to it; the repo's file loads pwndbg itself,
  and only if it's installed.
- There is deliberately no `v` (paste) command in `.zshrc`. See the comment
  there for why.
- This repo is public. Don't commit anything secret to it.
