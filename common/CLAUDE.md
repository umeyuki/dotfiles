# Base Claude Code Configuration Template

### Project Management

- **Session Start**: Execute `/project:orchestrator` to load context and plan task execution
- **Task Tracking**: Orchestrator mode automatically uses `pcheck` for TODO.md management

### Web Search Tool (Gemini CLI)

- **Installation Check**: If gemini CLI is not available, provide installation instructions
- **Usage**: Run web search via `gemini -p 'WebSearch: ...'` for research and information gathering

### Project Structure Standards

- **Documentation Directory**: Maintain `docs/` directory with structured documentation
- **Claude Configuration**: Use `.claude/` directory for Claude Code specific settings and local configurations
- **Examples Directory**: Provide `examples/` directory for code samples, templates, and demonstration materials

### Standard Documentation Files

Reference these files from the template repository when needed:

- **SPECIFICATION.md**: Technical specifications, requirements, and architecture details
- **IMPROVEMENT_HISTORY.md**: Learning records, decisions made, and improvements implemented
- **HISTORICAL_CONTEXT.md**: Project evolution, decision history, and contextual background
- **TROUBLESHOOTING.md**: Common errors, solutions, and debugging approaches
- **TODO.md**: Task management and project checklist

When working on projects, reference these templates from `#include common/docs/[filename]` for structured documentation.

### Development Workflow

- **Environment Verification**: Check build, test, and configuration status before starting work
- **Status Tracking**: Maintain clear records of completed features, known issues, and development priorities

### Notification Configuration

Configure notifications using Claude Code Hooks. See setup.sh for configuration instructions.

### Language and Model Guidelines

- **Language Processing**: Process and think in English for accuracy and token efficiency, then respond in Japanese
- **Model Selection**: At session start, select Opus 4 using `/model` command. If higher-tier models are available, choose those instead

### Development Best Practices

- **Scope Limitation**: Only modify files within the designated working directory
- **Content Restraint**: Do not add features or content beyond explicit instructions

### File Editing Rules

- **Project Root Only**: Only edit files within the current project root directory
- **No External Modifications**: Never modify files outside the project directory
- **Tmp Directory Usage**: Use `tmp/` directory for testing and validation before applying changes to production code
- **Local Settings**: Store project-specific Claude Code settings in `.claude/settings.local.json`

### Version Control Guidelines

- **Frequent Commits**: Execute git commit after completing each task phase/paragraph for granular progress tracking
- **Commit Message Format**: Include specific change description, business context, and technical rationale
- **Working Units**: Ensure each commit represents a functional, error-free state of the codebase

### Testing Guidelines

- **Testing Methodology**: Adopt TDD (Test-Driven Development) following t-wada's recommended practices
  - **Red-Green-Refactor Cycle**: 
    1. Red: Write a failing test first
    2. Green: Write minimal code to make the test pass
    3. Refactor: Improve the code while keeping tests green
  - **Test First Principle**: Always write tests before implementation code
  - **Power Assert**: Use power-assert for better assertion failure messages
    - Node.js: `npm install --save-dev power-assert`
    - Deno: Use built-in assertions or `import { assert } from "https://deno.land/std/testing/asserts.ts"`
  - **AAA Pattern**: Arrange-Act-Assert structure for test cases
- **Documentation Focus**:
  - **Code Comments**: Focus on **How** - explain the implementation approach
  - **Test Code**: Focus on **What** - clearly describe what behavior is being tested
  - **Commit Messages**: Focus on **Why** - explain the reason for the change
  - **Design Decisions**: Focus on **Why Not** - explain why alternatives were not chosen
- **Test Execution**:
  - Run tests frequently during development
  - All tests must pass before committing
  - Use `npm test` or `deno test` as appropriate for the project