# Skill Routing Index

Last scanned: runtime (SessionStart hook). Each entry: trigger keywords → skill | orchestration pattern.

## Documents & Media

| Keywords | Skill | Pattern |
|---|---|---|
| .pdf, merge/split/extract/OCR PDF | pdf | Single |
| .xlsx/.csv/.tsv, spreadsheet, chart, formula | xlsx | Single |
| .docx, word, memo, letterhead | docx | Single |
| .pptx, slides, deck, presentation | pptx | Single |
| poster, design, visual art, create art | canvas-design | Single |
| generative art, p5.js, flow field | algorithmic-art | Single |
| frontend, UI, website, landing page, React | frontend-design | Single |
| wowerpoint, kawaii slides, NotebookLM | wowerpoint | Single |
| slack GIF, animated GIF | slack-gif-creator | Single |

## Web & Research

| Keywords | Skill | Pattern |
|---|---|---|
| search, browse, login, web page, CDP | web-access | Single |
| research, deep dive, investigate, report | deep-research → doc-coauthoring | Sequential |
| find videos, YouTube, tutorials | youtube-search | Single |
| did we solve this, past sessions | mem-search | Single |

## Content Creation (cheat-on-content)

| Keywords | Skill | Pattern |
|---|---|---|
| init, setup, first time, 初始化 | cheat-init | Single (state gate) |
| score, 打分 | cheat-score | Single |
| start prediction, 启动预测 | cheat-predict | Single |
| shot, filmed, 拍了 | cheat-shoot | Single |
| published, shipped, 已发布 | cheat-publish | Single |
| retro, T+N data, 复盘 | cheat-retro | Single |
| recommend topics, 推荐选题 | cheat-recommend | Single |
| trends, fetch hot topics, 抓热点 | cheat-trends | Single |
| status, dashboard, 状态 | cheat-status | Single |
| bump rubric, 升级rubric | cheat-bump | Single |
| seed, find topic, 找选题 | cheat-seed | Single |
| learn from, import, 学这个账号 | cheat-learn-from | Single |
| migrate state, schema upgrade | cheat-migrate | Single |

## Planning & Architecture

| Keywords | Skill | Pattern |
|---|---|---|
| plan, feature plan, phased | make-plan → do | Sequential |
| blueprint, multi-session, multi-PR | blueprint | Single |
| learn codebase, prime repo, onboard | learn-codebase | Single |
| find in code, explore code, AST search | smart-explore | Single |
| audit architecture, find ideal path | pathfinder | Single |

## Code Quality

| Keywords | Skill | Pattern |
|---|---|---|
| code review, review PR | review | Single |
| security review, vulnerability check | security-review | Single |
| simplify, refactor, clean up | simplify | Single |
| babysit PR, monitor PR, watch PR | babysit | Single |

## Agent & Infrastructure

| Keywords | Skill | Pattern |
|---|---|---|
| autonomous agent, self-directing | autonomous-agent-harness | Single |
| continuous learning, instincts | continuous-learning-v2 | Single |
| cost optimize, model routing | cost-aware-llm-pipeline | Single |
| knowledge base, corpus, brain | knowledge-agent | Single |
| version bump, npm publish, release | claude-code-plugin-release | Single |
| Claude API, Anthropic SDK, caching | claude-api | Single |

## Communication & Styling

| Keywords | Skill | Pattern |
|---|---|---|
| internal comms, status report, newsletter | internal-comms | Single |
| brand colors, Anthropic style | brand-guidelines | Single |
| theme, color scheme, font | theme-factory | Single |

## Tools & Creation

| Keywords | Skill | Pattern |
|---|---|---|
| create skill, modify skill, optimize skill | skill-creator | Single |
| build MCP server, API integration | mcp-builder | Single |
| web artifact, shadcn/ui, React artifact | web-artifacts-builder | Single |
| webapp testing, Playwright, UI test | webapp-testing | Single |

## Council & Decision

| Keywords | Skill | Pattern |
|---|---|---|
| ambiguous decision, tradeoff, go/no-go | council | Single |

## Orchestration Pattern Reference

```
Sequential: A → B         deep-research → doc-coauthoring, make-plan → do
Parallel:   A ∥ B ∥ C     review ∥ security-review
Forced:     code → review  any code generation must be reviewed
```

## State Gates

- `cheat-*` before `.cheat-state.json` exists → route to `cheat-init` first
- `cheat-score` on script with predictions → remind about `cheat-predict`
- `.pdf` → never route to non-pdf skill; `.xlsx` → never route to non-xlsx skill
