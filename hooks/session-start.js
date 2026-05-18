#!/usr/bin/env node
/**
 * skill-router v4 — Always-On Router Layer
 * Cross-platform SessionStart hook: macOS / Linux / Windows
 * Injects routing context into every Claude Code session alongside claude-mem
 *
 * Usage (registered in settings.local.json):
 *   macOS/Linux: node ~/.claude/skills/skill-router/hooks/session-start.js
 *   Windows:     node %USERPROFILE%\.claude\skills\skill-router\hooks\session-start.js
 *
 * Fallback: if Node.js unavailable, use session-start.sh (Unix) or session-start.ps1 (Windows)
 */

const os = require('os');
const path = require('path');

const PLATFORM = os.platform(); // 'darwin' | 'linux' | 'win32'
const HOME = os.homedir();

// Resolve paths cross-platform
const CLAUDE_DIR = path.join(HOME, '.claude');
const SKILLS_DIR = path.join(CLAUDE_DIR, 'skills');
const ROUTER_DIR = path.join(SKILLS_DIR, 'skill-router');
const ROUTING_TABLE = path.join(ROUTER_DIR, 'references', 'routing-table.md');

// Detect available skills count (fast check, no deep scan)
let skillCount = 0;
try {
  const fs = require('fs');
  const entries = fs.readdirSync(SKILLS_DIR, { withFileTypes: true });
  skillCount = entries.filter(e => e.isDirectory() || e.isSymbolicLink()).length;
} catch (e) {
  skillCount = 50; // fallback estimate
}

// Platform-specific path display
const skillsPathDisplay = PLATFORM === 'win32'
  ? `%USERPROFILE%\\.claude\\skills\\`
  : '~/.claude/skills/';

const desktopPath = PLATFORM === 'win32'
  ? path.join(HOME, 'Desktop')
  : path.join(HOME, 'Desktop');

// Output router context (same format as bash hook, but OS-aware)
console.log(`<system-reminder>
## skill-router v4 (always active · ${PLATFORM} · ${skillCount} skills)

You are a routing layer. Before responding to ANY request, check if a specialized skill can handle it better than native reasoning.

### 🚨 Emergency (Step -1, check FIRST)
Keywords: 紧急/立刻/马上/崩了/挂了/救命/故障 | urgent/critical/now/ASAP/broke/production down
→ SKIP context scan, route immediately, parallel fan-out if tied.

### Quick Route
- 内容打分/预测/复盘 → cheat-* (no .cheat-state.json → cheat-init)
- .pdf/.xlsx/.docx/.pptx → pdf/xlsx/docx/pptx
- 深度调研/写报告 → deep-research → doc-coauthoring
- 网页/登录 → web-access | 搜视频 → youtube-search | 查历史 → mem-search
- 文档撰写 → doc-coauthoring | 代码计划 → make-plan → do | 代码审查 → review
- 学习计划(全工具) → doc-coauthoring ∥ youtube-search ∥ mem-search

### 3-Layer Fallback (Step 7)
L1: fuzzy match ≥0.4 → route with caveat
L2: native Claude or generic skill
L3: ⚠️ 未找到专用工具。① git clone <url> ${skillsPathDisplay} ② 说"帮我用 web-access 找一个"

### Learning (Step 8)
Signals: +2(confirmed)/+1(silent)/-1(ignored)/-2(corrected)
net≥+3→stable | net≤-2→unreliable | threshold: start 90→stable 70→mistakes 95

### Confidence
score=(intentMatch×0.5)+(contextRelevance×0.3)+((1-ambiguity)×0.2)

### Patterns
Seq: A→B | Par: A∥B∥C | Forced: code→review | security→audit | cheat→state gate

Skills dir: ${skillsPathDisplay}
Routing table: ${ROUTING_TABLE}
Desktop (context scan): ${desktopPath}
</system-reminder>`);

// Signal to Claude Code harness: continue normally, don't suppress output
console.log(JSON.stringify({ continue: true, suppressOutput: false }));
