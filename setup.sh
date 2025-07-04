#!/bin/bash

# Claude Code Dotfiles Setup Script
# Usage: 
#   ./setup.sh          - Setup global configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to create backup
backup_file() {
    local file="$1"
    local backup_dir="$HOME/tmp/dotfiles-backup-$(date +%Y%m%d_%H%M%S)"
    
    if [ -e "$file" ]; then
        mkdir -p "$backup_dir"
        local relative_path="${file#$HOME/}"
        local backup_path="$backup_dir/$relative_path"
        mkdir -p "$(dirname "$backup_path")"
        
        echo -e "${YELLOW}📦 Backing up: $file${NC}"
        echo -e "   → $backup_path"
        cp -r "$file" "$backup_path"
    fi
}

# Function to copy file with backup
copy_file() {
    local source="$1"
    local target="$2"
    
    # Backup existing file/directory if it exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        backup_file "$target"
        rm -rf "$target"
    fi
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"
    
    # Copy file
    cp "$source" "$target"
    echo -e "${GREEN}✅ Copied: $source → $target${NC}"
}

# Function to create symbolic link (replaced with copy for Claude Code compatibility)
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Use copy instead of symlink for Claude Code compatibility
    copy_file "$source" "$target"
}

# Alias for clarity - Claude Code doesn't support symlinks
copy_for_claude() {
    copy_file "$1" "$2"
}


# Global setup function
setup_global() {
    echo -e "${BLUE}🚀 Claude Code Dotfiles - Global Setup${NC}"
    echo "======================================="
    
    
    echo -e "\n${BLUE}📁 Setting up dotfiles...${NC}"
    
    # Setup .bashrc (using actual symlink for shell config)
    if [ -e "$HOME/.bashrc" ] || [ -L "$HOME/.bashrc" ]; then
        backup_file "$HOME/.bashrc"
        rm -f "$HOME/.bashrc"
    fi
    ln -s "$SCRIPT_DIR/.bashrc" "$HOME/.bashrc"
    echo -e "${GREEN}✅ Symlinked: .bashrc${NC}"
    
    # Setup .claude directory structure (not full directory link)
    echo -e "\n${BLUE}🔧 Setting up Claude configuration...${NC}"
    mkdir -p "$HOME/.claude"
    
    # Copy CLAUDE.md from common directory (Claude Code doesn't support symlinks)
    copy_file "$SCRIPT_DIR/common/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    
    # Copy settings.json (hooks configuration) from common directory
    copy_file "$SCRIPT_DIR/common/settings.json" "$HOME/.claude/settings.json"
    
    # Setup common commands (Claude Code doesn't support symlinks)
    mkdir -p "$HOME/.claude/commands"
    for cmd_file in "$SCRIPT_DIR/common/commands"/*.md; do
        if [ -f "$cmd_file" ]; then
            cmd_name=$(basename "$cmd_file")
            copy_file "$cmd_file" "$HOME/.claude/commands/$cmd_name"
        fi
    done
    
    # Setup common hooks
    mkdir -p "$HOME/.claude/hooks"
    for hook_file in "$SCRIPT_DIR/common/hooks"/*; do
        if [ -f "$hook_file" ]; then
            hook_name=$(basename "$hook_file")
            copy_for_claude "$hook_file" "$HOME/.claude/hooks/$hook_name"
        fi
    done
    
    
    # Create .env.local template if it doesn't exist
    if [ ! -f "$HOME/.env.local" ]; then
        echo -e "\n${BLUE}📝 Creating .env.local template...${NC}"
        cat > "$HOME/.env.local" << 'EOF'
# Pushover notification settings
# Get your keys from https://pushover.net/
PUSHOVER_USER_KEY=your-user-key-here
PUSHOVER_APP_TOKEN=your-app-token-here

# TDD Hook notification settings
# ENABLE_TDD_NOTIFICATIONS=true  # 通知を有効化
# NOTIFY_ON_SUCCESS=false        # テスト成功時の通知（デフォルト: false）
# NOTIFY_ON_FAILURE=true         # テスト失敗時の通知（デフォルト: true）
EOF
        echo -e "${GREEN}✅ Created: ~/.env.local${NC}"
        echo -e "${YELLOW}   Please edit this file and add your Pushover API keys${NC}"
    else
        # 既存の.env.localにTDD設定が無い場合は追加
        if ! grep -q "ENABLE_TDD_NOTIFICATIONS" "$HOME/.env.local"; then
            echo -e "\n${BLUE}📝 Adding TDD notification settings to .env.local...${NC}"
            cat >> "$HOME/.env.local" << 'EOF'

# TDD Hook notification settings
# ENABLE_TDD_NOTIFICATIONS=true  # 通知を有効化
# NOTIFY_ON_SUCCESS=false        # テスト成功時の通知（デフォルト: false）
# NOTIFY_ON_FAILURE=true         # テスト失敗時の通知（デフォルト: true）
EOF
            echo -e "${GREEN}✅ Updated: ~/.env.local${NC}"
        fi
    fi
    
    # Setup Claude Code Hooks
    echo -e "\n${BLUE}🎯 Next Steps:${NC}"
    echo "1. Edit ~/.env.local with your Pushover API keys"
    echo ""
    echo "2. Install similarity-ts for duplicate detection:"
    echo "   • cargo install similarity-ts (requires Rust)"
    echo ""
    echo "3. Reload your shell: source ~/.bashrc"
    echo ""
    echo -e "${GREEN}✅ Hooks automatically configured:${NC}"
    echo "   • Notification Hook: Pushover通知（Ubuntu対応）"
    echo "   • Code Quality Hook: 重複コード検出"
    echo "   • Testing Hook: ファイル編集後テスト自動実行（TDD支援）"
    echo "     - テストが失敗すると自動的にフィードバック"
    echo "     - Red-Green-Refactorサイクルを自動化"
    echo "     - デバッグログ: ~/.claude/tdd-debug.log"
    echo ""
    echo -e "${GREEN}✅ Global setup completed successfully!${NC}"
}

# Main execution - Global setup only
setup_global