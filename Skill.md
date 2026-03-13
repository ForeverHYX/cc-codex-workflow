---
name: cc-codex-flow
 description: Claude Code + Codex collaborative development workflow with GLM support and proxy support
 triggers:
   - cc codex
   - codex collaboration
   - collaborative coding
 argument-hint: "[task description]"
---

# CC + Codex Collaborative Development Skill

## Purpose

This skill orchestrates collaborative development between Claude Code (using GLM, and Codex (using OpenAI API with proxy). maximizing the strengths of both tool.

## When to activate

- User mentions "cc codex", "codex collaboration", or "collaborative coding"
- User wants to use both Claude Code and Codex together for development

- Complex development tasks requiring code generation and refactoring

## Environment Requirements

### Claude Code Environment
- Uses GLM model (requires direct connection, no proxy)
- Plan mode: uses oh-my-claudecode's `/plan` or `/ralplan`

### Codex Environment
- Requires proxy access to OpenAI API
- Proxy: http://127.0.0.1:7897
- Configured in ~/.claude.json via MCP server env

## Workflow

### Phase 1: Information Collection (Claude Code)
- WebSearch: latest docs/practices
- Glob/Grep: analyze code structure
- Output: context report (tech stack, files, patterns, risks)

### Phase 2: Task Planning (oh-my-claudecode Plan Mode)
Use `/oh-my-claudecode:plan` or `/ralplan` for planning:

**Tech Spec Template:**
```markdown
## Tech Spec
Goal: [one sentence]
Tech: [lang/framework]
Risks: [breaking changes]
Compatibility: [how to ensure]

## Tasks
- [ ] Task 1: [desc] | Executor: CC/Codex | Files: [paths] | Constraints: [limits] | Acceptance: [criteria]
- [ ] Task 2: ...
```

**Plan Mode Note**: Use `/oh-my-claudecode:plan` instead of built-in Plan Mode (Shift+Tab), because:
- CC uses GLM which requires direct connection
- oh-my-claudecode's plan skill works with GLM
- The plan skill can handle the planning workflow

### Phase 3: Execution (Codex-First)
All code-related tasks are delegated to Codex via MCP:

**Codex MCP Call Example:**
```javascript
mcp__codex__codex({
  model: "o3",
  sandbox: "danger-full-access",
  approval-policy: "on-failure",
  prompt: "<structured prompt>"
})
```

**Session Management:**
- Save `conversationId` from first call
- Use `mcp__codex__codex_reply` for subsequent calls

**CRITICAL Requirements for Codex MCP calls:**
- `model`: "o3"` (or user's preferred model)
- `sandbox`: "danger-full-access"`
- `approval-policy: "on-failure"`

### Phase 4: Validation (Claude Code)
- [ ] Functionality ✓
- [ ] Tests ✓
- [ ] Types ✓
- [ ] Performance ✓
- [ ] No API break ✓
- [ ] Style ✓

- If issues, return to Phase 3

## Decision Flow

```
User Request → /plan (oh-my-claudecode) → Assess → Default to Codex for code → Only CC for trivial/non-code
```

## MCP Configuration

The Codex MCP is configured in `~/.claude.json` with proxy settings:
```json
{
  "mcpServers": {
    "codex": {
      "type": "stdio",
      "command": "codex",
      "args": ["mcp", "serve"],
      "env": {
        "HTTP_PROXY": "http://127.0.0.1:7897",
        "HTTPS_PROXY": "http://127.0.0.1:7897",
        "NO_PROXY": "localhost,127.0.0.1"
      }
    }
  }
}
```

## Collaboration Rules (Embedded in this skill)

This skill embeds collaboration rules directly, so it doesn't depend on system-level CLAUDE.md

### Core Principles
1. **Separation of concerns**: CC = brain (planning, search, decisions), Codex = hands (code generation, refactoring)
2. **Codex-First strategy**: Default to Codex for code tasks, CC only for trivial changes (<20 lines) and non-code work
3. **Zero-confirmation flow**: Pre-defined boundaries, auto-execute within limits

### CC Responsibilities
- Plan, search (WebSearch/Glob/grep), decide, coordinate Codex
- Trivial changes only: typo fixes, comment updates, simple config tweaks (<20 lines)
- No final code in planning phase
- Delegate all code generation/refactoring to Codex

### Codex Participation Priority
Maximize Codex involvement for all code-related tasks
- Single function modification → Codex
- Adding a new method → Codex
- Refactoring logic → Codex
- Bug fixes → Codex
- Only skip Codex for: typo fixes, comment-only changes, trivial config tweaks (<20 lines)

## Routing Matrix

| Task | Executor | Trigger | Reason |
|------|----------|---------|--------|
| Code changes | **Codex** | Any code modification | Strong generation |
| Single-file edit | **Codex** | Even <50 lines if involves logic/code | Better code understanding |
| Multi-file refactor | **Codex** | >1 file with code changes | Global understanding |
| New feature | **Codex** | Any new functionality | Strong generation |
| Bug fix | **Codex** | Need trace or logic fix | Strong search + fix |
| Trivial changes | **CC** | Typos, comments, simple configs (<20 lines) | Too simple for Codex |
| Non-code work | **CC** | Pure .md/.json/.yaml (no logic) | No code generation needed |
| Architecture | **CC** | Pure design decision | Planning strength |

## Success Metrics
- **Efficiency**: 90% auto (no manual confirm) | <2min avg cycle | >80% first-time success
- **Quality**: Zero API break | Test coverage maintained | No performance regression
- **Experience**: Clear breakdown | Transparent progress | Recoverable errors

## Anti-Patterns (AVOID)
| Pattern | Problem | Fix |
|---------|---------|-----|
| CC doing code work | Waste Codex's strength | Use Codex for all code changes (even simple) |
| No boundaries | High failure, breaks code | Structured prompt required |
| Confirmation loops | Low efficiency | Pre-define auto boundaries |
| Ignoring Codex for "simple" edits | Miss code quality improvements | Default to Codex unless trivial (<20 lines typo/comment) |
| Vague tasks | Codex can't understand | Specific, measurable, verifiable |
| Ignore compatibility | Break user code | Explain in Constraints |

## Examples

### Simple Task
```
/cc-codex-flow Add a helper function to validate email addresses
```

### Complex Task
```
/cc-codex-flow Implement user authentication with JWT tokens and including login, registration, password reset, and profile management
```

### Refactoring Task
```
/cc-codex-flow Refactor the data processing module to use the functional pipeline pattern for better testability
```

## Notes
- Codex MCP requires proxy configured in ~/.claude.json
- Claude Code uses GLM direct connection
- Plan mode uses oh-my-claudecode's /plan or or `/ralplan`
- This skill is self-contained and doesn't modify system-level CLAUDE.md
