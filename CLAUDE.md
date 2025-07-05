# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository optimized for Claude Code users who practice Test-Driven Development (TDD). It provides automated testing, code quality checks, and smart notifications.

## Key Commands

### Initial Setup
```bash
# Install global dotfiles configuration
./setup.sh

# Create project from template
claude-blueprint              # Default: hono-sveltekit
claude-blueprint rails        # Rails template
```

### Development Commands
```bash
# Task management (pcheck)
pcheck                       # Show all TODO items
pcheck u                     # Update TODO.md (move completed to COMPLETED)
pcheck u --vacuum           # Remove completed tasks for git commits
pcheck add -m "Task"        # Add new task
pcheck check <id>           # Toggle task status

# Environment check
source ~/.bashrc            # Runs automatic environment verification

# Manual test execution (automatically runs on file edits)
npm test                    # Node.js projects
deno test                   # Deno projects
bundle exec rspec           # Ruby projects
python -m pytest            # Python projects
```

## Architecture & Structure

### Repository Layout
```
dotfiles/
├── .bashrc                 # Minimal bash config with asdf, aliases
├── .claude/               # Claude Code configurations
│   ├── CLAUDE.md          # Global instructions (copied to ~/.claude/)
│   ├── settings.json      # Hooks configuration
│   └── hooks/             # Automation scripts
│       ├── run-tests.sh   # Auto test runner (TDD support)
│       ├── detect-duplicates.sh  # Code duplication detector
│       └── notify-pushover.sh    # Smart notification system
├── setup.sh               # Global installer script
├── claude-blueprint.sh    # Project template generator
├── common/                # Shared templates
│   └── docs/              # Documentation templates
└── templates/             # Project-specific templates
    ├── hono-sveltekit/    # Functional programming focused
    └── rails/             # Rails conventions
```

### Hook System Architecture

The repository implements a sophisticated hook system that triggers on Claude Code events:

1. **Auto Test Runner** (`run-tests.sh`):
   - Triggers on source/test file edits
   - Auto-detects project type (Node.js, Deno, Ruby, Python, Go)
   - Implements TDD phase tracking (Red → Green → Refactor)
   - 5-second debounce to prevent duplicate runs

2. **Duplicate Code Detector** (`detect-duplicates.sh`):
   - Runs `similarity-ts` on TypeScript/JavaScript edits
   - 85% similarity threshold, minimum 5 lines
   - Automatic installation prompt if not available

3. **Smart Notifications** (`notify-pushover.sh`):
   - Filters meaningless notifications ("Claude: Claude")
   - Prevents duplicate notifications within 5 seconds
   - Configurable via `.env.local`

### Configuration Management

- **Global Config**: `~/.claude/CLAUDE.md` - Instructions for all projects
- **Project Config**: `.claude/` directory in each project
- **Environment**: `.env.local` for API keys and notification settings
- **Permissions**: Detailed security controls in `settings.json`

## Testing Philosophy

This repository enforces TDD practices following t-wada's methodology:

1. **Red Phase**: Write failing test first
2. **Green Phase**: Minimal code to pass
3. **Refactor Phase**: Improve while keeping tests green

Tests run automatically on file save with smart notification control.

## Important Implementation Details

### Language-Specific Test Detection
- **Node.js**: Checks for `package.json` with test script
- **Deno**: Looks for `deno.json` or `deno.jsonc`
- **Ruby**: Detects `Gemfile`, runs rspec/rake test
- **Python**: Finds `requirements.txt` or `pyproject.toml`, runs pytest/unittest
- **Go**: Executes `go test ./...` when go.mod exists

### Security Considerations
The `settings.json` includes comprehensive permissions for:
- File system access (read/write/list)
- Process execution (bash commands)
- Environment variable access
- External tool integration

### Notification System
- Requires Pushover account (Ubuntu/WSL)
- Configurable success/failure notifications
- Debug logs at `~/.claude/pushover-debug.log`
- Smart filtering prevents spam

## Development Workflow

1. **Project Creation**: Use `claude-blueprint` to set up new projects with TDD structure
2. **Task Management**: Use `pcheck` for TODO tracking
3. **TDD Cycle**: Write test → See it fail → Implement → See it pass → Refactor
4. **Code Quality**: Automatic duplicate detection on save
5. **Notifications**: Get alerts only for test failures (configurable)