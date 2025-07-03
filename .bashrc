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
if [ -f "$HOME/.asdf/asdf.sh" ]; then
  . "$HOME/.asdf/asdf.sh"
  . "$HOME/.asdf/completions/asdf.bash"
fi

[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"

# ───── プロンプト（軽量版）─────
PS1='\w\$ '

# ───── 基本alias ─────
alias ls='ls --color=auto'
alias ll='ls -alF'
alias grep='grep --color=auto'
alias open='explorer.exe'
alias setup='sudo sysctl -w vm.max_map_count=262144; sudo ntpdate 1.ro.pool.ntp.org;'

# Claude Code dotfiles aliases
alias claude-setup='~/dotfiles/setup.sh'
alias claude-init='~/dotfiles/setup.sh project'

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

  # check required tools
  if ! command -v asdf >/dev/null 2>&1; then
    echo -e "Missing tool: \033[1masdf\033[0m"
    echo "→ Install: git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0"
    missing=1
  fi

  if ! command -v deno >/dev/null 2>&1; then
    echo -e "Missing tool: \033[1mdeno\033[0m"
    echo "→ Install: curl -fsSL https://deno.land/install.sh | sh"
    missing=1
  fi

  if ! command -v bun >/dev/null 2>&1; then
    echo -e "Missing tool: \033[1mbun\033[0m"
    echo "→ Install: curl -fsSL https://bun.sh/install | bash"
    missing=1
  fi

  if ! command -v jq >/dev/null 2>&1; then
    echo -e "Missing tool: \033[1mjq\033[0m"
    echo "→ Install: sudo apt update && sudo apt install -y jq"
    missing=1
  fi

  if ! command -v pcheck >/dev/null 2>&1; then
    echo -e "Missing tool: \033[1mpcheck\033[0m"
    echo "→ Install: deno install -Afg --name pcheck jsr:@mizchi/project-checklist/cli"
    missing=1
  fi

  # check optional tools
  if ! command -v gemini >/dev/null 2>&1; then
    echo -e "Optional tool: \033[1mgemini CLI\033[0m"
    echo "→ Install: npm install -g @google/gemini-cli"
  fi

  if ! command -v peco >/dev/null 2>&1; then
    echo -e "Optional tool: \033[1mpeco\033[0m"
    echo "→ Install: go install github.com/peco/peco/cmd/peco@latest"
  fi


  if [ "$missing" -eq 0 ]; then
    echo "All essential tools are installed ✅"
  fi
}

check_and_suggest_install
