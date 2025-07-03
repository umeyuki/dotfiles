#!/bin/bash
TITLE="$1"
MESSAGE="$2"

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
  --form-string "title=${TITLE}" \
  --form-string "message=${MESSAGE}" \
  --form-string "sound=pushover" \
  https://api.pushover.net/1/messages.json > /dev/null

if [ $? -eq 0 ]; then
    echo "Notification sent successfully"
else
    echo "Failed to send notification"
fi