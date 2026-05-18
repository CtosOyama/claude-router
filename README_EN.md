<div align="right">

**English** | [**中文**](./README.md)

</div>

# Skill Router

> Always-on intent routing layer for Claude Code — 53 skills, one dispatcher, zero config.

---

## What It Does

Every time you talk to Claude Code, Skill Router runs silently in the background asking one question: **"Which skill fits this request best?"**

Think of it as a smart dispatcher:

| Step | What Happens | Analogy |
|---|---|---|
| 🚨 | Checks for emergencies first ("help", "down", "urgent") → routes immediately | 911 operator |
| 🔍 | Scans your desktop, folders, history → understands your context | "Where are you right now?" |
| 🎯 | Extracts: what action + what domain + what scope | Understanding your request |
| 📊 | Scores every candidate skill → highest score wins | Deciding which department |
| 🔗 | One skill not enough? → chains or fans out multiple | Conference-calling departments |
| 🛟 | No clear match? → fuzzy search → generic handling → asks you | "Let me get a supervisor" |
| 📚 | Tracks every outcome → reinforces good routes, corrects bad ones → learns | Veteran dispatcher knows your habits |

---

## Quick Examples

Say something ordinary — it finds the right skill:

| You Say | Router Invokes |
|---|---|
| "Help me process this PDF" | `pdf` |
| "Turn this Excel into a chart" | `xlsx` |
| "Write a research report on this" | `deep-research` → `doc-coauthoring` (chain) |
| "Find video tutorials on this tech" | `youtube-search` |
| "Make a study plan (use everything)" | `doc-coauthoring` ∥ `youtube-search` ∥ `web-access` (parallel) |
| "Review this code" | `review` |
| "How did we fix that bug last time?" | `mem-search` |
| "Help, production is down!" | 🚨 Emergency → route immediately |

---

## Install

### macOS / Linux — one command

```bash
curl -fsSL https://raw.githubusercontent.com/CtosOyama/claude-router/main/install-remote.sh | bash
```

### Windows — one command

```powershell
git clone https://github.com/CtosOyama/claude-router.git $env:TEMP\skill-router; cd $env:TEMP\skill-router; powershell -ExecutionPolicy Bypass -File install.ps1
```

### Manual install

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

3. Restart Claude Code

---

## Files

```
skill-router/
├── SKILL.md                 Full routing algorithm docs
├── README.md                You're reading this (English)
├── README.md                Chinese version
├── index.html               Bilingual website
├── install.sh               macOS/Linux installer
├── install.ps1              Windows installer
├── install-remote.sh        Remote one-line installer
├── hooks/
│   ├── session-start.js     Node.js hook (preferred)
│   ├── session-start.sh     Bash fallback
│   └── session-start.ps1    PowerShell fallback
└── references/
    └── routing-table.md     53-skill routing table
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
