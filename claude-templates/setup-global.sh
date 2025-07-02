#!/bin/bash

# Claude Code Templates - Global Setup Script
# Sets up global Claude Code configuration with symlinks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "🚀 Claude Code Templates - Global Setup"
echo "======================================="

# Create .claude directory if it doesn't exist
if [ ! -d "$CLAUDE_DIR" ]; then
    echo "📁 Creating ~/.claude directory..."
    mkdir -p "$CLAUDE_DIR"
fi

# Create symlink for global CLAUDE.md
echo "🔗 Setting up global CLAUDE.md symlink..."
if [ -L "$CLAUDE_DIR/CLAUDE.md" ]; then
    echo "   Removing existing symlink..."
    rm "$CLAUDE_DIR/CLAUDE.md"
elif [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    echo "   Backing up existing CLAUDE.md..."
    mv "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.backup.$(date +%Y%m%d_%H%M%S)"
fi

ln -s "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
echo "   ✅ Symlink created: ~/.claude/CLAUDE.md -> $SCRIPT_DIR/CLAUDE.md"

# Check for required tools
echo ""
echo "🔧 Checking required tools..."

# Check jq
if command -v jq >/dev/null 2>&1; then
    echo "   ✅ jq is installed"
else
    echo "   ❌ jq is NOT installed"
    echo "      Install with: sudo apt install jq (Ubuntu/Debian) or brew install jq (macOS)"
fi

# Check pcheck
if command -v pcheck >/dev/null 2>&1; then
    echo "   ✅ pcheck is installed"
else
    echo "   ❌ pcheck is NOT installed"
    echo "      Install with: deno install -Afg --name pcheck jsr:@mizchi/project-checklist/cli"
fi

# Check gemini CLI
if command -v gemini >/dev/null 2>&1; then
    echo "   ✅ gemini CLI is installed"
else
    echo "   ❌ gemini CLI is NOT installed"
    echo "      Install with: npm install -g @google/gemini-cli"
fi

# Check for notification script
if [ -x "$HOME/scripts/notify-pushover.sh" ]; then
    echo "   ✅ Pushover notification script found"
else
    echo "   ⚠️  Pushover notification script not found at ~/scripts/notify-pushover.sh"
    echo "      This is optional - notifications will be skipped if not available"
fi

echo ""
echo "🎯 Next Steps:"
echo "1. Configure Claude Code Hooks for notifications:"
echo "   • Run: /hooks in Claude Code"
echo "   • Select: 3. Notification - When notifications are sent"
echo "   • Add hook command:"
echo "     if [ -x ~/scripts/notify-pushover.sh ]; then"
echo "       jq -r '.message' | xargs ~/scripts/notify-pushover.sh \"Claude\""
echo "     fi"
echo ""
echo "2. For new projects, use:"
echo "   $SCRIPT_DIR/setup-project.sh [framework]"
echo ""
echo "3. Available frameworks:"
echo "   • hono  (Hono + Deno + TypeScript)"
echo "   • rails (Ruby on Rails)"
echo ""

# Create settings.local.json template
SETTINGS_LOCAL="$CLAUDE_DIR/settings.local.json"
if [ ! -f "$SETTINGS_LOCAL" ]; then
    echo "📝 Creating settings.local.json template..."
    cat > "$SETTINGS_LOCAL" << 'EOF'
{
  "project": {
    "name": "Your Project Name",
    "framework": "framework-name",
    "description": "Project description"
  },
  "preferences": {
    "language": "ja",
    "notifications": true
  }
}
EOF
    echo "   ✅ Created: ~/.claude/settings.local.json"
    echo "      Edit this file to customize project-specific settings"
fi

echo ""
echo "✅ Global setup completed successfully!"
echo "   Global CLAUDE.md is now available in all Claude Code sessions"
echo "   Use /project:orchestrator command to load project context"