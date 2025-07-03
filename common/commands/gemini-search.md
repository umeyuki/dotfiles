# Gemini Search

Use Google Gemini CLI for web search and research.

## Usage

```bash
gemini -p "WebSearch: [your search query]"
```

## Examples

```bash
# Search for technical documentation
gemini -p "WebSearch: TypeScript best practices 2024"

# Search for troubleshooting information
gemini -p "WebSearch: Node.js memory leak debugging"

# Search for framework comparisons
gemini -p "WebSearch: React vs Vue performance comparison"
```

## Installation

If gemini CLI is not available, install it with:

```bash
npm install -g @google/gemini-cli
```

## Integration

This command integrates with Claude Code's research workflow. Use it when you need:
- Current information beyond Claude's knowledge cutoff
- Technical documentation and best practices
- Troubleshooting solutions
- Framework and library comparisons