---
name: cc-codex-flow
description: Collaborative development workflow using Claude Code and Codex together. Use this skill when the user wants to leverage both Claude Code (for planning, search, architecture) and Codex (for code generation, refactoring, bug fixes) in a coordinated workflow. Triggers on phrases like "cc codex", "codex collaboration", "collaborative coding", or when complex development tasks would benefit from dual-AI orchestration.
license: MIT
---

# CC + Codex Collaborative Development

Orchestrate Claude Code (GLM) and Codex (OpenAI) working together for superior development outcomes.

## Purpose

This skill coordinates two AI systems:
- **Claude Code (GLM)**: Planning, code search, architecture decisions, validation
- **Codex (OpenAI)**: Code generation, refactoring, implementation, bug fixes

The workflow maximizes each AI's strengths while compensating for their limitations.

## When to Activate

- User explicitly mentions collaborative coding between Claude Code and Codex
- Complex tasks requiring both planning and heavy code generation
- Refactoring or implementation tasks where dual verification adds value
- User asks for "cc codex" or similar phrases

## Environment Configuration

### Claude Code Environment
- Model: GLM (direct connection, no proxy required)
- Role: Orchestrator, planner, validator

### Codex Environment
- Model: gpt-5.4 (configured in ~/.codex/config.toml)
- Proxy: Required for OpenAI API access (port 7897)
- MCP Configuration in `~/.claude.json`:

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

## Workflow

### Phase 1: Information Collection (Claude Code)

Gather context using available tools:
- WebSearch: Latest documentation and best practices
- Glob/Grep: Analyze existing code structure
- Read: Understand current implementation

Output: Context report covering tech stack, relevant files, patterns, and potential risks.

### Phase 2: Task Planning

Create a structured plan using this template:

```markdown
## Tech Spec
Goal: [Single sentence objective]
Tech: [Language/framework/libraries]
Risks: [Potential breaking changes]
Compatibility: [How to preserve existing behavior]

## Tasks
- [ ] Task 1: [Description]
  - Executor: Codex
  - Files: [Paths]
  - Constraints: [Limitations]
  - Acceptance: [Verification criteria]
```

### Phase 3: Execution (Codex-First)

Delegate code tasks to Codex via MCP:

```
mcp__codex__codex({
  "model": "gpt-5.4",
  "sandbox": "danger-full-access",
  "approval-policy": "on-failure",
  "prompt": "<structured prompt with context, task, constraints, acceptance criteria>"
})
```

**Session Management:**
- Capture `threadId` from the response
- Use `mcp__codex__codex-reply` for follow-up messages:
  ```
  mcp__codex__codex-reply({
    "threadId": "<saved-thread-id>",
    "prompt": "<next instruction>"
  })
  ```

### Phase 4: Validation (Claude Code)

Verify the implementation:
- [ ] Functionality works as expected
- [ ] Tests pass (if applicable)
- [ ] No type errors
- [ ] Performance acceptable
- [ ] No API breakage
- [ ] Code style consistent

If issues found, return to Phase 3 with specific fixes.

## Routing Matrix

| Task Type | Executor | Rationale |
|-----------|----------|-----------|
| Code changes | Codex | Strong code generation |
| New features | Codex | Better implementation quality |
| Bug fixes | Codex | Better code understanding |
| Refactoring | Codex | Global code comprehension |
| Architecture | Claude Code | Planning strength |
| Documentation | Claude Code | No code generation needed |
| Trivial edits (<20 lines) | Claude Code | Too simple for Codex overhead |

## Codex Prompt Template

When calling Codex, use this structure:

```markdown
## Context
- Tech Stack: [language/framework/version]
- Files: [path]: [purpose]
- Reference: [file for pattern/style]

## Task
[Clear, specific, verifiable task]

Steps:
1. [First step]
2. [Second step]
3. [Third step]

## Constraints
- API: Don't change [signatures]
- Performance: [requirements]
- Style: Follow [reference file]
- Scope: Only modify [specified files]
- Dependencies: No new deps without approval

## Acceptance Criteria
- [ ] Tests pass
- [ ] Types compile
- [ ] Linter clean
- [ ] [Project-specific criteria]
```

## Anti-Patterns

| Pattern | Problem | Solution |
|---------|---------|----------|
| Claude Code writing code | Wastes Codex strength | Delegate to Codex |
| Vague Codex prompts | Poor output quality | Use structured template |
| Skipping validation | Hidden bugs | Always run Phase 4 |
| Missing threadId | Lost context | Save and reuse threadId |
| Ignoring constraints | Breaks existing code | Document all constraints |

## Success Metrics

- **Efficiency**: >80% first-time success rate
- **Quality**: Zero API breakage, maintained test coverage
- **Speed**: <5 min average task completion

## Examples

### Simple Task
```
/cc-codex-flow Add email validation to the user registration form
```

### Complex Task
```
/cc-codex-flow Implement user authentication with JWT, including login, registration, password reset, and session management
```

### Refactoring Task
```
/cc-codex-flow Refactor the payment processing module to use the strategy pattern for multiple payment providers
```
