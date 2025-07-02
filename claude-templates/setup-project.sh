#!/bin/bash

# Claude Code Templates - Project Setup Script
# Copies framework-specific templates to current project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK="$1"

# Function to display usage
show_usage() {
    echo "Usage: $0 <framework>"
    echo ""
    echo "Available frameworks:"
    echo "  hono   - Hono + Deno + TypeScript"
    echo "  rails  - Ruby on Rails"
    echo ""
    echo "Example:"
    echo "  $0 hono"
    echo "  $0 rails"
}

# Check if framework argument is provided
if [ -z "$FRAMEWORK" ]; then
    echo "❌ Error: Framework not specified"
    echo ""
    show_usage
    exit 1
fi

# Check if framework exists
FRAMEWORK_DIR="$SCRIPT_DIR/frameworks/$FRAMEWORK"
if [ ! -d "$FRAMEWORK_DIR" ]; then
    echo "❌ Error: Framework '$FRAMEWORK' not found"
    echo ""
    show_usage
    exit 1
fi

echo "🚀 Claude Code Templates - Project Setup"
echo "========================================"
echo "Framework: $FRAMEWORK"
echo "Target: $(pwd)"
echo ""

# Create .claude directory
if [ ! -d ".claude" ]; then
    echo "📁 Creating .claude directory..."
    mkdir -p ".claude"
fi

# Create project-specific CLAUDE.md
echo "📝 Setting up project CLAUDE.md..."
cat > ".claude/CLAUDE.md" << EOF
# Claude Code Configuration for $FRAMEWORK Project

#include $SCRIPT_DIR/CLAUDE.md
#include $SCRIPT_DIR/frameworks/$FRAMEWORK/CLAUDE.md

## Project-Specific Configuration

<!-- TODO: Add project name and description -->
**Project Name**: [Enter project name]
**Description**: [Enter project description]
**Framework**: $FRAMEWORK

<!-- TODO: Customize project-specific settings -->
### Project Context

**Purpose**: [Describe the project purpose]
**Key Features**: 
- [Feature 1]
- [Feature 2]
- [Feature 3]

**Development Notes**:
- [Add development-specific notes]
- [Add team conventions]
- [Add project constraints]

### Quick Start

<!-- TODO: Add project-specific quick start instructions -->
1. [Setup step 1]
2. [Setup step 2]
3. [Setup step 3]

EOF

echo "   ✅ Created: .claude/CLAUDE.md"

# Copy framework-specific style guide if it exists
if [ -f "$FRAMEWORK_DIR/style-guide.md" ]; then
    echo "📋 Copying style guide..."
    cp "$FRAMEWORK_DIR/style-guide.md" ".claude/style-guide.md"
    echo "   ✅ Copied: .claude/style-guide.md"
fi

# Create docs directory and copy templates
echo "📚 Setting up documentation templates..."
mkdir -p "docs"

# Copy common documentation templates
for doc in SPECIFICATION IMPROVEMENT_HISTORY HISTORICAL_CONTEXT TROUBLESHOOTING; do
    if [ -f "$SCRIPT_DIR/common/docs/$doc.md" ]; then
        echo "   Copying $doc.md..."
        cp "$SCRIPT_DIR/common/docs/$doc.md" "docs/$doc.md"
    fi
done

echo "   ✅ Documentation templates copied to docs/"

# Create TODO.md with pcheck integration
echo "📋 Setting up TODO.md..."
cat > "TODO.md" << 'EOF'
# Project TODO List

This file is managed by `pcheck` tool for systematic task tracking.

## Setup

- [ ] Configure project-specific settings in .claude/CLAUDE.md
- [ ] Update docs/SPECIFICATION.md with project requirements
- [ ] Set up development environment
- [ ] Configure testing framework
- [ ] Set up deployment pipeline

## Documentation

- [ ] Update project README
- [ ] Complete SPECIFICATION.md
- [ ] Document API endpoints (if applicable)
- [ ] Add troubleshooting guide entries

## Development

- [ ] Implement core features
- [ ] Add comprehensive tests
- [ ] Set up CI/CD pipeline
- [ ] Performance optimization

## Deployment

- [ ] Configure production environment
- [ ] Set up monitoring and alerting
- [ ] Prepare deployment documentation
- [ ] Conduct security review

---

**Task Management**:
- Use `pcheck` to view and manage tasks
- Use `pcheck add -m "Description"` to add tasks
- Use `pcheck check <id>` to toggle task completion
- Use `pcheck u` to update COMPLETED section
EOF

echo "   ✅ Created: TODO.md"

# Create tmp directory for testing
echo "📁 Creating tmp directory for testing..."
mkdir -p "tmp"
echo "   ✅ Created: tmp/ (for testing and validation)"

# Create settings.local.json
echo "⚙️  Creating local settings..."
cat > ".claude/settings.local.json" << EOF
{
  "project": {
    "name": "[Enter project name]",
    "framework": "$FRAMEWORK",
    "description": "[Enter project description]"
  },
  "development": {
    "testDirectory": "tmp",
    "mainBranch": "main"
  },
  "preferences": {
    "language": "ja",
    "notifications": true,
    "autoFormat": true
  }
}
EOF

echo "   ✅ Created: .claude/settings.local.json"

# Framework-specific setup
case "$FRAMEWORK" in
    "hono")
        echo ""
        echo "🔧 Hono-specific setup recommendations:"
        echo "   • Ensure Deno is installed: curl -fsSL https://deno.land/install.sh | sh"
        echo "   • Verify deno.json configuration"
        echo "   • Consider using Deno Deploy for hosting"
        ;;
    "rails")
        echo ""
        echo "🔧 Rails-specific setup recommendations:"
        echo "   • Ensure Ruby is installed (rbenv/asdf recommended)"
        echo "   • Run: bundle install"
        echo "   • Set up database: rails db:setup"
        echo "   • Consider using Heroku or similar for deployment"
        ;;
esac

echo ""
echo "📋 TODO Items to Complete:"
echo "1. Edit .claude/CLAUDE.md with project-specific information"
echo "2. Fill out docs/SPECIFICATION.md with project requirements"
echo "3. Update TODO.md with project-specific tasks"
echo "4. Configure .claude/settings.local.json"
echo "5. Start development with: /project:orchestrator in Claude Code"
echo ""

# Check if we're in a git repository
if [ -d ".git" ]; then
    echo "📦 Git repository detected"
    echo "   Consider adding .claude/settings.local.json to .gitignore"
    echo "   if it contains sensitive information"
else
    echo "💡 Recommendation: Initialize git repository"
    echo "   git init"
    echo "   git add ."
    echo "   git commit -m \"Initial project setup with Claude Code templates\""
fi

echo ""
echo "✅ Project setup completed successfully!"
echo "   Framework: $FRAMEWORK"
echo "   Ready for development with Claude Code"