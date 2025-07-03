# Personal Dotfiles

個人用のdotfiles設定とClaude Code用のテンプレート集です。

## 概要

このリポジトリは個人の開発環境設定とClaude Codeでの開発を効率化するためのテンプレートを管理しています。

## 構成

```
dotfiles/
├── .bashrc                 # Bash設定
├── .claude/               # Claude Code設定
│   └── CLAUDE.md          # グローバルClaude設定
├── .gitignore             # Git除外設定
├── setup.sh               # セットアップスクリプト
├── scripts/               # ユーティリティスクリプト
│   └── notify-pushover.sh # Pushover通知
├── common/                # 共通テンプレート
│   ├── commands/          # コマンドテンプレート
│   └── docs/              # ドキュメントテンプレート
└── frameworks/            # フレームワーク別設定
    ├── hono/              # Hono設定
    └── rails/             # Rails設定
```

## セットアップ

### 1. グローバル設定のインストール

```bash
# リポジトリをクローン
git clone https://github.com/umeyuki/dotfiles.git ~/dotfiles

# グローバル設定をインストール
~/dotfiles/setup.sh

# または
claude-setup  # エイリアスを使用
```

### 2. プロジェクト設定

```bash
# プロジェクトディレクトリで実行
claude-init <framework>

# 例：Honoプロジェクト
claude-init hono

# 例：Railsプロジェクト
claude-init rails
```

## 主な機能

### 開発環境チェック
- asdf, deno, bun, jq, pcheckなどの必要ツールの確認
- 未インストールツールの公式インストール手順を表示

### 通知機能
- Pushover経由でのタスク完了通知
- Claude Codeからの自動通知

### テンプレート
- フレームワーク別のClaude設定
- プロジェクト構成用ドキュメントテンプレート
- タスク管理用TODO.md

## 必要なツール

### 必須
- **asdf**: バージョン管理
- **deno**: TypeScript/JavaScript実行環境
- **bun**: JavaScript実行環境
- **jq**: JSON処理
- **pcheck**: タスク管理ツール

### オプション
- **gemini CLI**: Google Gemini API
- **peco**: インタラクティブフィルタ
- **win32yank**: WSLクリップボード連携

## 使用方法

### エイリアス
```bash
claude-setup    # グローバル設定インストール
claude-init     # プロジェクト設定初期化
```

### 通知設定
1. `~/.env.local`にPushover APIキーを設定
2. Claude Code Hooksで通知を有効化

## 注意事項

- このdotfilesは個人用途向けに作成されています
- 使用する際は自己責任でお願いします
- 設定は個人の開発環境に特化しているため、そのままの利用は推奨しません

## ライセンス

このプロジェクトは個人用dotfilesとして公開されています。
参考として自由に閲覧・利用いただけますが、使用は自己責任でお願いします。

## 作者

[@umeyuki](https://github.com/umeyuki)