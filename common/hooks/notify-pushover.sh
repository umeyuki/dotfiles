#!/bin/bash
TITLE="$1"
MESSAGE="$2"

# デバッグログ
DEBUG_LOG="$HOME/.claude/pushover-debug.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Title: '$TITLE', Message: '$MESSAGE'" >> "$DEBUG_LOG"

# メッセージが空の場合のデフォルト処理
if [ -z "$MESSAGE" ]; then
    MESSAGE="通知（詳細なし）"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: Empty message, using default" >> "$DEBUG_LOG"
fi

# 意味のない通知をフィルタリング
if [ "$TITLE" = "Claude" ] && [ "$MESSAGE" = "Claude" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SKIP: Filtering out meaningless notification" >> "$DEBUG_LOG"
    exit 0
fi

# 重複通知の制御（5秒以内の同じ通知は無視）
NOTIFICATION_HASH=$(echo "${TITLE}${MESSAGE}" | md5sum | cut -d' ' -f1)
NOTIFICATION_LOCK="/tmp/pushover-${NOTIFICATION_HASH}.lock"

if [ -f "$NOTIFICATION_LOCK" ]; then
    last_sent=$(cat "$NOTIFICATION_LOCK")
    current_time=$(date +%s)
    if [ $((current_time - last_sent)) -lt 5 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] SKIP: Duplicate notification within 5 seconds" >> "$DEBUG_LOG"
        exit 0
    fi
fi
date +%s > "$NOTIFICATION_LOCK"

# より具体的なタイトルを生成
generate_specific_title() {
    local original_title="$1"
    local message="$2"
    
    # メッセージの内容に応じてタイトルを調整
    if [[ "$message" =~ "承認" || "$message" =~ "approval" ]]; then
        echo "Claude: 承認が必要です"
    elif [[ "$message" =~ "エラー" || "$message" =~ "error" ]]; then
        echo "Claude: エラーが発生しました"
    elif [[ "$message" =~ "完了" || "$message" =~ "complete" ]]; then
        echo "Claude: 作業が完了しました"
    elif [[ "$message" =~ "テスト" || "$message" =~ "test" ]]; then
        echo "Claude: テスト結果"
    elif [[ "$message" =~ "ファイル編集" || "$message" =~ "edit" ]]; then
        echo "Claude: ファイル編集検出"
    else
        echo "Claude: $original_title"
    fi
}

# 具体的なタイトルを生成
SPECIFIC_TITLE=$(generate_specific_title "$TITLE" "$MESSAGE")

# Load environment variables from .env.local if it exists
if [ -f "$HOME/.env.local" ]; then
    export $(grep -v '^#' "$HOME/.env.local" | xargs)
fi

# Use environment variables or defaults from .env.local
PUSHOVER_USER_KEY="${PUSHOVER_USER_KEY:-}"
PUSHOVER_APP_TOKEN="${PUSHOVER_APP_TOKEN:-}"

if [ -z "$PUSHOVER_USER_KEY" ] || [ -z "$PUSHOVER_APP_TOKEN" ]; then
    echo "Error: PUSHOVER_USER_KEY or PUSHOVER_APP_TOKEN not set"
    echo "Please set them in ~/.env.local file with the following format:"
    echo "PUSHOVER_USER_KEY=your-user-key"
    echo "PUSHOVER_APP_TOKEN=your-app-token"
    exit 1
fi

curl -s \
  --form-string "token=${PUSHOVER_APP_TOKEN}" \
  --form-string "user=${PUSHOVER_USER_KEY}" \
  --form-string "title=${SPECIFIC_TITLE}" \
  --form-string "message=${MESSAGE}" \
  --form-string "sound=pushover" \
  https://api.pushover.net/1/messages.json > /dev/null

if [ $? -eq 0 ]; then
    echo "Notification sent successfully"
else
    echo "Failed to send notification"
fi