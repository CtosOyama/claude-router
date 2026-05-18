# Skill Routing Table

Auto-generated from `~/.claude/skills/` on 2026-05-18. 53 skills indexed.
When a skill is added/removed, rescan:
- macOS/Linux: `ls ~/.claude/skills/*/SKILL.md`
- Windows: `dir %USERPROFILE%\.claude\skills\*\SKILL.md /B`

Cross-platform: all paths normalized. File extension matching is case-insensitive on Windows.

Each entry: `intent-patterns → skill-name | confidence-score | notes`

Confidence scores:
- **100**: exact trigger word match — route immediately
- **90**: clear semantic match — route with high confidence
- **70**: probable match — route but be ready to fallback
- **50**: possible match — check context before routing

---

## 1. Content Creation — cheat-on-content (14 skills)

| Intent Pattern | Skill | Confidence | Notes |
|---|---|---|---|
| "初始化", "init", "setup cheat", "我是新用户", "首次使用", "first time" | cheat-init | 100 | If .cheat-state.json does not exist, all other cheat-* requests MUST route here first |
| "打分这篇", "score this", "给稿子打分", "先打分看看" | cheat-score | 100 | Console output only, no files written |
| "启动预测", "start prediction", "写预测日志", "给这稿子打分并预测" | cheat-predict | 100 | Requires existing script + rubric |
| "拍了", "shot it", "录完了", "已拍", "shot" | cheat-shoot | 100 | Creates video folder, buffer +1 |
| "已发布", "I shipped", "发布链接", "publish registered", "刚发完" | cheat-publish | 100 | Updates metadata only |
| "复盘", "retro this", "T+3d", "数据来了", "抓数据" | cheat-retro | 100 | Requires existing prediction file |
| "升级rubric", "bump rubric", "更新公式", "调整权重", "重校桶" | cheat-bump | 100 | Requires calibration pool |
| "推荐选题", "next topic", "下一篇做什么", "挑一个选题" | cheat-recommend | 100 | Requires candidates.md |
| "抓热点", "fetch trends", "今天有什么可做", "trending now" | cheat-trends | 100 | Network required |
| "状态", "看板", "status", "进度怎么样" | cheat-status | 100 | Read-only, always safe |
| "学这个账号", "找对标", "learn from", "导入对标账号" | cheat-learn-from | 100 | Benchmark import |
| "迁移", "升级state", "migrate", "schema版本" | cheat-migrate | 100 | State schema upgrade |
| "找选题", "我想做一条", "seed", "最近有个想法" | cheat-seed | 100 | Topic discussion + draft writing |
| Request to do blind scoring internally (called by cheat-score/predict/bump) | cheat-score-blind | 100 | INTERNAL ONLY — hard refuses to read state/predictions/retro data |

## 2. Web & Research (3 skills)

| Intent Pattern | Skill | Confidence | Notes |
|---|---|---|---|
| "搜索", "查一下", "上网", "浏览网页", "登录后", "网页操作", 小红书/微博/推特内容抓取, CDP, "打开这个网站" | web-access | 90 | For any web interaction requiring browser CDP, login state, or anti-bot sites |
| "调研", "research", "deep dive", "investigate", "写一份研究报告", "深入了解", market research, competitive analysis, due diligence | deep-research | 90 | Requires firecrawl or exa MCP. Multi-source cited reports |
| "搜视频", "找视频", "youtube上有没有", "有什么教程视频", video search, "find videos about" | youtube-search | 90 | Returns structured video results via yt-dlp |

## 3. Documents & Media (10 skills)

| Intent Pattern | Skill | Confidence | Notes |
|---|---|---|---|
| "PDF", ".pdf file", "合并PDF", "拆分PDF", "提取PDF", "PDF转", "OCR", "加水印" | pdf | 100 | Any PDF operation |
| "excel", ".xlsx", ".csv", ".tsv", "表格", "spreadsheet", "数据透视", "公式计算", "图表" | xlsx | 100 | Any spreadsheet operation |
| "word", ".docx", "word document", "memo", "letterhead", "track changes" | docx | 100 | Any Word document operation |
| "ppt", "slides", "deck", "presentation", ".pptx", "幻灯片" | pptx | 100 | Any PowerPoint operation |
| "poster", "海报", "design", "create art", "visual design", "design a", "make a design" | canvas-design | 90 | Static visual art in .png/.pdf |
| "generative art", "algorithmic art", "p5.js", "flow field", "particle system" | algorithmic-art | 100 | Code-based generative art |
| "frontend", "UI", "website", "landing page", "dashboard", "web app", "React component", "HTML page", "界面", "网页" | frontend-design | 90 | Production-grade frontend interfaces |
| "wowerpoint", "kawaii slides", "NotebookLM slides", "make a deck about" | wowerpoint | 100 | NotebookLM-style slides from a document |
| "slack GIF", "animated GIF for slack", "make me a GIF" | slack-gif-creator | 100 | Slack-optimized animated GIFs |
| "web artifact", "claude.ai artifact", "React artifact", "multi-component HTML" | web-artifacts-builder | 90 | Complex claude.ai HTML artifacts |

## 4. Software Development — Planning & Architecture (6 skills)

| Intent Pattern | Skill | Confidence | Notes |
|---|---|---|---|
| "make a plan", "create a plan", "plan this feature", "how should I implement", "phase plan" | make-plan | 90 | Phased implementation plan |
| "execute the plan", "run the plan", "carry out", "do the plan", "implement the plan" | do | 90 | Executes a plan using subagents |
| "blueprint", "construction plan", "multi-session plan", "multi-PR plan", "step-by-step for multiple agents" | blueprint | 100 | Multi-session, multi-agent construction plans |
| "learn codebase", "prime the repo", "read the codebase", "get up to speed", "onboard to this project" | learn-codebase | 90 | Full codebase read-through |
| "find in code", "where is X defined", "explore codebase", "code structure", "AST search", "symbol search" | smart-explore | 90 | Tree-sitter structural code search |
| "find ideal path", "unify duplicated", "audit architecture", "refactor architecture", "代码架构审计" | pathfinder | 100 | Architecture audit + unified flowchart |

## 5. Software Development — Code Quality & Review (3 skills)

| Intent Pattern | Skill | Confidence | Notes |
|---|---|---|---|
| "code review", "review this PR", "review my code" | review | 90 | Pull request review |
| "security review", "security audit", "vulnerability check", "安全审计" | security-review | 90 | Security audit of changes |
| "simplify this code", "refactor", "clean up code", "remove duplication" | simplify | 90 | Code quality improvement |
| "babysit PR", "monitor PR", "watch PR", "keep checking reviews" | babysit | 100 | Automated PR monitoring |

## 6. Software Development — Build & Deploy (1 skill)

| Intent Pattern | Skill | Confidence | Notes |
|---|---|---|---|
| "publish plugin", "release this plugin", "version bump", "npm publish plugin" | claude-code-plugin-release | 90 | Claude Code plugin release workflow |

## 7. Claude API & LLM Engineering (2 skills)

| Intent Pattern | Skill | Confidence | Notes |
|---|---|---|---|
| "Claude API", "Anthropic SDK", "prompt caching", "cache hit rate", "Anthropic API call", imports anthropic/`@anthropic-ai/sdk` | claude-api | 100 | Claude API / Anthropic SDK development |
| "reduce API costs", "cheaper model routing", "cost optimize LLM", "prompt caching savings", "token budget" | cost-aware-llm-pipeline | 90 | LLM cost optimization patterns |

## 8. Agent Infrastructure & Memory (6 skills)

| Intent Pattern | Skill | Confidence | Notes |
|---|---|---|---|
| "did we already", "how did we do X last time", "previous work", "past sessions", "memory search" | mem-search | 90 | Cross-session memory search |
| "build knowledge base", "query my past work", "compile expertise", "knowledge corpus" | knowledge-agent | 90 | Build/query knowledge corpora from observations |
| "timeline report", "project history", "development journey", "journey report" | timeline-report | 100 | Narrative project history from claude-mem timeline |
| "how does claude-mem work", "what is this memory thing" | how-it-works | 100 | claude-mem explanation |
| "autonomous agent", "self-running agent", "continuous operation", "scheduled tasks", "agent loop" | autonomous-agent-harness | 100 | Autonomous agent with cron/dispatch/memory |
| "continuous learning", "extract patterns", "session learning", "auto-learn" | continuous-learning-v2 | 90 | Instinct-based pattern extraction from sessions |

## 9. Communication & Docs (2 skills)

| Intent Pattern | Skill | Confidence | Notes |
|---|---|---|---|
| "write a status report", "internal comms", "leadership update", "company newsletter", "FAQ", "incident report", "project update", "内部通讯" | internal-comms | 90 | Internal communication formats |
| "co-author doc", "write documentation", "draft spec", "technical proposal", "decision doc", "写文档", "技术方案" | doc-coauthoring | 90 | Structured doc co-authoring workflow |

## 10. Skill & Tool Creation (3 skills)

| Intent Pattern | Skill | Confidence | Notes |
|---|---|---|---|
| "create a skill", "new skill", "make a skill", "skill creator" | skill-creator | 100 | Skill creation workflow |
| "build MCP server", "MCP integration", "create MCP tool", "MCP SDK" | mcp-builder | 90 | MCP server development |
| "create .claude.md", "init project", "generate CLAUDE.md" | init | 90 | Project initialization |

## 11. Web Testing & QA (1 skill)

| Intent Pattern | Skill | Confidence | Notes |
|---|---|---|---|
| "test web app", "Playwright test", "browser test", "debug UI", "frontend test" | webapp-testing | 90 | Playwright-based web app testing |

## 12. Styling & Brand (2 skills)

| Intent Pattern | Skill | Confidence | Notes |
|---|---|---|---|
| "Anthropic brand", "brand colors", "company colors", "Anthropic style" | brand-guidelines | 90 | Anthropic brand application |
| "theme for slides", "style this doc", "apply theme", "color theme for" | theme-factory | 90 | Theme styling for artifacts |

## 13. Council & Decision (1 skill)

| Intent Pattern | Skill | Confidence | Notes |
|---|---|---|---|
| "what should I do", "weigh options", "council opinion", "multiple paths", "go/no-go", "tradeoff", "decision help" | council | 90 | Four-voice council for ambiguous decisions |

## 14. System Configuration (2 skills)

| Intent Pattern | Skill | Confidence | Notes |
|---|---|---|---|
| "update config", "change settings", "add permission", "configure hook", "settings.json" | update-config | 90 | Claude Code settings configuration |
| "keybinding", "keyboard shortcut", "rebind key", "chord shortcut" | keybindings-help | 100 | Keyboard shortcut customization |

## Context-Aware Secondary Routing

When user says "use all tools" / "把你觉得有用的工具都用上" / "把所有能用的都用上", the router must proactively add complementary skills. These rules map personal context patterns → secondary skill suggestions:

| If context scan finds... | Always add as secondary | Rationale |
|---|---|---|
| Learning/study topics (Japanese, exam prep, course planning) | `youtube-search` | Find tutorial videos, lectures, study-abroad experiences |
| Learning/study topics (any subject) | `mem-search` | Retrieve prior study plans, notes, past learning sessions |
| Content creation (任何创作相关) | `cheat-trends` or `cheat-recommend` | Check what's trending or recommend next topic |
| Technical/coding projects | `deep-research` | Background research on libraries, patterns, alternatives |
| Document/report writing | `theme-factory` (tertiary, optional) | Style the final output if user wants it polished |
| User has files in ~/ related to the topic | `mem-search` | Cross-reference with prior work on the same topic |

**Activation triggers** (any one is enough):
- "把你觉得对这事有帮助的工具都用上"
- "把所有能用的都用上"
- "use all the tools"
- "all available tools"
- "有什么工具能用"

## Forced Workflow Chains (Mandatory)

When certain intent patterns appear, these chains MUST be followed — never skip a step:

| Trigger Intent | Mandatory Chain | Rationale |
|---|---|---|
| "生成代码/create code/build feature" | `make-plan` → `do` (or code generation → `review`) | Plan before execute. Review after code. |
| "安全相关/security/auth/crypto/PII" | any code skill → `security-review` | Security audit is mandatory for sensitive code |
| cheat-score or cheat-predict | verify `.cheat-state.json` exists → `cheat-init` if not | State gate must pass before any cheat operation |
| "发布插件/publish plugin/npm publish" | `claude-code-plugin-release` | Version bump + build verify + git tag + npm + GitHub release |
| "改了代码但没测试/changed code no tests" | code skill → test skill (language-specific) | TDD workflow: tests must follow code changes |

## Orchestration Pattern Reference

> Pattern definitions (Sequential / Parallel / Forced) are in **SKILL.md Step 4**.

Common multi-skill patterns that the router should recognize:

| User Intent | Orchestration Pattern | Skills Chained |
|---|---|---|
| "研究X并写报告" | Sequential | `deep-research` → `doc-coauthoring` |
| "做功能X" | Sequential | `make-plan` → `do` |
| "写学习计划（全工具）" | Parallel + Sequential | `doc-coauthoring` ∥ `youtube-search` ∥ `mem-search` → `doc-coauthoring` |
| "代码审查+安全审查" | Parallel | `review` ∥ `security-review` |
| "分析数据+做图表+写报告" | Sequential | `xlsx` → `pptx` or `doc-coauthoring` |
| "找视频学习X然后写笔记" | Sequential | `youtube-search` → `doc-coauthoring` |
| "审查PR并babysit到合并" | Sequential | `review` → `babysit` |
| "做PPT演示" (from data) | Sequential | `xlsx` (data) → `pptx` (slides) |

## Emergency Routing Keywords

When user message contains ANY of these, trigger Emergency Mode (SKILL.md Step -1):

| Language | Keywords |
|---|---|
| 中文 | 紧急 / 立刻 / 马上 / 崩了 / 挂了 / 救命 / 快 / 急 / 生产环境 / 线上 / 故障 |
| English | urgent / critical / now / ASAP / broke / broken / production down / blocking / emergency / help / immediately |

Emergency mode: skip context scan, route immediately, parallel fan-out if tied.

## 3-Layer Fallback Reference

> Full logic in **SKILL.md Step 7**. This table helps quickly identify fallback routes.

| Fallback Layer | Trigger | Action |
|---|---|---|
| Layer 1: Fuzzy | No exact match, fuzzy ≥ 0.4 | Route with caveat: "X looks closest, try this?" |
| Layer 2: Generic | Fuzzy < 0.4 | Native Claude or generic skill (deep-research for research, cheat-seed for content, native for docs) |
| Layer 3: Human | Generic also can't handle | Offer: self-download / web-access search / more detail |

## Learning System Reference

> Full logic in **SKILL.md Step 8**. Routing-table entries tagged with learning status.

| Tag | Meaning | Routing Behavior |
|---|---|---|
| `[stable]` | net ≥ +3 signals | Auto-route, no clarification |
| `[unreliable]` | net ≤ -2 signals | Force Interactive Clarification |
| `[neutral]` | net between -1 and +2 (or new) | Normal confidence-based routing |

## Conflict Resolution Rules

> See **SKILL.md Step 6** for the 5 tiebreaker rules (single source of truth).
> See **SKILL.md Step -1** for emergency override (urgency trumps all).

## Routing Priority Rules

1. **Emergency detection** → skip all, route immediately
2. **Exact trigger word match** (confidence 100) → route immediately. **But still document ≥1 alternative considered.**
3. **File extension match** (.pdf, .xlsx, .docx, .pptx, .md) → route to file-type skill immediately. **But still document ≥1 alternative considered.**
4. **cheat-on-content state gate**: if intent matches cheat-* but `.cheat-state.json` doesn't exist → route to cheat-init
5. **Ambiguous intent** (2+ skills at confidence 70-90): rank by specificity — prefer the more specialized skill
6. **Personal context routing**: if Step 0.5 context scan reveals user patterns, apply context-aware secondary routing
7. **No match** (all confidence <50): invoke **3-Layer Fallback** (SKILL.md Step 7)

## Skills That Must Be Avoided for Non-Engineering Tasks

When the user's intent is **personal/learning/life planning** (not software engineering), these skills MUST be explicitly avoided in routing output:

| Skill | Why avoid for non-engineering |
|---|---|
| `make-plan` | Software feature implementation plans only — NOT personal study/life plans |
| `blueprint` | Multi-session engineering construction plans for multi-PR code projects — NOT general planning |
| `do` | Executes software implementation plans via subagents — NOT general task execution |
| `code-review` / `review` | Pull request and code review — NOT document or plan review |
| `claude-code-plugin-release` | npm publishing workflow — NOT general release management |

If any of these appear as false-positive matches (e.g., "plan" matching `make-plan`), list them in `skills_explicitly_avoided` with a clear one-line rationale.

## Meta: Self-Routing

This routing table describes skill-router itself at:
- Intent: "which skill to use", "what tool for", "找不到合适的skill", "route this"
- Routes to: **self** — the skill-router is the tool for finding tools
