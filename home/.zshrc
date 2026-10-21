# ~/.zshrc - remote CTF box
#
# Adapted from a local Kali config. Changes made for a headless server:
#   - dropped `source <(fzf --zsh)`  (needs fzf 0.48+, Ubuntu ships 0.44)
#   - dropped `xset r rate`          (no X server)
#   - xclip aliases replaced with OSC 52 (clipboard travels over SSH)
#   - PATH points at /root, not /home/kali; dropped aarch64 zig path
#   - venv activation on the last line

# ------------------------------------------------------------------ locale
# SSH forwards the client's LC_ALL/LANG. If that locale isn't available here,
# zsh falls back to POSIX and every \uXXXX escape below dies with "character
# not in range", taking the prompt with it. Force something sane first.
if [[ "$(locale charmap 2>/dev/null)" != "UTF-8" ]]; then
    export LC_ALL=C.UTF-8
    export LANG=C.UTF-8
fi

# ---------------------------------------------------------------- fzf history
# Reads the history file directly and strips zsh timestamps.
fzf-history-widget() {
  local selected
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null

  selected=$(
    tac ~/.zsh_history 2>/dev/null | \
    sed 's/^: [0-9]*:[0-9]*;//' | \
    awk '!seen[$0]++' | \
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore --scheme=history --bind=ctrl-r:toggle-sort ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m" \
    FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd)
  )

  local ret=$?
  if [ -n "$selected" ]; then
    LBUFFER="$selected"
  fi
  zle reset-prompt
  return $ret
}

__fzfcmd() {
  [ -n "${TMUX_PANE-}" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "${FZF_TMUX_OPTS-}" ]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

zle -N fzf-history-widget
# NOTE: the actual `bindkey '^F'` lives further down, *after* `bindkey -v`.
# Binding it here as well would be pointless: switching to the vi keymap
# discards bindings made against the previous one.

# ------------------------------------------------------------------- options
setopt autocd              # change directory just by typing its name
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # filename expansion for anything=expression
setopt nonomatch           # no error if a glob doesn't match
setopt notify              # report background job status immediately
setopt numericglobsort     # sort filenames numerically when sensible
setopt promptsubst         # command substitution in prompt

WORDCHARS=${WORDCHARS//\/}
PROMPT_EOL_MARK=""

# -------------------------------------------------------------- vi keybinds
bindkey -v
export KEYTIMEOUT=1
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char

autoload -U edit-command-line
zle -N edit-command-line
bindkey -M viins '^E' edit-command-line
bindkey -M vicmd '^E' edit-command-line

export EDITOR=vim
export VISUAL=vim

bindkey ' ' magic-space
bindkey '^U' backward-kill-line
bindkey '^[[3;5~' kill-word
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[5~' beginning-of-buffer-or-history
bindkey '^[[6~' end-of-buffer-or-history
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[Z' undo

# fzf history search - must come after `bindkey -v` or the vi keymap eats it
bindkey -M viins '^F' fzf-history-widget
bindkey -M vicmd '^F' fzf-history-widget

bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^[^?' backward-kill-word
bindkey -M viins '^[^[[3~' kill-word
bindkey -M viins '^R' redo
bindkey -M vicmd '^R' redo

# ------------------------------------------------------------- completion
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# ---------------------------------------------------------------- history
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt INC_APPEND_HISTORY      # write immediately, so fzf sees it
unsetopt SHARE_HISTORY         # but don't auto-import between panes
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
alias history="history 0"

# Arrow keys walk per-pane history; ^F (fzf) searches everything.
up-line-or-local-history() {
    zle set-local-history 1
    zle up-line-or-history
    zle set-local-history 0
}
zle -N up-line-or-local-history

down-line-or-local-history() {
    zle set-local-history 1
    zle down-line-or-history
    zle set-local-history 0
}
zle -N down-line-or-local-history

bindkey '^[[A' up-line-or-local-history
bindkey '^[OA' up-line-or-local-history
bindkey '^[[B' down-line-or-local-history
bindkey '^[OB' down-line-or-local-history

TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'

# ----------------------------------------------------------------- prompt
force_color_prompt=yes
color_prompt=
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    fi
fi

configure_prompt() {
    prompt_symbol=$'\u327f'
    case "$PROMPT_ALTERNATIVE" in
        twoline)
            PROMPT=$'%F{%(#.blue.green)}\u250c\u2500\u2500${debian_chroot:+($debian_chroot)\u2500}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))\u2500}(%B%F{%(#.red.blue)}%n'$prompt_symbol$'%m%b%F{%(#.blue.green)})-[%B%F{reset}%(6~.%-1~/\u2026/%4~.%5~)%b%F{%(#.blue.green)}]\n\u2514\u2500%B%(#.%F{red}#.%F{blue}$)%b%F{reset} '
            ;;
        oneline)
            PROMPT=$'${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%B%F{%(#.red.blue)}%n@%m%b%F{reset}:%B%F{%(#.blue.green)}%~%b%F{reset}%(#.#.$) '
            RPROMPT=
            ;;
    esac
    unset prompt_symbol
}

PROMPT_ALTERNATIVE=twoline
NEWLINE_BEFORE_PROMPT=yes

if [ "$color_prompt" = yes ]; then
    VIRTUAL_ENV_DISABLE_PROMPT=1
    configure_prompt

    if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
        . /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
        ZSH_HIGHLIGHT_STYLES[default]=none
        ZSH_HIGHLIGHT_STYLES[unknown-token]=underline
        ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
        ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[global-alias]=fg=green,bold
        ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[path]=bold
        ZSH_HIGHLIGHT_STYLES[path_pathseparator]=
        ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
        ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[command-substitution]=none
        ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[process-substitution]=none
        ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=green
        ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=green
        ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
        ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=magenta
        ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[assign]=none
        ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[comment]=fg=white
        ZSH_HIGHLIGHT_STYLES[named-fd]=none
        ZSH_HIGHLIGHT_STYLES[numeric-fd]=none
        ZSH_HIGHLIGHT_STYLES[arg0]=fg=cyan
        ZSH_HIGHLIGHT_STYLES[bracket-error]=fg=red,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-1]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-2]=fg=green,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-3]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-4]=fg=yellow,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-5]=fg=cyan,bold
        ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]=standout
    fi
else
    PROMPT='%n@%m:%~%(#.#.$) '
fi
unset color_prompt force_color_prompt

toggle_oneline_prompt(){
    if [ "$PROMPT_ALTERNATIVE" = oneline ]; then
        PROMPT_ALTERNATIVE=twoline
    else
        PROMPT_ALTERNATIVE=oneline
    fi
    configure_prompt
    zle reset-prompt
}
zle -N toggle_oneline_prompt
bindkey ^P toggle_oneline_prompt

case "$TERM" in
xterm*|rxvt*|Eterm|aterm|kterm|gnome*|alacritty|xterm-ghostty)
    TERM_TITLE=$'\e]0;${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%n@%m: %~\a'
    ;;
*)
    TERM_TITLE=''
    ;;
esac

precmd() {
    print -Pnr -- "$TERM_TITLE"
    if [ "$NEWLINE_BEFORE_PROMPT" = yes ]; then
        if [ -z "$_NEW_LINE_BEFORE_PROMPT" ]; then
            _NEW_LINE_BEFORE_PROMPT=1
        else
            print ""
        fi
    fi
}

# ------------------------------------------------------------------ colors
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export LS_COLORS="$LS_COLORS:ow=30;44:"

    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'

    export LESS_TERMCAP_mb=$'\E[1;31m'
    export LESS_TERMCAP_md=$'\E[1;36m'
    export LESS_TERMCAP_me=$'\E[0m'
    export LESS_TERMCAP_so=$'\E[01;33m'
    export LESS_TERMCAP_se=$'\E[0m'
    export LESS_TERMCAP_us=$'\E[1;32m'
    export LESS_TERMCAP_ue=$'\E[0m'

    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
    zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
fi

alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias b='cd $OLDPWD'

# --------------------------------------------------------------- clipboard
# No X server here, so xclip is out. OSC 52 pushes the clipboard up through
# SSH + tmux to the local terminal. Needs a terminal that supports it:
# Alacritty / Ghostty / Kitty / WezTerm yes, iTerm2 after enabling the
# setting, Terminal.app never.
#
#   cat flag.txt | c        copy to local clipboard
#   ./exploit.py | t        show output AND copy it
#
# There is no `v` (paste). Terminals refuse OSC 52 *reads* for security
# reasons. Use Cmd-V to paste into the terminal, or scp for whole files.
# There is deliberately no `v` (paste). Terminals refuse OSC 52 *reads* for
# security reasons, and the workaround -- a reverse tunnel serving pbpaste
# back to this box -- would let any process here read the Mac's clipboard.
# That's a bad trade on a machine where you run untrusted challenge binaries
# as root. Use Cmd-V to paste into the terminal, or scp for whole files.
c() { printf '\033]52;c;%s\007' "$(base64 -w0)"; }
t() { tee >(c); }

# Copy the previous command to the clipboard.
cpc() { fc -ln -1 | sed 's/^[[:space:]]*//' | c; }

# ----------------------------------------------------------------- helpers
# Quick HTTP server:  up 8000
up() { python3 -m http.server "${1:-8000}"; }

alias urlencode='python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" '
alias urldecode='python3 -c "import urllib.parse, sys; print(urllib.parse.unquote(sys.argv[1]))" '
urlplusencode() { urlencode "$1" | sed 's/%20/+/g'; }

# String -> PowerShell-compatible base64
towinb64() {
    if [ -t 0 ]; then
        echo -n "$1" | iconv -t UTF-16LE | base64 -w 0
    else
        cat | iconv -t UTF-16LE | base64 -w 0
    fi
    echo ""
}

# NetExec output filter: collapse repeated failures
nxc_filter() {
    local N=${1:-5}
    awk -v N="$N" 'BEGIN{attempts=0} /\[\-\]/ {attempts++; if (attempts % N == 0) print $0 " [ATTEMPT " attempts "]"} !/\[\-\]/ {print $0}'
}

# ------------------------------------------------------------------- time
fakertime() {
    local timestr="$1"
    shift

    local hours=$(echo "$timestr" | grep -oP '\d+(?=h)' || echo "0")
    local mins=$(echo "$timestr" | grep -oP '\d+(?=m)' || echo "0")
    local secs=$(echo "$timestr" | grep -oP '\d+(?=s)' || echo "0")

    local total=$((hours * 3600 + mins * 60 + secs))

    local sign=""
    [[ "$timestr" =~ ^- ]] && sign="-" || sign="+"

    faketime -f "${sign}${total}s" "$@"
}

setfakertime() {
    local timestr="$1"
    timedatectl set-ntp false
    echo "[*] Disabling NTP time sync..."
    local offset_time=$(fakertime "$timestr" date '+%Y-%m-%d %H:%M:%S')
    echo "[*] Setting system time to: $offset_time"
    timedatectl set-time "$offset_time"
    echo "[!] Current time: $(date)"
}

timereset() {
    timedatectl set-ntp true
    echo "[*] Re-enabled NTP time sync..."
    echo "[!] Current time: $(date)"
}

alias fkt='fakertime'
alias sfkt='setfakertime'
alias trst='timereset'

# --------------------------------------------------------- text objects
# ci" ci' ci` di" etc
autoload -U select-quoted
zle -N select-quoted
for m in visual viopp; do
        for c_ in {a,i}{\',\",\`}; do
                bindkey -M $m $c_ select-quoted
        done
done

# ci{ ci( ci< di{ etc
autoload -U select-bracketed
zle -N select-bracketed
for m in visual viopp; do
        for c_ in {a,i}${(s..)^:-'()[]{}<>bB'}; do
                bindkey -M $m $c_ select-bracketed
        done
done

# cs ds ys - surround
autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -a cs change-surround
bindkey -a ds delete-surround
bindkey -a ys add-surround
bindkey -M visual S add-surround

# ------------------------------------------------------------- cursor shape
zle-keymap-select () {
  if [[ $KEYMAP == vicmd ]]; then
    echo -ne "\e[2 q"   # block
  else
    echo -ne "\e[5 q"   # bar
  fi
}
zle -N zle-keymap-select

zle-line-init() { echo -ne "\e[5 q"; }
zle -N zle-line-init
echo -ne "\e[5 q"

# ------------------------------------------------------------------- misc
WORDCHARS=${WORDCHARS//[.\/=]}

if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi

# ------------------------------------------------------------------- PATH
export PATH=/root/.local/bin:$PATH
[ -d ~/go/bin ] && export PATH=$PATH:~/go/bin

# ---------------------------------------------------- venv (keep this last)
# Last line on purpose: activate prepends to PATH, and anything that
# prepends after it would shadow the venv's python3.
source ~/ctf-venv/bin/activate
