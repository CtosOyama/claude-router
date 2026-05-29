---
name: skill-router
description: >-
  Use when the user asks which skill or tool to use for a task, or when
  you detect a task requiring 2+ skills chained together (e.g. "research X
  and make slides"). The SessionStart hook injects a dynamic routing context
  with installed skill count, desktop file hints, and orchestration patterns.
  DO NOT invoke for single-step tasks where the right skill is obvious.
---

# Skill Router

When invoked, scan `references/routing-table.md` for the current skill index and orchestration patterns. Then:

1. Match user intent to the best skill from the routing table
2. Detect multi-step tasks needing sequential (A→B) or parallel (A∥B) chaining
3. Verify referenced skills exist before suggesting them
4. If no match: fuzzy → generic → ask user for direction

## Quick Reference

| Scenario | Action |
|---|---|
| User unsure which tool | Scan routing table, suggest top match |
| Multi-step task | Propose orchestration chain (e.g., deep-research → wowerpoint) |
| Skill may not exist | Verify against routing table first |
| User already named a skill | Respect it, do not override |

## Orchestration Patterns

| Pattern | Syntax | Example |
|---|---|---|
| Sequential | A → B | deep-research → doc-coauthoring |
| Parallel | A ∥ B | review ∥ security-review |
| Forced | code → review | any code change → review |

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/CtosOyama/claude-router/main/install-remote.sh | bash
```

## Files

```
skill-router/
├── SKILL.md                 This file
├── hooks/
│   ├── session-start.js     Node.js hook (preferred)
│   ├── session-start.sh     Bash fallback
│   └── session-start.ps1    PowerShell fallback
├── references/
│   └── routing-table.md     Skill index + orchestration patterns
├── install.sh               Manual installer
└── install-remote.sh        One-command installer
```
