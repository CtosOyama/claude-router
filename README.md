# skill-router

> Always-on intent routing layer for Claude Code. 53 skills, one dispatcher, zero config.

skill-router sits alongside claude-mem in every Claude Code session. Before you respond to any request, it silently checks: *"is there a specialized skill for this?"* — and routes to it.

---

## Install

### macOS / Linux — one command

```bash
curl -fsSL https://raw.githubusercontent.com/ctosOyama/skill-router/main/install-remote.sh | bash
```

### Windows — one command

```powershell
git clone https://github.com/ctosOyama/skill-router.git $env:TEMP\skill-router; cd $env:TEMP\skill-router; powershell -ExecutionPolicy Bypass -File install.ps1
```

### Manual (all platforms)

1. Copy this repo to `~/.claude/skills/skill-router/`
2. Add to `~/.claude/settings.local.json`:

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "startup|clear|compact",
      "hooks": [{
        "type": "command",
        "command": "node ~/.claude/skills/skill-router/hooks/session-start.js"
      }]
    }]
  }
}
```

3. Restart Claude Code.

---

## What It Does

```
Your message → Emergency? → Context Scan → Intent Parse → Confidence Score
                                                         │
                    ┌──────────┬──────────┬──────────────┤
                    ▼          ▼          ▼              ▼
                 ≥90:        70-89:    50-69:         <50:
              Route now   Route+watch  Low conf    Clarify (3 options)
                    │          │          │              │
                    └──────────┴──────────┴──────────────┘
                                        │
                          Match? ──→ Invoke Skill
                              │
                          No Match? ──→ L1 Fuzzy → L2 Generic → L3 Human+web-access
                                        │
                                   LEARN: track +2/+1/-1/-2 signals, auto-adapt
```

| | |
|---|---|
| **8-step algorithm** | Emergency → Context → Intent → Confidence → Match → Orchestrate → Fallback → Learn |
| **53 skills covered** | Content creation, documents, web research, coding, agent infra, and more |
| **Always-on** | SessionStart hook injects routing layer, no manual invocation |
| **Chinese + English** | Full Chinese trigger words, hybrid intent recognition |
| **3-layer fallback** | Fuzzy match → generic handling → human + web-access GitHub search |
| **Self-learning** | Tracks user corrections, auto-promotes/demotes routes, adapts thresholds |
| **Cross-platform** | macOS / Linux / Windows, Node.js hook with bash/PS1 fallbacks |
| **Zero dependencies** | Pure markdown + shell + Node.js — no Docker, no database |

---

## Quick Example

| You say | Router invokes |
|---|---|
| "帮我看看这篇稿子能不能火" | `cheat-score` (or `cheat-init` if first time) |
| "把这俩 Excel 合并做图表" | `xlsx` |
| "深入研究 AI agent 融资写报告" | `deep-research` → `doc-coauthoring` |
| "写日本留学学习计划" | `doc-coauthoring` ∥ `youtube-search` ∥ `mem-search` |
| "上次那个 bug 怎么修的" | `mem-search` |
| "审查这个 PR" | `review` |
| "救命线上崩了" | 🚨 Emergency → route immediately |

---

## Files

```
skill-router/
├── SKILL.md                    Full routing algorithm + feature docs
├── README.md                   You're reading it
├── install.sh                  macOS/Linux one-command installer
├── install.ps1                 Windows PowerShell installer
├── hooks/
│   ├── session-start.js        Node.js cross-platform hook (preferred)
│   ├── session-start.sh        Bash fallback (macOS/Linux)
│   └── session-start.ps1      PowerShell fallback (Windows)
└── references/
    └── routing-table.md        53-skill routing map with patterns
```

---

## Uninstall

```bash
rm -rf ~/.claude/skills/skill-router
# then remove the hook entry from ~/.claude/settings.local.json
```

## Update

```bash
cd /tmp/skill-router && git pull
# symlink auto-updates on macOS/Linux. On Windows: re-run install.ps1
```
