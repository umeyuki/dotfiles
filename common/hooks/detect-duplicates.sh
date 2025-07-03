#!/bin/bash
# Claude Code Hook: 重複コード検出
# PostToolUse: Edit|Write|MultiEdit で実行

set -e

# 入力JSONを読み取り
input_data=$(cat)
tool_name=$(echo "$input_data" | jq -r '.tool_name // ""')

# ファイル編集系ツールのみ対象
case "$tool_name" in
    "Edit"|"MultiEdit"|"Write")
        ;;
    *)
        exit 0
        ;;
esac

# TypeScript/JavaScript プロジェクトかチェック
if [ ! -f "package.json" ] && [ ! -f "tsconfig.json" ] && [ ! -f "deno.json" ]; then
    exit 0
fi

# similarity-ts がインストールされているかチェック
if ! command -v similarity-ts >/dev/null 2>&1; then
    exit 0
fi

# 重複コード検出実行
similarity_output=$(similarity-ts . --threshold 0.85 --min-lines 5 --cross-file 2>/dev/null || true)

# 重複が見つかった場合、Claudeにフィードバック
if [ -n "$similarity_output" ] && echo "$similarity_output" | grep -q "Duplicates in"; then
    echo "🔍 重複コードが検出されました。以下の結果を確認してリファクタリングを検討してください：" >&2
    echo "" >&2
    echo "$similarity_output" >&2
    echo "" >&2
    echo "💡 推奨アクション: similarity-ts の結果を分析して、共通関数の抽出やコードの統合を検討してください。" >&2
    
    # exit code 2 で Claudeに自動フィードバック
    exit 2
fi

exit 0