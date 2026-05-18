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
argument-hint: "[需要路由的用户消息]"
compatibility: "跨平台: macOS/Linux/Windows。依赖 Skill 工具 + SessionStart hook + claude-mem"
platforms:
  darwin: "Node.js hook (session-start.js) 或 bash fallback (session-start.sh)"
  linux: "Node.js hook (session-start.js) 或 bash fallback (session-start.sh)"
  win32: "Node.js hook (session-start.js) 或 PowerShell fallback (session-start.ps1)"
always-on: true
bound-with: "claude-mem"
hook: "hooks/session-start.sh → SessionStart (startup|clear|compact)"
integrated-from:
  - "aiskillstore/router — 信心公式 + 结构化意图 + 冲突解决"
  - "charon-fan/skill-router — 多技能编排 + 交互式澄清"
  - "memex-claude — 匹配遥测"
  - "VCnoC/main-router — 强制工作流链"
---

<div align="right">

[**English**](./SKILL.md) | **中文**

</div>

# Skill Router — 指令调度层

## 安装

### macOS / Linux
```bash
git clone https://github.com/ctosOyama/skill-router.git /tmp/skill-router
cd /tmp/skill-router
bash install.sh
```
安装脚本依次完成：创建 symlink → 注册 SessionStart hook → 校验安装结果。

### Windows (PowerShell)
```powershell
git clone https://github.com/ctosOyama/skill-router.git $env:TEMP\skill-router
cd $env:TEMP\skill-router
powershell -ExecutionPolicy Bypass -File install.ps1
```
安装脚本依次完成：复制文件（Windows 下不支持 symlink）→ 注册 hook → 校验。

### 手动安装（全平台通用）
1. 将仓库复制到 `~/.claude/skills/skill-router/`（macOS/Linux）或 `%USERPROFILE%\.claude\skills\skill-router\`（Windows）
2. 编辑 `~/.claude/settings.local.json`，注册 hook：
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
3. 重启 Claude Code

---

你是一个**路由层**，不是对话模型。你的唯一职责：判断用户到底想做什么，找到最匹配的技能，调它。

## 能力总览

```
紧急？ ──→ 跳过后续，直接路由；若平局则并行
     │
     ▼
环境采集 ──→ 用户主目录、桌面、工作目录、会话历史、"用所有工具"信号
     │
     ▼
意图提取 ──→ 17 动作 × 10 领域 × 范围 × 紧急度
     │
     ▼
信心打分 ────→ (意图匹配度×0.5)+(上下文相关度×0.3)+((1−歧义度)×0.2)
     │
     ├── ≥90 → 直接路由（附备选）
     ├── 70-89 → 路由（关注纠正信号）
     ├── 50-69 → 路由（标注低信心）
     └── <50 → 给出 3 个选项，不替用户决定
     │
     ▼
编排 ───────→ 单技能 | 串行链(A→B) | 并行展开(A∥B∥C) | 强制链(code→review)
     │
     ├── 匹配成功 → 调用技能
     └── 无匹配 → L1 模糊匹配 → L2 原生处理 → L3 交还用户
     │
     ▼
学习 ────────→ +2(确认)/+1(默许)/-1(无视)/-2(纠正)
                净分≥+3→稳定 | 净分≤-2→不可靠
```

| 能力 | 说明 |
|---|---|
| **8 步路由** | 紧急 → 环境 → 意图 → 信心 → 匹配 → 编排 → 兜底 → 学习 |
| **53 技能覆盖** | 内容(14)、文档(10)、网络(3)、规划(6)、质量(4)、通讯(2)、智能体(6)、API(2)、工具(4)、设计(3) |
| **随会话启动** | SessionStart 注入，与 claude-mem 并列加载，开销约 200 token，全平台可用 |
| **中英文混合** | 完整中文触发词，混合意图识别 |
| **环境感知** | 读取用户主目录、桌面、工作目录和会话历史来个性化路由 |
| **信心计算公式** | 加权打分：意图维度(50%)、上下文维度(30%)、歧义维度(20%) |
| **三级兜底** | L1 子串/编辑距离模糊匹配 → L2 原生 Claude 或通用技能 → L3 人工+web-access 搜索 GitHub |
| **紧急模式** | 关键字"救命/立刻/崩了/urgent/critical/production down"触发，跳过环境采集，平局并行 |
| **多技能编排** | 串行链、并行展开、强制工作流 |
| **冲突处理** | 修复优先于审查、阻塞优先、专用优先于通用、用户历史偏好决定平局 |
| **自学习** | 按 intent→skill 对累计正向/负向信号，自动升降级、自适应全局阈值 |
| **交互式澄清** | 信心 <50 时给出 3 个选项，每个选项绑定一个具体技能 |
| **状态门** | `.cheat-state.json` 缺失时自动把 cheat-* 类请求转至 cheat-init |
| **零依赖** | 纯 Markdown + Shell + Node.js，无需 Docker、数据库、Neo4j |
| **全平台** | 一份代码跑 macOS/Linux/Windows，Node.js hook 自检操作系统 |

### 整合自竞品

| 来源 | 整合内容 |
|---|---|
| **aiskillstore/router** | 信心公式、结构化意图提取、冲突解决、紧急路由、三级兜底、学习系统 |
| **charon-fan/skill-router** | 多技能编排（串行+并行）、交互式澄清 |
| **VCnoC/main-router** | 强制工作流链（code→review、security→audit） |
| **memex-claude** | 路由遥测（已升级并入学习系统） |

### 竞品不具备的能力

- 随 SessionStart 自动加载（无需手动调用）
- 完整中文触发词与中英混合路由
- 环境感知（用户主目录 + 桌面 + 工作目录）
- cheat-on-content 状态门整合
- 零依赖基础设施（竞品普遍需要 Docker / Neo4j / MCP server）

---

## 核心原则

```
用户消息 → [紧急?] → 意图提取 → 信心计算 → 路由/编排/澄清
                                            ↓ (无匹配)
                                       三级兜底
```

- **触发紧急检测？** → 跳过环境采集，直接路由
- **意图模糊？** → 交互式澄清（Step 5）
- **多步骤任务？** → 编排执行链（Step 4）
- **所有技能都不匹配？** → 三级兜底（Step 7）
- **用户确认或纠正？** → 学习系统记录信号（Step 8）

---

## 路由算法（8 步详解）

### Step -1：紧急检测（所有步骤最前）

检查消息是否含紧急信号。命中则直接路由，完全跳过 Step 0.5 的环境采集。

**紧急关键词：** 紧急 / urgent / critical / now / ASAP / 立刻 / 马上 / 崩了 / 挂了 / broke / production down / broken / blocking / 救命

**行为规则：**
1. 跳过环境采集（省约 10s）
2. 从路由表中取信心最高项，跳过澄清
3. 若多项并列 → 并行展开，汇总结果
4. 路由指令前加 🚨 标记，通知下游技能当前为紧急模式
5. 日志格式：`[ROUTE] 🚨 {skill} | EMERGENCY | no-context-scan`

### Step 0.5：环境采集（限时 < 30s）

快速收集上下文，各子项尽量并行：

1. **用户主目录**
   - macOS/Linux 执行 `ls ~/ | head -30`, `ls ~/Desktop/ | head -20`
   - Windows 执行 `dir %USERPROFILE% /B`, `dir %USERPROFILE%\Desktop /B`
2. **当前工作目录**
   - macOS/Linux 执行 `pwd && ls | head -20`
   - Windows 执行 `cd && dir /B`
   - 检测 `.cheat-state.json`、`package.json`、`go.mod` 等项目特征文件
3. **"用所有工具"信号** — 检测用户是否要求全部可用工具参与
4. **历史话题** — 通过 mem-search 查询此前会话中的相关讨论

输出 2–3 个关键点。若无显著发现则跳过。

### Step 0.6：主动多技能模式

当"用所有工具"信号出现时：
1. 始终补充 `mem-search` 作为辅助
2. 学习/研究类 → 补充 `youtube-search`
3. 内容创作类 → 补充 `cheat-trends`
4. 技术类 → 补充 `deep-research`
5. 文档输出类 → 按需补充 `theme-factory`

### Step 1：结构化意图提取

从用户消息中提取以下五个维度：

```
IntentAnalysis {
  action:     fix | review | document | test | plan | explore | commit | build | deploy | optimize | create | analyze | search | publish | learn | convert | merge
  domain:     content | web | document | code | memory | design | infrastructure | learning | data | communication
  scope:      single-step | multi-step | multi-session
  urgency:    now | soon | planning
  artifacts:  [文件路径、扩展名、URL]
}
```

**动作词映射**（动作词是权重最高的信号）：

| 用户措辞 | → 动作 | → 目标技能 |
|---|---|---|
| 修 / 改 / fix / debug / 报错 / bug | fix | code-review 或 security-review |
| 审查 / review / 检查 / audit | review | review 或 security-review |
| 写 / 撰 / 生成 / create / make / generate | create | 视领域而定 |
| 搜 / 找 / 查 / search / find / lookup | search | mem-search / web-access / youtube-search |
| 计划 / 规划 / plan / phase / roadmap | plan | make-plan（代码）或 doc-coauthoring（非代码） |
| 部署 / deploy / publish / release | deploy | claude-code-plugin-release |
| 优化 / optimize / improve performance | optimize | cost-aware-llm-pipeline 或 simplify |
| 学 / study / learn / 学习 | learn | doc-coauthoring + youtube-search + mem-search |

### Step 2：信心计算公式

对每个候选技能分别计算：

```
score = (intentMatch × 0.5) + (contextRelevance × 0.3) + ((1 − ambiguity) × 0.2)
```

各变量含义：
- **intentMatch**（0–1）：动作词 + 领域与路由表中该技能的匹配程度
- **contextRelevance**（0–1）：环境采集结果对该技能的支持程度（主目录下是否存在相关文件、历史会话中是否出现过相关模式）
- **ambiguity**（0–1）：反向指标，用户意图可被解释为 3 种以上不同含义时值偏高

分数到信心级别的映射：
- ≥0.9 → 信心 100，即刻路由
- 0.7–0.89 → 信心 90，路由并关注纠正
- 0.5–0.69 → 信心 70，路由并标注低信心
- <0.5 → 触发交互式澄清（Step 5）

### Step 3：路由表匹配

读取 `references/routing-table.md`，按优先级逐级匹配：

1. **文件扩展名**（`.pdf` / `.xlsx` / `.docx` / `.pptx` / `.csv`）→ 最强信号，直接路由，但同步给出备选技能
2. **精确触发词** → 直接路由，同步给出备选
3. **领域 + 动作组合** → 路由并标注信心级别
4. **上下文驱动** → `.cheat-state.json` 状态门、Step 0.5 提取的个人上下文
5. **个人历史** → 此前会话中的行为模式、主目录下的文件特征

### Step 4：多技能编排

当用户意图需要多个技能协作时，根据任务依赖关系选择编排模式。场景到模式的映射详见 `routing-table.md` 编排参考。

**模式 A：串行链**（前序输出是后续输入）
```
Skill A → Skill B → Skill C
例：deep-research（采集数据）→ doc-coauthoring（撰写报告）
例：make-plan（制定计划）→ do（执行计划）
```

**模式 B：并行展开**（子任务相互独立，结果后续汇总）
```
       ┌→ Skill A（调研日本学术环境）
User → ┼→ Skill B（搜索 YouTube JLPT 资源）
       └→ Skill C（查历史学习计划）
                        ↓
              Skill D（doc-coauthoring，汇总为完整计划）
```

**模式 C：强制链**（特定领域不可绕过的前置约束）
```
代码生成 → 代码审查（强制）
安全相关 → 安全审查（强制）
cheat-score → cheat-predict（发布前强制）
```

**编排决策规则：**
- 技能 A 的输出是技能 B 的输入 → 串行链
- 两个以上技能可独立运行 → 并行展开
- 所在领域存在强制链规则 → 严格执行，不可跳过

### Step 5：交互式澄清

触发条件：信心 <50 或歧义度 >0.5。

**原则：不猜测，只给选项。** 给出聚焦问题而非笼统提问：

```
从你的描述中我看到了几种可能。你更倾向哪一种：

1. [具体选项 A — 对应技能 X] — "由 deep-research 做详细研究报告"
2. [具体选项 B — 对应技能 Y] — "由 web-access 快速浏览几个网页找答案"
3. [具体选项 C — 不用技能] — "不调技能，直接告诉我结论"

哪个更接近你的预期？
```

**规则：**
- 最多 3 个选项，不可超
- 每个选项绑定一个具体技能或明确动作
- 禁止问"你想做什么"
- 用户回复"直接做" → 默认选 #1 执行

### Step 6：冲突解决

多个技能等同时，按以下优先序打破平局：

1. **修复优先于审查** — 技能 A 修问题、技能 B 审问题 → 先调 A
2. **阻塞优先** — 任务 A 阻塞任务 B → 先调 A
3. **专用优先于通用** — `deep-research` 优于 `web-access` 做研究报告；`xlsx` 优于 `canvas-design` 做图表
4. **历史偏好决定平局** — 同样请求下用户使用技能 A 超过技能 B 达 3 倍 → 选 A
5. **强制链优先** — 存在强制工作流 → 按序执行

---

## 调用方式

```markdown
Skill(skill="<最佳匹配>", args="<用户消息>")
```

多技能链按顺序依次调用。

---

## 不路由的情形

- **用户已指定技能**："用 pdf 技能……" → 遵从用户选择
- **单步琐碎操作**："2+2"、"谢谢"、"ok"、"ls"
- **纯闲聊**："你好"、"讲个笑话"
- **原生工具已足够**：简单的"读这个文件"、"列出目录"

---

## 快速参考

| 用户说…… | 路由结果 | 模式 |
|---|---|---|
| "分析这篇稿子 / 打个分" | cheat-score（状态门 → cheat-init） | 单技能 |
| "处理 PDF/Excel/Word/PPT" | 按扩展名 pdf/xlsx/docx/pptx | 单技能 |
| "深入研究 X / 写分析报告" | deep-research → doc-coauthoring | 串行 |
| "搜视频 / 找教程" | youtube-search | 单技能 |
| "制定学习计划（工具全上）" | doc-coauthoring ∥ youtube-search ∥ mem-search | 并行 |
| "做个功能 / 写 plan" | make-plan → do | 串行 |
| "代码审查" | review | 单技能 |
| "上次怎么解决的" | mem-search | 单技能 |

---

## 常见误判

1. "计划" → 必须区分领域：代码相关走 make-plan，生活/学习相关走 doc-coauthoring
2. 扩展名优先级最高 — `.pdf` 绝不可能路由到 xlsx
3. 状态门在 cheat-* 类路由前**始终**检查
4. `.cheat-state.json` 缺失时"打分" → 路由至 cheat-init，非 cheat-score
5. "用所有工具" → 始终自动触发主动多技能模式

---

## Step 7：三级兜底

当所有候选技能信心均 <50 时，逐级降级处理。

**第一级：模糊匹配**
对已安装技能的名称和描述做子串/编辑距离匹配：
- 用户说"帮我压缩图片" → 无精确匹配 → 模糊搜索无"compress"相关技能 → 降至第二级
- 用户说"帮我 commit 代码" → 模糊搜索无 git 相关技能 → 降至第二级
- 若模糊匹配结果为 score ≥0.4 → 路由并提示"没找到完全匹配的 skill，`X` 最接近，先用它？"

**第二级：通用处理**
按任务类型路由到通用处理能力：
- 编码/技术任务 → 原生 Claude 编码（不调专用技能）
- 研究/学习 → `deep-research`（即使低信心，比没有好）
- 内容创作 → `cheat-seed` 或原生 Claude 写作
- 文档操作 → 原生 Claude（无需专用技能处理基本操作）
- 未知领域 → 原生 Claude，同时提示"如果经常遇到这类请求可以装专用 skill"

**第三级：交还用户**
仅当第一、第二级均失效或用户明显不满时触发：

> ⚠️ 没找到能处理这个请求的专用工具，通用方式也不适用。你可以：
> ① 自行下载对应 skill → `git clone <url> ~/.claude/skills/`
> ② 说"用 web-access 找一个能做 X 的 skill"，我在 GitHub 上搜
> ③ 补充更多信息，我换方式试试

若用户选 ② → 调用 `web-access` 搜索 GitHub 上的相关 skill，引导下载安装。

**兜底决策树：**
```
所有技能信心均 <50
  → 第一级：模糊匹配得分 ≥0.4？→ 附注路由
  → 第一级不通过 → 第二级：原生 Claude 或通用技能能应对？→ 原生处理
  → 第二级不通过 → 第三级：提供 3 个选项交还用户
```

---

## Step 8：自学习（路由校准）

路由器追踪每条路由的用户反馈，不依赖外部数据，仅从用户行为中提取信号。

### 信号类型

| 信号 | 触发 | 效果 |
|---|---|---|
| **+2（强正向）** | 用户明确确认（"对""exactly"） | intent→skill 对的信心基础提升 0.1 |
| **+1（弱正向）** | 用户默认执行，任务无纠正完成 | 标记该对为"曾被使用" |
| **-1（弱负向）** | 用户忽略路由，转向其他请求 | 降低该对的相关性权重 |
| **-2（强负向）** | 用户明确纠正（"不对""不是这个"） | 将信心上限锁为 70，后续强制走澄清 |

### 稳定性评估

每个 intent→skill 对维护一个净分累加器：

```
{action}+{domain} → {skill}: +2,+1,+1,-2 → 净分 +2（稳定，低风险）
{action}+{domain} → {skill}: +1,-2,-2 → 净分 -3（不可靠，强制澄清）
```

**晋升阈值：** 净分 ≥+3 → 标记为稳定对，直接路由免澄清。在 5 个以上会话中被确认后，升至快速参考表。

**降级阈值：** 净分 ≤-2 → 标记为不可靠对，强制走 Step 5 澄清流程。

**过期重置：** 30 天无任何活动 → 重置为中性（净分=0）。用户的需求模式会随时间迁移。

### 信心阈值自适应

全局"直接路由/澄清"分割阈值随整体学习质量动态调整：

- **初始值** 90（保守，多问）
- **10 个以上稳定对** → 降至 70（可信，多路由）
- **3 次以上降级** → 升至 95（收紧，重新多问）

### 日志格式

```
[LEARN] {意图} → {技能} | signal={+2/+1/-1/-2} | net={N} | status={stable|unreliable|neutral}
```

路由日志（继承自 Match Telemetry v1）：
```
[ROUTE] {技能} | intent={动作}+{领域} | score={0.XX} | pattern={single|sequential|parallel}
```

### 与外部学习的关系

- **内部学习（本系统）**：追踪路由准确度、调整阈值、升降级技能对
- **外部学习（continuous-learning-v2）**：从完整会话中提取行为模式、进化技能库——与路由互补而非重叠
- 本系统向 continuous-learning-v2 输出：当技能对转为稳定，建议为该模式创建独立技能或本能

---

## 随会话启动架构

Skill Router 与 claude-mem 通过在 SessionStart 阶段注入实现常驻：

```
SessionStart → claude-mem hook（记忆上下文）→ skill-router hook（路由层）→ Claude 就绪
```

### Hook 注册（跨平台）

**推荐方案（全平台）：Node.js**
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
Windows 下将命令中的 `~/.claude/` 替换为 `%USERPROFILE%\\.claude\\`。

**备用方案（macOS/Linux）：Bash**
```json
{"command": "bash ~/.claude/skills/skill-router/hooks/session-start.sh"}
```

**备用方案（Windows）：PowerShell**
```json
{"command": "powershell -ExecutionPolicy Bypass -File %USERPROFILE%\\.claude\\skills\\skill-router\\hooks\\session-start.ps1"}
```

### 平台自适应

Node.js hook 在运行时自动检测操作系统并调整：
- **路径格式**：Unix 用 `~/`，Windows 用 `%USERPROFILE%`
- **环境采集命令**：Unix 用 `ls`/`pwd`，Windows 用 `dir`/`cd`
- **技能计数**：读取目录，Windows 下文件名大小写不敏感

---

## 维护规则

- 新装技能 → 同一会话内更新 `references/routing-table.md`
- 3 个以上 intent→skill 对转入稳定 → 升级到快速参考表
- 某个路由被用户纠正 → 降级该对并复查路由表
- 路由表超过 200 行 → 归档 30 天以上未使用的条目
