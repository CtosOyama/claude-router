# skill-router v4 — Always-On Router Layer (PowerShell fallback for Windows)
# Use session-start.js (Node.js) if available — it's the preferred cross-platform hook.
# This PS1 is the fallback when Node.js is not in PATH.

$skillsDir = "$env:USERPROFILE\.claude\skills"
$routerDir = "$skillsDir\skill-router"
$desktopDir = "$env:USERPROFILE\Desktop"

# Count skills
try {
    $skillCount = (Get-ChildItem -Path $skillsDir -Directory -ErrorAction Stop).Count
} catch {
    $skillCount = 50
}

Write-Output @"
<system-reminder>
## skill-router v4 (always active · win32 · $skillCount skills)

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
L3: ⚠️ 未找到专用工具。① git clone <url> %USERPROFILE%\.claude\skills\ ② 说"帮我用 web-access 找一个"

### Patterns
Seq: A→B | Par: A∥B∥C | Forced: code→review | security→audit | cheat→state gate

Desktop: $desktopDir
Routing table: $routerDir\references\routing-table.md
</system-reminder>
"@

# Signal to Claude Code harness
Write-Output '{"continue":true,"suppressOutput":false}'
