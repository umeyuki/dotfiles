#!/bin/bash

# Claude Code Dotfiles Setup Script
# Usage: 
#   ./setup.sh          - Setup global configuration
#   ./setup.sh project [framework] - Setup project-specific configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTION="${1:-global}"
FRAMEWORK="$2"

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

# Function to check required tools
check_tools() {
    echo -e "\n${BLUE}🔧 Checking development tools...${NC}"
    
    local tools_ok=true
    local missing_tools=()
    
    # Check asdf
    if command -v asdf >/dev/null 2>&1; then
        echo -e "   ${GREEN}✓${NC} asdf"
    else
        echo -e "   ${RED}✗${NC} asdf"
        missing_tools+=("asdf")
        tools_ok=false
    fi
    
    # Check Deno
    if command -v deno >/dev/null 2>&1; then
        echo -e "   ${GREEN}✓${NC} deno"
    else
        echo -e "   ${RED}✗${NC} deno"
        missing_tools+=("deno")
        tools_ok=false
    fi
    
    # Check bun
    if command -v bun >/dev/null 2>&1; then
        echo -e "   ${GREEN}✓${NC} bun"
    else
        echo -e "   ${RED}✗${NC} bun"
        missing_tools+=("bun")
        tools_ok=false
    fi
    
    # Check rbenv
    if command -v rbenv >/dev/null 2>&1; then
        echo -e "   ${GREEN}✓${NC} rbenv"
    else
        echo -e "   ${RED}✗${NC} rbenv"
        missing_tools+=("rbenv")
        tools_ok=false
    fi
    
    # Check jq (system package)
    if command -v jq >/dev/null 2>&1; then
        echo -e "   ${GREEN}✓${NC} jq"
    else
        echo -e "   ${RED}✗${NC} jq"
        missing_tools+=("jq")
        tools_ok=false
    fi
    
    # Check pcheck (requires deno)
    if command -v pcheck >/dev/null 2>&1; then
        echo -e "   ${GREEN}✓${NC} pcheck"
    else
        echo -e "   ${RED}✗${NC} pcheck"
        missing_tools+=("pcheck")
        tools_ok=false
    fi
    
    # Check optional tools
    if command -v gemini >/dev/null 2>&1; then
        echo -e "   ${GREEN}✓${NC} gemini CLI"
    else
        echo -e "   ${YELLOW}⚠${NC}  gemini CLI (optional)"
    fi
    
    if command -v peco >/dev/null 2>&1; then
        echo -e "   ${GREEN}✓${NC} peco"
    else
        echo -e "   ${YELLOW}⚠${NC}  peco (optional)"
    fi
    
    if [ "$tools_ok" = false ]; then
        echo -e "\n${YELLOW}Some required tools are missing. Here are the installation commands:${NC}"
        show_install_commands "${missing_tools[@]}"
        
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Function to show installation commands
show_install_commands() {
    local missing_tools=("$@")
    
    echo -e "\n${BLUE}📋 Installation Commands:${NC}"
    echo "=========================================="
    
    for tool in "${missing_tools[@]}"; do
        case "$tool" in
            "asdf")
                echo -e "\n${YELLOW}📦 asdf (version manager)${NC}"
                echo "git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0"
                echo "echo '. ~/.asdf/asdf.sh' >> ~/.bashrc"
                echo "echo '. ~/.asdf/completions/asdf.bash' >> ~/.bashrc"
                echo "source ~/.bashrc"
                ;;
            "deno")
                echo -e "\n${YELLOW}📦 Deno (JavaScript/TypeScript runtime)${NC}"
                echo "curl -fsSL https://deno.land/install.sh | sh"
                echo "echo 'export PATH=\"\$HOME/.deno/bin:\$PATH\"' >> ~/.bashrc"
                echo "source ~/.bashrc"
                ;;
            "bun")
                echo -e "\n${YELLOW}📦 Bun (JavaScript runtime)${NC}"
                echo "curl -fsSL https://bun.sh/install | bash"
                echo "source ~/.bashrc"
                ;;
            "rbenv")
                echo -e "\n${YELLOW}📦 rbenv (Ruby version manager)${NC}"
                echo "git clone https://github.com/rbenv/rbenv.git ~/.rbenv"
                echo "echo 'export PATH=\"\$HOME/.rbenv/bin:\$PATH\"' >> ~/.bashrc"
                echo "echo 'eval \"\$(rbenv init -)\"' >> ~/.bashrc"
                echo "source ~/.bashrc"
                echo "git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build"
                ;;
            "jq")
                echo -e "\n${YELLOW}📦 jq (JSON processor)${NC}"
                echo "sudo apt update && sudo apt install -y jq"
                ;;
            "pcheck")
                echo -e "\n${YELLOW}📦 pcheck (project checklist tool)${NC}"
                echo "# Requires Deno to be installed first"
                echo "deno install -Afg --name pcheck jsr:@mizchi/project-checklist/cli"
                ;;
        esac
    done
    
    echo -e "\n${BLUE}💡 Optional tools:${NC}"
    echo "# gemini CLI (Google Gemini API)"
    echo "npm install -g @google/gemini-cli"
    echo ""
    echo "# peco (interactive filtering tool)"
    echo "go install github.com/peco/peco/cmd/peco@latest"
    echo ""
    echo "# win32yank (WSL clipboard utility)"
    echo "curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip"
    echo "unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe"
    echo "chmod +x /tmp/win32yank.exe"
    echo "sudo mv /tmp/win32yank.exe /usr/local/bin/"
}

# Global setup function
setup_global() {
    echo -e "${BLUE}🚀 Claude Code Dotfiles - Global Setup${NC}"
    echo "======================================="
    
    # Check tools
    check_tools
    
    echo -e "\n${BLUE}📁 Setting up dotfiles...${NC}"
    
    # Setup .bashrc
    create_symlink "$SCRIPT_DIR/.bashrc" "$HOME/.bashrc"
    
    # Setup .claude directory
    create_symlink "$SCRIPT_DIR/.claude" "$HOME/.claude"
    
    # Setup scripts
    if [ ! -d "$HOME/scripts" ]; then
        mkdir -p "$HOME/scripts"
    fi
    create_symlink "$SCRIPT_DIR/scripts/notify-pushover.sh" "$HOME/scripts/notify-pushover.sh"
    
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
    echo "1. Configure Claude Code Hooks for notifications:"
    echo "   • Run: /hooks in Claude Code"
    echo "   • Select: 3. Notification - When notifications are sent"
    echo "   • Add hook command:"
    echo -e "${YELLOW}     if [ -x ~/scripts/notify-pushover.sh ]; then"
    echo "       jq -r '.message' | xargs ~/scripts/notify-pushover.sh \"Claude\""
    echo -e "     fi${NC}"
    echo ""
    echo "2. Edit ~/.env.local with your Pushover API keys"
    echo ""
    echo "3. Reload your shell: source ~/.bashrc"
    echo ""
    echo -e "${GREEN}✅ Global setup completed successfully!${NC}"
}

# Project setup function
setup_project() {
    local framework="$1"
    
    if [ -z "$framework" ]; then
        echo -e "${RED}❌ Error: Framework not specified${NC}"
        echo ""
        echo "Usage: $0 project <framework>"
        echo ""
        echo "Available frameworks:"
        for dir in "$SCRIPT_DIR/frameworks"/*; do
            if [ -d "$dir" ]; then
                echo "  • $(basename "$dir")"
            fi
        done
        exit 1
    fi
    
    # Check if framework exists
    if [ ! -d "$SCRIPT_DIR/frameworks/$framework" ]; then
        echo -e "${RED}❌ Error: Framework '$framework' not found${NC}"
        echo ""
        echo "Available frameworks:"
        for dir in "$SCRIPT_DIR/frameworks"/*; do
            if [ -d "$dir" ]; then
                echo "  • $(basename "$dir")"
            fi
        done
        exit 1
    fi
    
    echo -e "${BLUE}🚀 Claude Code Project Setup${NC}"
    echo "========================================"
    echo "Framework: $framework"
    echo "Target: $(pwd)"
    echo ""
    
    # Create .claude directory
    if [ ! -d ".claude" ]; then
        echo -e "${BLUE}📁 Creating .claude directory...${NC}"
        mkdir -p ".claude"
    fi
    
    # Create project-specific CLAUDE.md
    echo -e "${BLUE}📝 Setting up project CLAUDE.md...${NC}"
    cat > ".claude/CLAUDE.md" << EOF
# Claude Code Configuration for $framework Project

#include $SCRIPT_DIR/.claude/CLAUDE.md
#include $SCRIPT_DIR/frameworks/$framework/CLAUDE.md

## Project-Specific Configuration

<!-- TODO: プロジェクト情報を記入してください -->
**Project Name**: <!-- TODO: プロジェクト名を記入 -->
**Description**: <!-- TODO: プロジェクトの説明を記入 -->
**Framework**: $framework

### Project Context

<!-- TODO: 以下の項目を記入してください -->
**Purpose**: <!-- TODO: プロジェクトの目的を記述 -->
**Key Features**: 
- <!-- TODO: 主要機能1 -->
- <!-- TODO: 主要機能2 -->
- <!-- TODO: 主要機能3 -->

### Quick Start

<!-- TODO: プロジェクト固有のセットアップ手順を記入 -->
1. <!-- TODO: セットアップ手順1 -->
2. <!-- TODO: セットアップ手順2 -->
3. <!-- TODO: セットアップ手順3 -->
EOF
    echo -e "${GREEN}✅ Created: .claude/CLAUDE.md${NC}"
    
    # Copy framework-specific files
    if [ -f "$SCRIPT_DIR/frameworks/$framework/style-guide.md" ]; then
        cp "$SCRIPT_DIR/frameworks/$framework/style-guide.md" ".claude/style-guide.md"
        echo -e "${GREEN}✅ Copied: .claude/style-guide.md${NC}"
    fi
    
    # Create docs directory and copy templates
    echo -e "${BLUE}📚 Setting up documentation templates...${NC}"
    mkdir -p "docs"
    
    for doc in SPECIFICATION IMPROVEMENT_HISTORY HISTORICAL_CONTEXT TROUBLESHOOTING; do
        if [ -f "$SCRIPT_DIR/common/docs/$doc.md" ]; then
            cp "$SCRIPT_DIR/common/docs/$doc.md" "docs/$doc.md"
        fi
    done
    echo -e "${GREEN}✅ Documentation templates copied to docs/${NC}"
    
    # Create TODO.md
    echo -e "${BLUE}📋 Setting up TODO.md...${NC}"
    cat > "TODO.md" << 'EOF'
# Project TODO List

This file is managed by `pcheck` tool for systematic task tracking.

## Setup

- [ ] Configure project-specific settings in .claude/CLAUDE.md
- [ ] Update docs/SPECIFICATION.md with project requirements
- [ ] Set up development environment
- [ ] Configure testing framework

## Development

- [ ] Implement core features
- [ ] Add comprehensive tests
- [ ] Performance optimization

---

**Task Management**:
- Use `pcheck` to view tasks
- Use `pcheck add -m "Description"` to add tasks
- Use `pcheck check <id>` to toggle completion
EOF
    echo -e "${GREEN}✅ Created: TODO.md${NC}"
    
    # Create tmp directory
    mkdir -p "tmp"
    echo -e "${GREEN}✅ Created: tmp/ (for testing and validation)${NC}"
    
    # Framework-specific recommendations
    case "$framework" in
        "hono")
            echo -e "\n${BLUE}🔧 Hono-specific recommendations:${NC}"
            echo "   • Ensure Deno is installed"
            echo "   • Verify deno.json configuration"
            ;;
        "rails")
            echo -e "\n${BLUE}🔧 Rails-specific recommendations:${NC}"
            echo "   • Run: bundle install"
            echo "   • Set up database: rails db:setup"
            ;;
    esac
    
    echo -e "\n${GREEN}✅ Project setup completed successfully!${NC}"
    echo "   Framework: $framework"
    echo "   Ready for development with Claude Code"
}

# Main execution
case "$ACTION" in
    "global")
        setup_global
        ;;
    "project")
        setup_project "$FRAMEWORK"
        ;;
    *)
        echo -e "${RED}❌ Error: Unknown action '$ACTION'${NC}"
        echo ""
        echo "Usage:"
        echo "  $0          - Setup global configuration"
        echo "  $0 project [framework] - Setup project-specific configuration"
        exit 1
        ;;
esac