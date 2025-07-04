# Claude Code Hooks TDD トラブルシューティングガイド

## 一般的な問題と解決方法

### 1. テストが自動実行されない

#### 症状
ファイルを編集してもテストが自動的に実行されない

#### 原因と解決方法

1. **設定ファイルの確認**
   ```bash
   cat ~/.claude/settings.json
   ```
   PostToolUseフックが正しく設定されているか確認

2. **スクリプトの実行権限**
   ```bash
   chmod +x ~/.claude/hooks/run-tests.sh
   ls -la ~/.claude/hooks/run-tests.sh
   ```

3. **jqコマンドの確認**
   ```bash
   which jq
   # インストールされていない場合
   # macOS: brew install jq
   # Linux: sudo apt-get install jq
   ```

### 2. デバッグログの確認方法

#### ログファイルの場所
```bash
tail -f ~/.claude/tdd-debug.log
```

#### ログの内容
- Hook triggered: フックが呼び出されたかどうか
- File edited: 編集されたファイルパス
- Project root: 検出されたプロジェクトルート
- Running: 実行されたテストコマンド
- Test result: テストの結果

### 3. Pushover通知が表示されない

#### 症状
テスト実行後にPushover通知が送信されない

#### 解決方法
1. **環境変数の設定確認**
   ```bash
   cat ~/.env.local
   ```
   以下の設定が必要です:
   - `PUSHOVER_USER_KEY`: Pushoverのユーザーキー
   - `PUSHOVER_APP_TOKEN`: Pushoverのアプリトークン
   - `ENABLE_TDD_NOTIFICATIONS=true`: TDD通知を有効化

2. **通知設定のカスタマイズ**
   ```bash
   # ~/.env.localに追加
   ENABLE_TDD_NOTIFICATIONS=true  # 通知を有効化
   NOTIFY_ON_SUCCESS=false        # 成功時は通知しない（推奨）
   NOTIFY_ON_FAILURE=true         # 失敗時のみ通知（推奨）
   ```

3. **手動テスト**
   ```bash
   echo "テストメッセージ" | ~/.claude/hooks/notify-pushover.sh "テスト"
   ```

4. **理想的な通知設定**
   - テスト失敗時のみ通知することで、重要な情報に集中できます
   - 成功時の通知は無効にすることで、通知疲れを防げます

### 4. 連続実行制御の問題

#### 症状
同じファイルを短時間で何度も編集してもテストが1回しか実行されない

#### 解決方法
- 5秒以上待ってから再度編集
- ロックファイルの手動削除:
  ```bash
  rm ~/.claude/hooks/locks/*.lock
  ```

### 5. テストコマンドが見つからない

#### 各言語のテストツール確認

**Node.js/JavaScript**
```bash
npm --version
# package.jsonにtestスクリプトがあるか確認
grep '"test"' package.json
```

**Python**
```bash
python -m pytest --version
# または
python -m unittest --version
```

**Go**
```bash
go version
```

**Ruby**
```bash
bundle --version
rspec --version
```

### 6. プロジェクトルートが正しく検出されない

#### 症状
テストが違うディレクトリで実行される

#### 解決方法
プロジェクトルートに以下のファイルのいずれかが存在することを確認:
- `package.json` (Node.js)
- `deno.json` または `deno.jsonc` (Deno)
- `Gemfile` (Ruby)
- `requirements.txt` または `pyproject.toml` (Python)
- `go.mod` (Go)

### 7. Claude Code Hooksの再読み込み

設定を変更した後、新しいClaude Codeセッションを開始する必要があります。

### 8. 手動でのテスト実行

自動実行が機能しない場合の各言語でのテスト実行方法:

```bash
# Node.js
npm test

# Python
python -m pytest
# または
python -m unittest discover

# Go
go test ./...

# Ruby
bundle exec rspec
```

### 9. 環境変数の設定

TDDフェーズを手動で設定する場合:
```bash
export TDD_PHASE=Red   # Red Phase
export TDD_PHASE=Green # Green Phase
export TDD_PHASE=Refactor # Refactor Phase
```

### 10. よくあるエラーメッセージ

#### "jq: command not found"
jqがインストールされていません。インストール方法は上記参照。

#### "Permission denied"
```bash
chmod +x ~/.claude/hooks/run-tests.sh
```

#### "No such file or directory"
必要なディレクトリを作成:
```bash
mkdir -p ~/.claude/hooks
```

## サポート

問題が解決しない場合は、以下の情報を確認してください:
1. デバッグログの内容 (`~/.claude/tdd-debug.log`)
2. Claude Code のバージョン
3. 使用しているOS
4. エラーメッセージの全文