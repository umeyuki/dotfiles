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

# Function to create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Backup existing file/directory if it exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        backup_file "$target"
        rm -rf "$target"
    fi
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"
    
    # Create symlink
    ln -s "$source" "$target"
    echo -e "${GREEN}✅ Linked: $target → $source${NC}"
}


# Global setup function
setup_global() {
    echo -e "${BLUE}🚀 Claude Code Dotfiles - Global Setup${NC}"
    echo "======================================="
    
    
    echo -e "\n${BLUE}📁 Setting up dotfiles...${NC}"
    
    # Setup .bashrc
    create_symlink "$SCRIPT_DIR/.bashrc" "$HOME/.bashrc"
    
    # Setup .claude directory structure (not full directory link)
    echo -e "\n${BLUE}🔧 Setting up Claude configuration...${NC}"
    mkdir -p "$HOME/.claude"
    
    # Link CLAUDE.md
    create_symlink "$SCRIPT_DIR/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    
    # Link settings.json (hooks configuration)
    create_symlink "$SCRIPT_DIR/.claude/settings.json" "$HOME/.claude/settings.json"
    
    # Setup common commands
    mkdir -p "$HOME/.claude/commands"
    for cmd_file in "$SCRIPT_DIR/common/commands"/*.md; do
        if [ -f "$cmd_file" ]; then
            cmd_name=$(basename "$cmd_file")
            create_symlink "$cmd_file" "$HOME/.claude/commands/$cmd_name"
        fi
    done
    
    # Setup common hooks
    mkdir -p "$HOME/.claude/hooks"
    for hook_file in "$SCRIPT_DIR/common/hooks"/*; do
        if [ -f "$hook_file" ]; then
            hook_name=$(basename "$hook_file")
            create_symlink "$hook_file" "$HOME/.claude/hooks/$hook_name"
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
EOF
        echo -e "${GREEN}✅ Created: ~/.env.local${NC}"
        echo -e "${YELLOW}   Please edit this file and add your Pushover API keys${NC}"
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
    echo "   • Notification Hook: Pushover通知"
    echo "   • Code Quality Hook: 重複コード検出"
    echo ""
    echo -e "${GREEN}✅ Global setup completed successfully!${NC}"
}

# Main execution - Global setup only
setup_global