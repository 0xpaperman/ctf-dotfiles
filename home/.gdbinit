# ~/.gdbinit
#
# Owned by the dotfiles repo. setup/30-pwndbg.sh installs pwndbg with
# --update, which tells pwndbg's installer not to append to this file.

set disassembly-flavor intel

# finishn N -- run until N frames have returned (finishn 1 == finish)
define finishn
  select-frame $arg0 - 1
  finish
end

# Load pwndbg only if it's installed. A plain `source` of a missing file
# would abort the rest of this file, so guard it -- and keep it last.
python
import os
_pwndbg = os.path.expanduser("~/pwndbg/gdbinit.py")
if os.path.exists(_pwndbg):
    gdb.execute("source " + _pwndbg)
end
