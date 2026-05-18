---
name: skill-router
description: >-
  ALWAYS-ON routing layer bound with claude-mem. Injected into context via
  SessionStart hook on every session. Before ANY response, check if a specialized
  skill can handle the request better than native reasoning. Routes user intent
  to the best of 50+ installed skills silently. Supports multi-skill orchestration
  (sequential chains, parallel fan-out), confidence scoring, interactive clarification
  for ambiguous intents, conflict resolution, 3-layer fallback (fuzzy→generic→human),
  emergency routing for urgent requests, and a self-learning system that adapts routing
  thresholds based on user feedback signals.
  DO NOT use this skill only for obvious "find a tool" queries — it should
  activate preemptively on EVERY user request to route it to the right specialist.
  Only skip routing when: user named a specific skill, task is trivial one-step,
  or request is purely conversational.
argument-hint: "[user message to route]"
compatibility: "Cross-platform: macOS/Linux/Windows. Requires Skill tool + SessionStart hook + claude-mem"
platforms:
  darwin: "Node.js hook (session-start.js) or bash fallback (session-start.sh)"
  linux: "Node.js hook (session-start.js) or bash fallback (session-start.sh)"
  win32: "Node.js hook (session-start.js) or PowerShell fallback (session-start.ps1)"
always-on: true
bound-with: "claude-mem"
hook: "hooks/session-start.sh → SessionStart (startup|clear|compact)"
integrated-from:
  - "aiskillstore/router — confidence formula + structured intent + conflict resolution"
  - "charon-fan/skill-router — multi-skill orchestration + interactive clarification"
  - "memex-claude — match telemetry"
  - "VCnoC/main-router — forced workflow chains"
---

# Skill Router — Silent Intent → Best Skill Dispatcher

## 📦 Installation

### macOS / Linux
```bash
git clone https://github.com/ctosOyama/skill-router.git /tmp/skill-router
cd /tmp/skill-router
bash install.sh
```
The installer: symlinks the skill → registers the SessionStart hook → verifies everything works.

### Windows (PowerShell)
```powershell
git clone https://github.com/ctosOyama/skill-router.git $env:TEMP\skill-router
cd $env:TEMP\skill-router
powershell -ExecutionPolicy Bypass -File install.ps1
```
The installer: copies the skill (no symlink on Windows) → registers the hook → verifies.

### Manual Install (all platforms)
1. Copy `skill-router/` to `~/.claude/skills/skill-router/` (macOS/Linux) or `%USERPROFILE%\.claude\skills\skill-router\` (Windows)
2. Register the hook in `~/.claude/settings.local.json`:
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

You are a **routing layer**, not a chatbot. Your only job: figure out what the user is really trying to do, find the best skill for it, and invoke it.

## Capability Overview

```
EMERGENCY? ──→ skip scan, route now, parallel if tied
     │
     ▼
CONTEXT SCAN ──→ ~/ files, CWD, mem-search, "use all tools" signal
     │
     ▼
INTENT PARSE ──→ 17 actions × 10 domains × scope × urgency
     │
     ▼
CONFIDENCE ────→ (intentMatch×0.5)+(contextRelevance×0.3)+((1-ambiguity)×0.2)
     │
     ├── ≥90 → ROUTE NOW (document alternatives)
     ├── 70-89 → ROUTE (watch for corrections)
     ├── 50-69 → ROUTE + note low confidence
     └── <50 → CLARIFY (3 options, don't guess)
     │
     ▼
ORCHESTRATE ───→ Single | Sequential(A→B) | Parallel(A∥B∥C) | Forced(code→review)
     │
     ├── Match → Invoke Skill
     └── No Match → L1 Fuzzy → L2 Generic → L3 Human+web-access
     │
     ▼
LEARN ────────→ +2(confirmed)/+1(ok)/-1(ignored)/-2(corrected)
                 net≥+3→stable | net≤-2→unreliable
```

| Capability | Description |
|---|---|
| **8-Step Algorithm** | Emergency → Context → Intent → Confidence → Match → Orchestrate → Fallback → Learn |
| **53-Skill Routing** | 10 categories: content(14), docs(10), web(3), planning(6), quality(4), comms(2), agent(6), API(2), tools(4), design(3) |
| **Always-On Hook** | SessionStart injection alongside claude-mem, ~200 tokens, macOS/Linux/Windows |
| **Chinese+English** | Full Chinese trigger words for cheat-on-content ecosystem, hybrid intent recognition |
| **Context Scan** | Reads ~/ and Desktop files, CWD state, mem-search history to personalize routing |
| **Confidence Formula** | Weighted score across intent match (50%), context relevance (30%), ambiguity (20%) |
| **3-Layer Fallback** | L1: fuzzy substring match → L2: native Claude or generic skill → L3: human + web-access GitHub search |
| **Emergency Mode** | Detects urgent/critical/立刻/救命, skips context scan, parallel fan-out if tied |
| **Multi-Skill Orchestration** | Sequential chains (A→B), parallel fan-out (A∥B∥C), forced workflows (code→review) |
| **Conflict Resolution** | Fixes beat reviews, blocking first, specific beats general, user history wins ties |
| **Self-Learning** | Tracks +/- signals per intent→skill pair, auto-promotes/demotes, adapts confidence threshold |
| **Interactive Clarification** | When confidence <50, presents 3 concrete options mapped to specific skills |
| **State Gate** | Auto-redirects cheat-* requests to cheat-init when .cheat-state.json is missing |
| **Zero Dependencies** | Pure markdown + shell + Node.js, no Docker, no database, no Neo4j |
| **Cross-Platform** | One codebase for macOS/Linux/Windows, Node.js hook auto-detects OS |

### Integrated from Competitors

| Source | Integrated Features |
|---|---|
| **aiskillstore/router** | Confidence formula, structured intent extraction, conflict resolution, emergency routing, 3-layer fallback, learning system |
| **charon-fan/skill-router** | Multi-skill orchestration (Sequential + Parallel), interactive clarification |
| **VCnoC/main-router** | Forced workflow chains (code→review, security→audit) |
| **memex-claude** | Route telemetry (upgraded into learning system) |

### What We Have That Competitors Don't

- Always-On SessionStart hook (no manual invocation needed)
- Full Chinese trigger words + hybrid CN/EN routing
- Context-aware scanning of ~/ + Desktop + CWD
- cheat-on-content state gate integration
- Zero infrastructure (competitors require Docker/Neo4j/MCP servers)

---

## Core Principle

```
User message → [Emergency?] → Intent → Confidence → Route/Orchestrate/Clarify
                                              ↓ (no match)
                                         3-Layer Fallback
```

- **Emergency detected?** → skip context scan, route immediately
- **Ambiguous?** → Interactive Clarification (Step 5)
- **Multi-step?** → Orchestrate chain (Step 4)
- **No match?** → 3-Layer Fallback (Step 7)
- **User confirms/corrects?** → Learning System logs signal (Step 8)

---

## Routing Algorithm (8 steps)

### Step -1: Emergency Detection (before any other step)

Check user message for **urgency signals**. If detected, SKIP Step 0.5 (context scan) and route immediately:

**Urgency keywords:** 紧急 / urgent / critical / critical / "now" / "ASAP" / "立刻" / "马上" / "崩了" / "挂了" / "broke" / "production down" / "broken" / blocking / "救命"

**Emergency mode behavior:**
1. Skip context scan entirely (save 10s)
2. Pick the highest-confidence match from the routing table WITHOUT clarification
3. If 2+ skills match equally → **Parallel Fan-out** (invoke all at once, aggregate results)
4. Prefix routing with 🚨 signal so downstream skills know this is urgent
5. Emergency route log format: `[ROUTE] 🚨 {skill} | EMERGENCY | no-context-scan`

### Step 0.5: Context Scan (< 30 seconds)

Quick environment scan. Parallel where possible:

1. **Home directory**
   - macOS/Linux: `ls ~/ | head -30`, `ls ~/Desktop/ | head -20`
   - Windows: `dir %USERPROFILE% /B`, `dir %USERPROFILE%\Desktop /B`
2. **CWD**
   - macOS/Linux: `pwd && ls | head -20`
   - Windows: `cd && dir /B`
   - Check: .cheat-state.json? package.json? go.mod?
3. **"Use all tools" signal** — same triggers as before
4. **Recurring topics** — mem-search for prior session patterns

Output 2-3 bullets. Skip if nothing obvious.

### Step 0.6: Proactive Multi-Skill Mode

When "use all tools" signal detected:
1. Always add `mem-search` as secondary
2. Learning/study → add `youtube-search`
3. Content creation → add `cheat-trends`
4. Technical → add `deep-research`
5. Document output → optionally add `theme-factory`

### Step 1: Structured Intent Extraction

Extract and score these five dimensions:

```
IntentAnalysis {
  action:     fix | review | document | test | plan | explore | commit | build | deploy | optimize | create | analyze | search | publish | learn | convert | merge
  domain:     content | web | document | code | memory | design | infrastructure | learning | data | communication
  scope:      single-step | multi-step | multi-session
  urgency:    now | soon | planning
  artifacts:  [file paths, extensions, URLs mentioned]
}
```

**Action verb mapping** — the action verb is the STRONGEST signal:
- "修/改/fix/debug/报错/bug" → fix → code-review or security-review
- "审查/review/检查/audit" → review → review or security-review
- "写/撰/生成/create/make/generate" → create → depends on domain
- "搜/找/查/search/find/lookup" → search → mem-search or web-access or youtube-search
- "计划/规划/plan/phase/roadmap" → plan → make-plan (code) or doc-coauthoring (non-code)
- "部署/deploy/publish/release" → deploy → claude-code-plugin-release
- "优化/optimize/improve performance" → optimize → cost-aware-llm-pipeline or simplify
- "学/study/learn/学习" → learn → doc-coauthoring + youtube-search + mem-search

### Step 2: Confidence Scoring Formula

For each candidate skill, calculate:

```
score = (intentMatch × 0.5) + (contextRelevance × 0.3) + ((1 - ambiguity) × 0.2)
```

Where:
- **intentMatch** (0-1): how well the action verb + domain match the routing table entry
- **contextRelevance** (0-1): how well the context scan findings support this skill (files in ~/ match? prior sessions match?)
- **ambiguity** (0-1): inverse — if user's intent could mean 3+ different things, ambiguity is high

Convert to confidence:
- score ≥ 0.9 → **100 confidence** (route immediately)
- score 0.7-0.89 → **90 confidence** (route with high confidence)
- score 0.5-0.69 → **70 confidence** (route but watch for fallback)
- score < 0.5 → **50 or below** → trigger **Interactive Clarification** (Step 5)

### Step 3: Match Against Routing Table

Read `references/routing-table.md`. Apply match priorities:

1. **File extension** (.pdf/.xlsx/.docx/.pptx/.csv) → strongest signal, route immediately. Still document alternatives.
2. **Exact trigger word** (confidence 100) → route immediately. Still document alternatives.
3. **Domain + action combo** (confidence 70-90) → route with confidence level noted
4. **Context-based** → .cheat-state.json state gate, personal context from Step 0.5
5. **Personal context** → prior session patterns, files in ~/

### Step 4: Multi-Skill Orchestration

> For specific scene→pattern→skills mappings, see **routing-table.md: Orchestration Pattern Reference**.

When user intent requires 2+ skills, choose the right orchestration pattern:

**Pattern A: Sequential Chain** (output of skill A is input to skill B)
```
Skill A → Skill B → Skill C
Example: deep-research (gather data) → doc-coauthoring (write report)
Example: make-plan (create plan) → do (execute plan)
```

**Pattern B: Parallel Fan-out** (independent tasks with shared goal)
```
       ┌→ Skill A (research Japanese academic environment)
User → ┼→ Skill B (search YouTube for JLPT study resources)
       └→ Skill C (search memory for prior study plans)
                        ↓
              Skill D (doc-coauthoring — synthesize into plan)
```

**Pattern C: Forced Workflow** (mandatory chain, from VCnoC)
```
Code generation → code review (MANDATORY)
Security-sensitive → security-review (MANDATORY)
cheat-score → cheat-predict (before publishing)
```

**Orchestration decision rules:**
- If skill A's output feeds into skill B → Sequential Chain
- If 2+ skills can run independently → Parallel Fan-out
- If the domain has a forced workflow rule → apply it, don't skip

### Step 5: Interactive Clarification

When confidence < 50 OR ambiguity > 0.5:

**Don't guess. Ask.** Present a focused question (not an open-ended "what do you want?"):

```
我看到你的请求中有几种可能性。你更想让我：

1. [具体选项A — 对应 skill X] — "用 deep-research 做一份详细的研究报告"
2. [具体选项B — 对应 skill Y] — "用 web-access 快速浏览几个网站找答案"
3. [具体选项C — 自己处理] — "不用 skill，直接告诉我"

哪一个更接近你想要的？
```

**Rules for clarification:**
- Maximum 3 options. Never more.
- Each option maps to a concrete skill or action
- Never ask "what do you want to do?" — always give specific paths
- If user ignores clarification and says "just do it" → pick #1 and go

### Step 6: Conflict Resolution

When 2+ skills are equally valid candidates, apply these tiebreakers:

1. **Fixes beat reviews** — if one skill fixes a problem and another reviews it, route to fix first
2. **Blocking issues first** — if one task blocks another, route the blocker first
3. **Specific beats general** — `deep-research` beats `web-access` for research reports; `xlsx` beats `canvas-design` for data charts
4. **User history wins ties** — if user has used skill A 3× more than skill B for similar requests, prefer A
5. **Mandatory chain wins** — if a forced workflow exists, execute the chain in order

---

## Invocation

```markdown
Skill(skill="<best-match>", args="<user message>")
```

For multi-skill chains, invoke sequentially (wait for first to complete, then second).

---

## When NOT to Route

- **User explicitly named a skill**: "use pdf skill to..." → respect it
- **Trivial one-step**: "2+2", "thanks", "ok", "ls"
- **Purely conversational**: "how are you", "tell me a joke"
- **Native tools sufficient**: simple "read this file", "list directory"

---

## Quick Reference

| User says... | Route to | Pattern |
|---|---|---|
| "帮我分析稿子/打分" | cheat-score (state gate → cheat-init) | Single |
| "处理 PDF/Excel/Word/PPT" | pdf/xlsx/docx/pptx | Single |
| "深入研究X/写分析报告" | deep-research → doc-coauthoring | Sequential |
| "搜视频/找教程" | youtube-search | Single |
| "写学习计划（把工具都用上）" | doc-coauthoring ∥ youtube-search ∥ mem-search | Parallel |
| "做功能/写plan" | make-plan → do | Sequential |
| "代码审查" | review | Single |
| "我上次怎么做的" | mem-search | Single |

---

## Common Pitfalls

1. "计划" → check domain. make-plan for code, doc-coauthoring for life/study
2. File extension is king — .pdf NEVER routes to xlsx
3. State gate ALWAYS checked before cheat-* routing
4. "打分" without .cheat-state.json → cheat-init, not cheat-score
5. "use all tools" → always trigger Proactive Multi-Skill Mode

---

## Step 7: 3-Layer Fallback (when no skill matches)

When confidence < 50 for ALL skills in the routing table, don't just fail. Escalate through 3 layers:

**Layer 1: Fuzzy Match** — scan all installed skill names for near matches
- Use simple substring/Levenshtein logic: does the user's intent word appear in any skill name or description?
- Example: user says "帮我压缩图片" → no exact match → fuzzy finds no "image-compress" skill → fall to Layer 2
- Example: user says "帮我commit代码" → fuzzy finds no "git" skill name (but we have nothing for git commits) → fall to Layer 2
- If fuzzy match finds a candidate with score ≥ 0.4 → route there with a note: "我没有找到完全匹配的 skill，但 `X` 看起来最接近。用这个试试？"

**Layer 2: General-Purpose Agent** — route to the best generic handler
- Coding/technical task → route to a general coding agent (native Claude coding, no specialized skill)
- Research/learning task → `deep-research` (even at low confidence, it's better than nothing)
- Content creation task → `cheat-seed` (for topic exploration) or native Claude writing
- Document task → native Claude (no specialized skill needed for basic operations)
- Unknown domain → native Claude with a note: "我用自己的能力处理这个。如果经常遇到这类请求，建议装一个专门的 skill。"

**Layer 3: Human-in-the-Loop** — only when Layer 2 also fails or user is clearly frustrated
- Output a clear, helpful message:

> ⚠️ 我没有找到处理这个请求的专用工具，也无法用通用能力替代。你可以：
> ① 自行下载对应 skill → `git clone <url> ~/.claude/skills/`
> ② 说"帮我用 web-access 找一个能做 X 的 skill"，我帮你在 GitHub 上找
> ③ 告诉我更多细节，也许我能换一种方式帮你

- If user picks ② → invoke `web-access` to search GitHub for relevant skills, guide through download + install

**Fallback decision tree:**
```
No match (all confidence < 50)
  → Layer 1: fuzzy match ≥ 0.4? → route with caveat
  → Layer 1 failed → Layer 2: can native Claude or a generic skill handle it? → handle natively
  → Layer 2 failed → Layer 3: human-in-the-loop, offer 3 options
```

---

## Step 8: Learning System (self-calibrating router)

The router improves over time by tracking signals from every routing decision. No external data needed — just observe user behavior.

### Signal Types

| Signal | Trigger | Effect |
|--------|---------|--------|
| **+2 (strong positive)** | User explicitly confirms the route ("对"/"yes"/"exactly") | Boost intent→skill pair confidence by 0.1 |
| **+1 (weak positive)** | User accepts route silently, task completes without correction | Slight boost: mark pair as "used" |
| **-1 (weak negative)** | User ignores the route and asks something different | Slight penalty: reduce pair relevance |
| **-2 (strong negative)** | User explicitly corrects ("不对"/"不是这个"/"I meant...") | Demote pair: set confidence ceiling to 70, force clarification next time |

### Stability Tracking

For each intent→skill pair, maintain a mental tally:
```
{action}+{domain} → {skill}: +2,+1,+1,-2 = net +2 (stable, low risk)
{action}+{domain} → {skill}: +1,-2,-2 = net -3 (unreliable, always clarify)
```

**Promotion threshold:** net ≥ +3 → pair is **stable**. Auto-route without clarification. Promote to Quick Reference if 5+ sessions.

**Demotion threshold:** net ≤ -2 → pair is **unreliable**. Always show Interactive Clarification (Step 5) for this pair, don't auto-route.

**Reset:** after 30 days of no activity, reset pair to neutral (net=0). Intent patterns change over time.

### Adaptive Thresholds

The confidence threshold for "route immediately vs. ask clarification" adapts based on overall learning health:

- **Start:** threshold = 90 (conservative — ask if unsure)
- **After 10+ stable pairs:** threshold = 70 (confident — route more)
- **After 3+ demotions:** threshold = 95 (regress — ask more, learning from mistakes)

### Learning Log Format

```
[LEARN] {intent} → {skill} | signal={+2/+1/-1/-2} | net={N} | status={stable|unreliable|neutral}
```

This is the log format from Match Telemetry v1 (now merged into Learning System):
```
[ROUTE] {skill} | intent={action}+{domain} | score={0.XX} | pattern={single|sequential|parallel}
```

### Self-Learning vs External Learning

- **Internal (this system)**: tracks routing accuracy, adjusts thresholds, promotes/demotes pairs
- **External (continuous-learning-v2)**: extracts instincts from full sessions, evolves skills — complementary, not redundant
- The Learning System feeds into continuous-learning-v2: when a pair becomes stable, suggest creating a dedicated skill or instinct for it

---

## Always-On Architecture

Skill-router injects via **SessionStart hook** alongside claude-mem:

```
SessionStart → claude-mem hook (memory context) → skill-router hook (routing layer) → Claude ready
```

### Hook Registration (cross-platform)

**Preferred (all platforms): Node.js hook**
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
Windows: replace `~/.claude/` with `%USERPROFILE%\\.claude\\` in the command.

**Fallback (macOS/Linux): bash**
```json
{"command": "bash ~/.claude/skills/skill-router/hooks/session-start.sh"}
```

**Fallback (Windows): PowerShell**
```json
{"command": "powershell -ExecutionPolicy Bypass -File %USERPROFILE%\\.claude\\skills\\skill-router\\hooks\\session-start.ps1"}
```

### Platform Detection

The Node.js hook auto-detects OS and adjusts:
- **Path format**: `~/` on Unix, `%USERPROFILE%` on Windows
- **Context scan commands**: `ls`/`pwd` on Unix, `dir`/`cd` on Windows
- **Skill count**: reads directory, case-insensitive on Windows

---

## Self-Maintenance

- New skill installed → update `references/routing-table.md` within the same session
- 3+ stable intent→skill pairs → promote to Quick Reference
- User corrects a route → demote the pair, review routing table
- Routing table exceeds 200 lines → archive stale entries (not used in 30+ days)
