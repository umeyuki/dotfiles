#!/bin/bash

# Claude Blueprint - Project Template Setup
# Usage: 
#   ./claude-blueprint.sh [template]  - Setup project with template (default: hono-sveltekit)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="${1:-hono-sveltekit}"  # Default to hono-sveltekit

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if template exists
if [ ! -d "$SCRIPT_DIR/templates/$TEMPLATE" ]; then
    echo -e "${RED}❌ Error: Template '$TEMPLATE' not found${NC}"
    echo ""
    echo "Available templates:"
    for dir in "$SCRIPT_DIR/templates"/*; do
        if [ -d "$dir" ]; then
            echo "  • $(basename "$dir")"
        fi
    done
    exit 1
fi

echo -e "${BLUE}🚀 Claude Blueprint - Project Setup${NC}"
echo "========================================"
echo "Template: $TEMPLATE"
echo "Target: $(pwd)"
echo ""

# Create .claude directory
if [ ! -d ".claude" ]; then
    echo -e "${BLUE}📁 Creating .claude directory...${NC}"
    mkdir -p ".claude"
fi

# Create project-specific CLAUDE.md in project root
echo -e "${BLUE}📝 Setting up project CLAUDE.md...${NC}"
cat > "CLAUDE.md" << EOF
# Claude Code Configuration for $TEMPLATE Project

#include $SCRIPT_DIR/common/CLAUDE.md
#include $SCRIPT_DIR/templates/$TEMPLATE/CLAUDE.md

## Project Documentation

For detailed project information, refer to the following documents in the \`docs/\` directory:

- **docs/SPECIFICATION.md**: Technical specifications, requirements, and architecture details
- **docs/IMPROVEMENT_HISTORY.md**: Learning records, decisions made, and improvements implemented  
- **docs/HISTORICAL_CONTEXT.md**: Project evolution, decision history, and contextual background
- **docs/TROUBLESHOOTING.md**: Common errors, solutions, and debugging approaches

Use these documents to understand project context, track changes, and resolve issues effectively.
EOF
echo -e "${GREEN}✅ Created: CLAUDE.md${NC}"

# Copy template-specific files
if [ -f "$SCRIPT_DIR/templates/$TEMPLATE/style-guide.md" ]; then
    cp "$SCRIPT_DIR/templates/$TEMPLATE/style-guide.md" ".claude/coding-guide.md"
    echo -e "${GREEN}✅ Copied: .claude/coding-guide.md${NC}"
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
- [ ] Configure testing template

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

# Template-specific recommendations
case "$TEMPLATE" in
    "hono-sveltekit")
        echo -e "\n${BLUE}🔧 Hono-SvelteKit specific recommendations:${NC}"
        echo "   • Ensure Deno is installed"
        echo "   • Run: npx create-svelte@latest . --template https://github.com/vercel/hono-sveltekit"
        echo "   • Configure Turso database connection"
        echo "   • Set up Cloud Run or Cloudflare deployment"
        ;;
    "rails")
        echo -e "\n${BLUE}🔧 Rails-specific recommendations:${NC}"
        echo "   • Run: bundle install"
        echo "   • Set up database: rails db:setup"
        ;;
esac

echo -e "\n${GREEN}✅ Project blueprint completed successfully!${NC}"
echo "   Template: $TEMPLATE"
echo "   Ready for development with Claude Code"