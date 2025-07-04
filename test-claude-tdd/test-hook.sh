#!/bin/bash
# Claude Code Hooksの動作確認スクリプト

echo "🧪 Claude Code Hooks動作確認を開始します..."

# テスト用のJSONデータを作成
test_edit_json() {
    cat << EOF
{
  "tool_name": "Edit",
  "file_path": "/home/umeyuki/dotfiles/test-claude-tdd/index.js"
}
EOF
}

# フックスクリプトを直接実行
echo "📝 Editツールのシミュレーション..."
test_edit_json | ~/.claude/hooks/run-tests.sh

echo ""
echo "✅ 動作確認完了"
echo ""
echo "📋 確認項目:"
echo "1. デバッグログを確認: tail -f ~/.claude/tdd-debug.log"
echo "2. テストが実行されたか確認"
echo "3. 通知設定が有効な場合、Pushover通知が送信されたか確認"