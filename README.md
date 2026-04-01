# CC + Codex Collaborative Development Workflow

A workflow for collaborative development using Claude Code and Codex (OpenAI API with proxy support).

## Features

- **Dual-Model collaboration**: Claude Code handles planning/search, Codex handles code generation
- **Proxy support**: Automatic proxy configuration for Codex through port 7897
- **Plan mode integration**: Uses oh-my-claudecode's `/plan` or `/ralplan`
- **Self-contained**: No modification to system-level CLAUDE.md required

## Quick Start

### Prerequisites

1. **Claude Code** installed
2. **Codex CLI** installed: `npm install -g @openai/codex`
3. **Proxy server** running on port 7897

### Installation

#### Option 1: Auto Install (Recommended)

```bash
git clone https://github.com/your-username/cc-codex-workflow.git
cd cc-codex-workflow
./install.sh
```

The installer will:
1. Copy the skill to `~/.claude/skills/cc-codex-flow/SKILL.md`
2. Optionally configure Codex MCP in `~/.claude.json` (with proxy)

To uninstall:
```bash
./install.sh --uninstall
```

#### Option 2: Manual Install

1. **Configure Codex MCP** in `~/.claude.json`:
```json
{
  "mcpServers": {
    "codex": {
      "type": "stdio",
      "command": "codex",
      "args": ["mcp-server"],
      "env": {
        "HTTP_PROXY": "http://127.0.0.1:7897",
        "HTTPS_PROXY": "http://127.0.0.1:7897",
        "NO_PROXY": "localhost,127.0.0.1"
      }
    }
  }
}
```

2. **Copy the skill**:
```bash
mkdir -p ~/.claude/skills/cc-codex-flow
cp SKILL.md ~/.claude/skills/cc-codex-flow/SKILL.md
```

3. **Restart Claude Code** to apply changes

### Usage

In Claude Code, type:
```
/cc-codex-flow [task description]
```

Examples:
```
/cc-codex-flow Add user authentication with JWT tokens
/cc-codex-flow Refactor the data processing module
/cc-codex-flow Implement a REST API client
```

## Workflow

1. **Information Collection** (Claude Code)
   - WebSearch for latest docs
   - Glob/Grep for code structure analysis
   - Output: context report

2. **Task Planning** (oh-my-claudecode Plan Mode)
   - Use `/oh-my-claudecode:plan` or `/ralplan`
   - Generate tech spec and task breakdown

3. **Execution** (Codex-First)
   - All code tasks delegated to Codex via MCP
   - Session management with conversationId

4. **Validation** (Claude Code)
   - Test verification
   - Type checking
   - Performance review

## Configuration

### MCP Server Configuration
The Codex MCP is configured with proxy settings in `~/.claude.json`:
 See [Installation](#installation) section for details.

### Skill Configuration
    The skill contains embedded collaboration rules, eliminating the need for system-level CLAUDE.md modifications.

## Why This approach?

1. **Avoids system-level config conflicts**: Project-level CLAUDE.md can override system-level settings
2. **Portability**: Skill can be easily shared and installed across projects
3. **Version control**: Track changes to the workflow through Git

## License

MIT
