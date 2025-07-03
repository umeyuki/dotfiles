# Personal Dotfiles

個人用のdotfiles設定とClaude Code用のテンプレート集です。

## 概要

このリポジトリは個人の開発環境設定とClaude Codeでの開発を効率化するためのテンプレートを管理しています。

## 構成

```
dotfiles/
├── .bashrc                 # Bash設定
├── .claude/               # Claude Code設定
│   ├── CLAUDE.md          # グローバルClaude設定
│   └── settings.json      # Hooks設定（自動化）
├── .gitignore             # Git除外設定
├── setup.sh               # グローバルセットアップスクリプト
├── claude-blueprint.sh    # プロジェクトテンプレートスクリプト
├── common/                # 共通テンプレート
│   ├── commands/          # コマンドテンプレート
│   ├── docs/              # ドキュメントテンプレート
│   └── hooks/             # 共通Hooksスクリプト
│       ├── detect-duplicates.sh # 重複コード検出
│       └── notify-pushover.sh   # Pushover通知
└── templates/             # プロジェクトテンプレート
    ├── hono-sveltekit/    # Hono+SvelteKit設定
    └── rails/             # Rails設定
```

## セットアップ

### 1. グローバル設定のインストール

```bash
# リポジトリをクローン
git clone https://github.com/umeyuki/dotfiles.git ~/dotfiles

# グローバル設定をインストール
~/dotfiles/setup.sh

# シェルを再読み込み
source ~/.bashrc
```

### 2. プロジェクトテンプレート作成

```bash
# プロジェクトディレクトリで実行
claude-blueprint                    # hono-sveltekit（デフォルト）
claude-blueprint hono-sveltekit    # 明示的指定
claude-blueprint rails             # Rails用

# 例：新しいプロジェクト作成
mkdir my-app && cd my-app
claude-blueprint
```

## 主な機能

### 自動化されたHooks
- **重複コード検出**: similarity-ts による自動チェック（ファイル編集時）
- **Pushover通知**: Claude Codeからの自動通知
- **設定不要**: setup.sh 実行時に自動で有効化

### 開発環境チェック
- asdf, deno, bun, jq, pcheck, similarity-ts などの必要ツールの確認
- 未インストールツールの公式インストール手順を表示

### プロジェクトテンプレート
- **hono-sveltekit**: Hono + SvelteKit + Turso + Cloud Run/Cloudflare構成
- **rails**: Ruby on Rails構成
- プロジェクト構成用ドキュメントテンプレート
- タスク管理用TODO.md（pcheck対応）

## 必要なツール

### 必須
- **asdf**: バージョン管理
- **deno**: TypeScript/JavaScript実行環境
- **bun**: JavaScript実行環境
- **jq**: JSON処理
- **pcheck**: タスク管理ツール

### オプション（推奨）
- **similarity-ts**: 重複コード検出（cargo install similarity-ts）
- **gemini CLI**: Google Gemini API（npm install -g @google/gemini-cli）
- **peco**: インタラクティブフィルタ

## 使用方法

### 基本コマンド
```bash
~/dotfiles/setup.sh              # 初回グローバルセットアップ
claude-blueprint                 # プロジェクトテンプレート作成
```

### 設定ファイル
- **~/.env.local**: Pushover APIキー設定
- **~/.claude/settings.json**: Hooks設定（自動）
- **~/.claude/CLAUDE.md**: Claude設定（自動）

## 注意事項

- このdotfilesは個人用途向けに作成されています
- 使用する際は自己責任でお願いします
- 設定は個人の開発環境に特化しているため、そのままの利用は推奨しません

## ライセンス

このプロジェクトは個人用dotfilesとして公開されています。
参考として自由に閲覧・利用いただけますが、使用は自己責任でお願いします。

## 作者

[@umeyuki](https://github.com/umeyuki)