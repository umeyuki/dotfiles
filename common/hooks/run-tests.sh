#!/bin/bash
# Claude Code Hook: Auto-run tests after file edit
# PostToolUse: Edit|Write|MultiEdit で実行
# TDD (Test-Driven Development) をサポートする自動テスト実行フック

set -e

# デバッグログ設定
DEBUG_LOG="$HOME/.claude/tdd-debug.log"
mkdir -p "$(dirname "$DEBUG_LOG")"

# ログ関数
log_debug() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$DEBUG_LOG"
}

# .env.localから環境変数を読み込み
if [ -f "$HOME/.env.local" ]; then
    export $(grep -v '^#' "$HOME/.env.local" | xargs)
fi

# 通知設定（環境変数で制御）
ENABLE_TDD_NOTIFICATIONS="${ENABLE_TDD_NOTIFICATIONS:-false}"
NOTIFY_ON_SUCCESS="${NOTIFY_ON_SUCCESS:-false}"
NOTIFY_ON_FAILURE="${NOTIFY_ON_FAILURE:-true}"

# Pushover通知関数
notify_pushover() {
    local title="$1"
    local message="$2"
    
    # 通知が無効な場合はスキップ
    if [ "$ENABLE_TDD_NOTIFICATIONS" != "true" ]; then
        return
    fi
    
    # notify-pushover.shを使用
    if [ -x "$HOME/.claude/hooks/notify-pushover.sh" ]; then
        echo "$message" | "$HOME/.claude/hooks/notify-pushover.sh" "$title"
    fi
}

# 連続実行制御用のロックファイル
LOCK_DIR="$HOME/.claude/hooks/locks"
mkdir -p "$LOCK_DIR"

# 入力JSONを読み取り
input_data=$(cat)
tool_name=$(echo "$input_data" | jq -r '.tool_name // ""')

log_debug "Hook triggered: tool_name=$tool_name"

# ファイル編集系ツールのみ対象
case "$tool_name" in
    "Edit"|"MultiEdit"|"Write")
        ;;
    *)
        log_debug "Skipping: tool is not Edit/MultiEdit/Write"
        exit 0
        ;;
esac

# 編集されたファイルパスを取得
file_path=$(echo "$input_data" | jq -r '.file_path // ""')

log_debug "File edited: $file_path"

# ファイルパスが取得できない場合は終了
if [ -z "$file_path" ]; then
  log_debug "No file path found in input"
  exit 0
fi

# テストまたはソースファイルかチェック
if [[ ! "$file_path" =~ \.(js|ts|jsx|tsx|rb|py|go)$ ]] && [[ ! "$file_path" =~ (test|spec)\. ]]; then
  log_debug "File is not a test or source file"
  exit 0
fi

# 連続実行制御（5秒以内の同一ファイル編集は無視）
LOCK_FILE="$LOCK_DIR/$(echo "$file_path" | tr '/' '_').lock"
if [ -f "$LOCK_FILE" ]; then
    last_run=$(cat "$LOCK_FILE")
    current_time=$(date +%s)
    if [ $((current_time - last_run)) -lt 5 ]; then
        log_debug "Skipping test run: last run was less than 5 seconds ago"
        exit 0
    fi
fi
date +%s > "$LOCK_FILE"

# プロジェクトルートを検索（package.json、Gemfile、deno.json が存在する場所）
PROJECT_ROOT=$(pwd)
while [ "$PROJECT_ROOT" != "/" ]; do
  if [ -f "$PROJECT_ROOT/package.json" ] || [ -f "$PROJECT_ROOT/Gemfile" ] || [ -f "$PROJECT_ROOT/deno.json" ] || [ -f "$PROJECT_ROOT/pyproject.toml" ] || [ -f "$PROJECT_ROOT/requirements.txt" ]; then
    break
  fi
  PROJECT_ROOT=$(dirname "$PROJECT_ROOT")
done

# プロジェクトルートに移動
cd "$PROJECT_ROOT" || exit 0

log_debug "Project root: $PROJECT_ROOT"

echo "🧪 TDD Hook: ファイル編集を検出しました: $file_path" >&2
echo "📂 プロジェクトルート: $PROJECT_ROOT" >&2

# TDDフェーズの管理
TDD_PHASE="${TDD_PHASE:-Red}"
log_debug "TDD Phase: $TDD_PHASE"

# プロジェクトタイプに基づいてテストを実行
test_result=0
test_command=""

if [ -f "package.json" ]; then
  # Node.js プロジェクト
  if command -v npm &> /dev/null && grep -q '"test"' package.json; then
    test_command="npm test"
    echo "🚀 Node.js プロジェクトのテストを実行中..." >&2
    log_debug "Running: $test_command"
    npm test || test_result=$?
  fi
elif [ -f "deno.json" ] || [ -f "deno.jsonc" ]; then
  # Deno プロジェクト
  if command -v deno &> /dev/null; then
    test_command="deno test"
    echo "🦕 Deno プロジェクトのテストを実行中..." >&2
    log_debug "Running: $test_command"
    deno test || test_result=$?
  fi
elif [ -f "Gemfile" ]; then
  # Ruby プロジェクト
  if command -v bundle &> /dev/null; then
    echo "💎 Ruby プロジェクトのテストを実行中..." >&2
    if bundle exec rspec 2>/dev/null; then
      test_command="bundle exec rspec"
    elif bundle exec rake test 2>/dev/null; then
      test_command="bundle exec rake test"
    elif bundle exec ruby -I test test/ 2>/dev/null; then
      test_command="bundle exec ruby -I test test/"
    else
      test_result=1
    fi
    log_debug "Running: $test_command"
  fi
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  # Python プロジェクト
  if command -v python &> /dev/null; then
    echo "🐍 Python プロジェクトのテストを実行中..." >&2
    if python -m pytest 2>/dev/null; then
      test_command="python -m pytest"
    elif python -m unittest discover 2>/dev/null; then
      test_command="python -m unittest discover"
    else
      test_result=1
    fi
    log_debug "Running: $test_command"
  fi
elif [ -f "go.mod" ]; then
  # Go プロジェクト
  if command -v go &> /dev/null; then
    test_command="go test ./..."
    echo "🐹 Go プロジェクトのテストを実行中..." >&2
    log_debug "Running: $test_command"
    go test ./... || test_result=$?
  fi
fi

# テスト結果に基づいてフィードバック
if [ $test_result -ne 0 ]; then
  log_debug "Test failed with exit code: $test_result"
  
  echo "" >&2
  echo "❌ テストが失敗しました！" >&2
  echo "" >&2
  
  if [ "$TDD_PHASE" = "Red" ]; then
    echo "💡 TDD サイクル: Red フェーズ" >&2
    echo "   失敗するテストが書けました。次は実装を追加してテストを通しましょう。" >&2
  else
    echo "💡 TDD サイクル: Red → Green" >&2
    echo "   失敗したテストを確認し、テストが通るように実装を修正してください。" >&2
  fi
  echo "" >&2
  
  # Pushover通知（失敗時）
  if [ "$NOTIFY_ON_FAILURE" = "true" ]; then
    notify_pushover "TDD: テスト失敗 ❌" "テストが失敗しました: $(basename $file_path)"
  fi
  
  # TDDフェーズを更新
  export TDD_PHASE="Green"
  
  # exit code 2 で Claudeに自動フィードバック
  exit 2
else
  log_debug "All tests passed"
  
  echo "" >&2
  echo "✅ すべてのテストが成功しました！" >&2
  echo "" >&2
  
  if [ "$TDD_PHASE" = "Green" ]; then
    echo "💡 TDD サイクル: Green → Refactor" >&2
    echo "   テストが通りました！コードの品質を改善するリファクタリングを検討してください。" >&2
    export TDD_PHASE="Refactor"
  elif [ "$TDD_PHASE" = "Refactor" ]; then
    echo "💡 TDD サイクル: Refactor フェーズ" >&2
    echo "   リファクタリング後もテストが通っています。次の機能に進みましょう。" >&2
    export TDD_PHASE="Red"
  else
    echo "💡 TDD サイクル: 継続中" >&2
    echo "   次のテストケースを追加して、Red-Green-Refactorサイクルを続けましょう。" >&2
  fi
  echo "" >&2
  
  # Pushover通知（成功時）
  if [ "$NOTIFY_ON_SUCCESS" = "true" ]; then
    notify_pushover "TDD: テスト成功 ✅" "すべてのテストが成功しました: $(basename $file_path)"
  fi
fi

# クリーンアップ（古いロックファイルを削除）
find "$LOCK_DIR" -type f -name "*.lock" -mmin +10 -delete 2>/dev/null || true

log_debug "Hook completed"
exit 0