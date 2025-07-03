#!/bin/bash
# Claude Code Hook: Auto-run tests after file edit
# This hook runs tests when source or test files are modified

# Get the edited file from Claude Code hook context
EDITED_FILE="${EDITED_FILE:-}"

# Exit if no file was edited
if [ -z "$EDITED_FILE" ]; then
  exit 0
fi

# Check if the edited file is a test or source file
if [[ ! "$EDITED_FILE" =~ \.(js|ts|jsx|tsx|rb|py)$ ]] && [[ ! "$EDITED_FILE" =~ (test|spec)\. ]]; then
  exit 0
fi

# Find project root (where package.json, Gemfile, or deno.json exists)
PROJECT_ROOT=$(pwd)
while [ "$PROJECT_ROOT" != "/" ]; do
  if [ -f "$PROJECT_ROOT/package.json" ] || [ -f "$PROJECT_ROOT/Gemfile" ] || [ -f "$PROJECT_ROOT/deno.json" ]; then
    break
  fi
  PROJECT_ROOT=$(dirname "$PROJECT_ROOT")
done

# Change to project root
cd "$PROJECT_ROOT" || exit 0

# Run tests based on project type
if [ -f "package.json" ]; then
  # Node.js project
  if command -v npm &> /dev/null && grep -q '"test"' package.json; then
    echo "🧪 Running tests for Node.js project..."
    npm test
  fi
elif [ -f "deno.json" ] || [ -f "deno.jsonc" ]; then
  # Deno project
  if command -v deno &> /dev/null; then
    echo "🧪 Running tests for Deno project..."
    deno test
  fi
elif [ -f "Gemfile" ]; then
  # Ruby project
  if command -v bundle &> /dev/null; then
    echo "🧪 Running tests for Ruby project..."
    bundle exec rspec || bundle exec rake test || bundle exec ruby -I test test/
  fi
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  # Python project
  if command -v python &> /dev/null; then
    echo "🧪 Running tests for Python project..."
    python -m pytest || python -m unittest discover
  fi
fi