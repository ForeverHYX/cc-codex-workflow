#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────────
# CC + Codex Collaborative Workflow — Installer
#
# Usage:
#   ./install.sh              # Install skill
#   ./install.sh --uninstall  # Remove skill
#   ./install.sh --help       # Show help
# ──────────────────────────────────────────────────

SKILL_NAME="cc-codex-flow"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_SRC="$SCRIPT_DIR/Skill.md"

CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
SKILL_DEST="$CLAUDE_SKILLS_DIR/$SKILL_NAME"

# Colors
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[ OK ]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
die()   { echo -e "${RED}[FAIL]${NC} $*"; exit 1; }

# ── Prerequisites ──────────────────────────────────

check_prerequisites() {
    [[ -f "$SKILL_SRC" ]] || die "Skill file not found: $SKILL_SRC"

    if ! command -v claude &>/dev/null; then
        warn "'claude' CLI not found in PATH — skill will install but won't activate until Claude Code is installed."
    fi

    if ! command -v codex &>/dev/null; then
        warn "'codex' CLI not found. Install with: npm install -g @openai/codex"
    fi

    if ! command -v python3 &>/dev/null; then
        warn "'python3' not found. MCP configuration will be skipped."
    fi
}

# ── Install skill ──────────────────────────────────

install_skill() {
    info "Installing skill to $SKILL_DEST ..."

    # Create ~/.claude/skills/ if needed
    mkdir -p "$CLAUDE_SKILLS_DIR"

    # Remove previous installation
    if [[ -e "$SKILL_DEST" || -L "$SKILL_DEST" ]]; then
        info "Replacing previous installation ..."
        rm -rf "$SKILL_DEST"
    fi

    # Copy skill folder with SKILL.md (Claude Code standard entry point)
    mkdir -p "$SKILL_DEST"
    cp "$SKILL_SRC" "$SKILL_DEST/SKILL.md"

    ok "Skill installed: $SKILL_DEST/SKILL.md"
}

# ── Configure Codex MCP (optional) ────────────────

configure_mcp() {
    local claude_json="$HOME/.claude.json"

    if ! command -v python3 &>/dev/null; then return; fi
    if [[ ! -f "$claude_json" ]]; then
        warn "~/.claude.json not found — skipping MCP config."
        return
    fi

    # Check if codex MCP already exists
    if python3 -c "
import json, sys
with open('$claude_json') as f:
    data = json.load(f)
sys.exit(0 if 'codex' in data.get('mcpServers', {}) else 1)
" 2>/dev/null; then
        ok "Codex MCP already configured in ~/.claude.json."
        return
    fi

    echo ""
    info "Codex MCP server is not configured in ~/.claude.json."
    read -rp "Add Codex MCP configuration now? [y/N] " answer
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        warn "Skipped. You can configure it later (see README.md)."
        return
    fi

    read -rp "Proxy address [http://127.0.0.1:7897]: " proxy
    proxy="${proxy:-http://127.0.0.1:7897}"

    python3 -c "
import json
path = '$claude_json'
with open(path) as f:
    data = json.load(f)
data.setdefault('mcpServers', {})['codex'] = {
    'type': 'stdio',
    'command': 'codex',
    'args': ['mcp-server'],
    'env': {
        'HTTP_PROXY': '$proxy',
        'HTTPS_PROXY': '$proxy',
        'NO_PROXY': 'localhost,127.0.0.1'
    }
}
with open(path, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')
" || warn "Failed to update ~/.claude.json — please configure manually."

    ok "Codex MCP configured (proxy: $proxy)"
}

# ── Verify ─────────────────────────────────────────

verify() {
    echo ""
    if [[ -f "$SKILL_DEST/SKILL.md" ]]; then
        ok "Verified: $SKILL_DEST/SKILL.md"
        echo ""
        ok "Done! Restart Claude Code (or start a new session) to activate."
        echo ""
        echo "  Usage: /cc-codex-flow <task description>"
    else
        die "Installation failed — SKILL.md not found at $SKILL_DEST"
    fi
}

# ── Uninstall ──────────────────────────────────────

uninstall() {
    info "Uninstalling $SKILL_NAME ..."
    if [[ -e "$SKILL_DEST" || -L "$SKILL_DEST" ]]; then
        rm -rf "$SKILL_DEST"
        ok "Removed: $SKILL_DEST"
    else
        warn "Skill not installed — nothing to remove."
    fi
    echo ""
    ok "Done. Restart Claude Code to apply."
}

# ── Main ───────────────────────────────────────────

usage() {
    cat <<EOF
CC + Codex Collaborative Workflow — Installer

Usage:
  $0              Install the skill into ~/.claude/skills/
  $0 --uninstall  Remove the skill
  $0 --help       Show this message
EOF
}

main() {
    echo -e "${CYAN}━━━ CC + Codex Collaborative Workflow ━━━${NC}"
    echo ""

    case "${1:-}" in
        --uninstall|-u) uninstall ;;
        --help|-h)      usage ;;
        "")
            check_prerequisites
            echo ""
            install_skill
            configure_mcp
            verify
            ;;
        *)  die "Unknown option: $1 (try --help)" ;;
    esac
}

main "$@"
