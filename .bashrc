 # ~/.bashrc - minimal, asdf-based, Claude Code friendly

# 対話シェルでなければ抜ける
case $- in *i*) ;; *) return ;; esac

# ───── 基本設定 ─────
shopt -s histappend       # 履歴を追記モードに
export HISTSIZE=9999
export HISTCONTROL=ignoreboth:erasedups
umask 022
export LANG=ja_JP.UTF-8
export LESSCHARSET=utf-8
export PAGER=less
export EDITOR=vim

# ───── PATH・ツール管理 ─────
export GOPATH="$HOME/dev"
export BUN_INSTALL="$HOME/.bun"
export ASDF_DATA_DIR="$HOME/.asdf"

export PATH="$HOME/.asdf/shims:$HOME/.asdf/bin:$BUN_INSTALL/bin:$GOPATH/bin/flutter/bin:/usr/local/go/bin:$PATH"

# asdf初期化（Node.js, Ruby, etc 管理統一）
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"

[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"

# ───── プロンプト（軽量版）─────
PS1='\w\$ '

# ───── 基本alias ─────
alias ls='ls --color=auto'
alias ll='ls -alF'
alias grep='grep --color=auto'
alias pbcopy='win32yank.exe -i'
alias open='explorer.exe'
alias setup='sudo sysctl -w vm.max_map_count=262144; sudo ntpdate 1.ro.pool.ntp.org;'

# peco + Git連携
alias pco='git checkout $(git branch | peco)'
alias pcd='cd $(ghq list -p | peco)'

# peco履歴検索（Ctrl-r）
function peco-select-history() {
  local tac
  which gtac &> /dev/null && tac="gtac" || which tac &> /dev/null && tac="tac" || tac="tail -r"
  READLINE_LINE=$(HISTTIMEFORMAT= history | $tac | sed -e 's/^\s*[0-9]\+\s\+//' | awk '!a[$0]++' | peco --query "$READLINE_LINE")
  READLINE_POINT=${#READLINE_LINE}
}
bind -x '"\C-r": peco-select-history'

# bash-completion（オプション）
if ! shopt -oq posix; then
  [ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
  [ -f /etc/bash_completion ] && . /etc/bash_completion
fi

# ~/.bash_aliases があれば読み込み
[ -f ~/.bash_aliases ] && . ~/.bash_aliases


function check_and_suggest_install() {
  local missing=0

  echo -e "\n\033[1;33m[Setup Notice]\033[0m"

  # check peco
  if ! command -v peco >/dev/null; then
    echo -e "Missing tool: \033[1mpeco\033[0m"
    echo "→ Install: sudo apt install peco"
    missing=1
  fi

  # check ghq
  if ! command -v ghq >/dev/null; then
    echo -e "Missing tool: \033[1mghq\033[0m"
    echo "→ Install: go install github.com/x-motemen/ghq@latest"
    missing=1
  fi

  # check asdf
  if [ ! -d "$HOME/.asdf" ]; then
    echo -e "Missing tool: \033[1masdf\033[0m"
    echo "→ Install: git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0"
    missing=1
  fi

  # check deno
  if ! command -v deno >/dev/null && [ ! -f "$HOME/.deno/env" ]; then
    echo -e "Missing tool: \033[1mdeno\033[0m"
    echo "→ Install: curl -fsSL https://deno.land/install.sh | sh"
    missing=1
  fi

  # check go
  if ! command -v go >/dev/null; then
    echo -e "Missing tool: \033[1mGo (golang)\033[0m"
    echo "→ Install: sudo apt install golang"
    missing=1
  fi

  # check bun
  if [ ! -d "$HOME/.bun" ]; then
    echo -e "Missing tool: \033[1mbun\033[0m"
    echo "→ Install: curl -fsSL https://bun.sh/install | bash"
    missing=1
  fi

  # check win32yank
  if ! command -v win32yank.exe >/dev/null && grep -qEi "(microsoft|wsl)" /proc/version 2>/dev/null; then
    echo -e "Missing tool: \033[1mwin32yank (for pbcopy)\033[0m"
    echo "→ Install: curl -Lo win32yank.exe https://github.com/equalsraf/win32yank/releases/download/v0.0.4/win32yank.exe && chmod +x win32yank.exe && mv win32yank.exe ~/.local/bin"
    missing=1
  fi

  if [ "$missing" -eq 0 ]; then
    echo "All essential tools are installed ✅"
  fi
}

check_and_suggest_install
