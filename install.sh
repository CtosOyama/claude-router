#!/bin/bash
# skill-router v4 — Universal Install Script
# Auto-detects macOS/Linux/Windows (Git Bash/WSL) and installs correctly
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
SKILL_NAME="skill-router"
SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_SKILLS=""

# ── Platform Detection ──────────────────────────────────
detect_platform() {
    case "$(uname -s)" in
        Darwin)  PLATFORM="macOS";  HOME_DIR="$HOME";;
        Linux)   PLATFORM="Linux";  HOME_DIR="$HOME";;
        MINGW*|MSYS*|CYGWIN*)
                  PLATFORM="Windows (Git Bash)"; HOME_DIR="$HOME";;
        *)       PLATFORM="Unknown"; HOME_DIR="$HOME";;
    esac
    CLAUDE_SKILLS="$HOME_DIR/.claude/skills"
}

# ── Check prerequisites ─────────────────────────────────
check_prereqs() {
    echo -e "${CYAN}┌─────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  skill-router v5 — Universal Installer   │${NC}"
    echo -e "${CYAN}│  Platform: ${YELLOW}$PLATFORM${CYAN}                      │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────┘${NC}"
    echo ""

    if [ ! -d "$CLAUDE_SKILLS" ]; then
        echo -e "${RED}✗ ~/.claude/skills/ not found. Is Claude Code installed?${NC}"
        echo "  Install Claude Code first: https://claude.ai/code"
        exit 1
    fi

    if [ -d "$CLAUDE_SKILLS/$SKILL_NAME" ]; then
        echo -e "${YELLOW}⚠ $SKILL_NAME already installed. Replacing...${NC}"
        rm -rf "$CLAUDE_SKILLS/$SKILL_NAME"
    fi

    echo -e "${GREEN}✓${NC} Claude Code found"
    echo -e "${GREEN}✓${NC} Platform: $PLATFORM"
}

# ── Install skill files ─────────────────────────────────
install_skill() {
    echo ""
    echo -e "${CYAN}Installing skill files...${NC}"

    if [ "$PLATFORM" = "Windows (Git Bash)" ]; then
        # Windows: copy (no symlink support in Git Bash by default)
        cp -r "$SKILL_DIR" "$CLAUDE_SKILLS/$SKILL_NAME"
        echo -e "${GREEN}✓${NC} Copied to $CLAUDE_SKILLS/$SKILL_NAME (Windows copy mode)"
    else
        # macOS/Linux: symlink (live-update when git pull)
        ln -sf "$SKILL_DIR" "$CLAUDE_SKILLS/$SKILL_NAME"
        echo -e "${GREEN}✓${NC} Symlinked to $CLAUDE_SKILLS/$SKILL_NAME"
    fi

    # Verify key files
    for f in "SKILL.md" "references/routing-table.md" "hooks/session-start.js" "hooks/session-start.sh"; do
        if [ -f "$CLAUDE_SKILLS/$SKILL_NAME/$f" ]; then
            echo -e "${GREEN}✓${NC} $f"
        else
            echo -e "${RED}✗${NC} $f MISSING"
        fi
    done
}

# ── Register hook ────────────────────────────────────────
register_hook() {
    echo ""
    echo -e "${CYAN}Registering SessionStart hook...${NC}"

    SETTINGS_FILE="$HOME_DIR/.claude/settings.local.json"
    HOOK_CMD=""

    # Pick the right hook command for this platform
    if command -v node &> /dev/null; then
        # Node.js: preferred cross-platform hook
        HOOK_CMD="node $CLAUDE_SKILLS/$SKILL_NAME/hooks/session-start.js"
        echo -e "${GREEN}✓${NC} Using Node.js hook (cross-platform)"
    elif [ "$PLATFORM" = "Windows (Git Bash)" ]; then
        # Windows fallback: PowerShell
        HOOK_CMD="powershell -ExecutionPolicy Bypass -File $CLAUDE_SKILLS/$SKILL_NAME/hooks/session-start.ps1"
        echo -e "${YELLOW}⚠${NC} Node.js not found. Using PowerShell fallback."
    else
        # macOS/Linux fallback: bash
        HOOK_CMD="bash $CLAUDE_SKILLS/$SKILL_NAME/hooks/session-start.sh"
        echo -e "${YELLOW}⚠${NC} Node.js not found. Using bash fallback."
    fi

    # Check if settings.local.json exists
    if [ ! -f "$SETTINGS_FILE" ]; then
        echo '{}' > "$SETTINGS_FILE"
        echo -e "${GREEN}✓${NC} Created $SETTINGS_FILE"
    fi

    # Check if hook already registered
    if grep -q "skill-router" "$SETTINGS_FILE" 2>/dev/null; then
        echo -e "${YELLOW}⚠${NC} Hook already registered. Skipping."
    else
        # Use python to merge JSON safely (available on all platforms)
        python3 -c "
import json, sys
with open('$SETTINGS_FILE') as f:
    cfg = json.load(f)
cfg.setdefault('hooks', {}).setdefault('SessionStart', []).append({
    'matcher': 'startup|clear|compact',
    'hooks': [{'type': 'command', 'command': '$HOOK_CMD'}]
})
with open('$SETTINGS_FILE', 'w') as f:
    json.dump(cfg, f, indent=2, ensure_ascii=False)
" 2>/dev/null && echo -e "${GREEN}✓${NC} Hook registered: $HOOK_CMD" || {
            echo -e "${RED}✗${NC} Failed to register hook. Add manually:"
            echo "  $HOOK_CMD"
        }
    fi
}

# ── Verify installation ─────────────────────────────────
verify() {
    echo ""
    echo -e "${CYAN}Verifying installation...${NC}"

    # Test hook output
    if command -v node &> /dev/null; then
        if node "$CLAUDE_SKILLS/$SKILL_NAME/hooks/session-start.js" 2>/dev/null | grep -q "Router v5"; then
            echo -e "${GREEN}✓${NC} Hook script works (Node.js)"
        else
            echo -e "${RED}✗${NC} Hook script failed"
        fi
    else
        echo -e "${YELLOW}⚠${NC} Skipping hook test (Node.js not available)"
    fi

    # Count skills
    COUNT=$(ls -1 "$CLAUDE_SKILLS" 2>/dev/null | wc -l | tr -d ' ')
    echo -e "${GREEN}✓${NC} $COUNT skills in $CLAUDE_SKILLS"
}

# ── Done ─────────────────────────────────────────────────
done_msg() {
    echo ""
    echo -e "${GREEN}┌─────────────────────────────────────────┐${NC}"
    echo -e "${GREEN}│  ✅ skill-router v5 installed!           │${NC}"
    echo -e "${GREEN}└─────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${CYAN}Next steps:${NC}"
    echo -e "  1. Restart Claude Code (or /clear)"
    echo -e "  2. The router activates automatically"
    echo -e "  3. Missing a skill? Just ask: \"帮我用 web-access 找一个\""
    echo ""
    echo -e "  ${CYAN}Platform:${NC} $PLATFORM"
    echo -e "  ${CYAN}Hook:${NC} $HOOK_CMD"
    echo -e "  ${CYAN}Skills directory:${NC} $CLAUDE_SKILLS"
    echo ""
    echo -e "  ${CYAN}Uninstall:${NC} rm -rf $CLAUDE_SKILLS/$SKILL_NAME"
    echo -e "  ${CYAN}Update:${NC} cd $SKILL_DIR && git pull"
    echo ""
}

# ── Run ──────────────────────────────────────────────────
detect_platform
check_prereqs
install_skill
register_hook
verify
done_msg
