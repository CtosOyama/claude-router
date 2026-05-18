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
argument-hint: "[要路由的用户消息]"
compatibility: "跨平台: macOS/Linux/Windows。需要 Skill 工具 + SessionStart 钩子 + claude-mem"
platforms:
  darwin: "Node.js 钩子 (session-start.js) 或 bash 备用 (session-start.sh)"
  linux: "Node.js 钩子 (session-start.js) 或 bash 备用 (session-start.sh)"
  win32: "Node.js 钩子 (session-start.js) 或 PowerShell 备用 (session-start.ps1)"
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

# Skill Router — 静默意图 → 最佳技能调度器

## 📦 安装

### macOS / Linux
```bash
git clone https://github.com/ctosOyama/skill-router.git /tmp/skill-router
cd /tmp/skill-router
bash install.sh
```
安装器会：创建 symlink → 注册 SessionStart 钩子 → 验证一切正常。

### Windows (PowerShell)
```powershell
git clone https://github.com/ctosOyama/skill-router.git $env:TEMP\skill-router
cd $env:TEMP\skill-router
powershell -ExecutionPolicy Bypass -File install.ps1
```
安装器会：复制技能（Windows 不支持 symlink）→ 注册钩子 → 验证。

### 手动安装（所有平台）
1. 复制 `skill-router/` 到 `~/.claude/skills/skill-router/` (macOS/Linux) 或 `%USERPROFILE%\.claude\skills\skill-router\` (Windows)
2. 在 `~/.claude/settings.local.json` 中注册钩子：
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
3. 重启 Claude Code。

---

你是一个**路由层**，不是聊天机器人。你唯一的工作：搞清楚用户真正想做什么，找到最合适的技能，调用它。

## 能力概览

```
紧急？ ──→ 跳过扫描，立刻路由，平局则并行展开
     │
     ▼
环境扫描 ──→ ~/ 文件、CWD、历史记忆、"用所有工具"信号
     │
     ▼
意图解析 ──→ 17 种动作 × 10 个领域 × 范围 × 紧急度
     │
     ▼
信心打分 ────→ (intentMatch×0.5)+(contextRelevance×0.3)+((1-ambiguity)×0.2)
     │
     ├── ≥90 → 立刻路由（列出备选）
     ├── 70-89 → 路由（留意纠正）
     ├── 50-69 → 路由 + 标注低信心
     └── <50 → 澄清（给 3 个选项，不猜测）
     │
     ▼
编排 ───────→ 单技能 | 串联(A→B) | 并行(A∥B∥C) | 强制(code→review)
     │
     ├── 匹配 → 调用技能
     └── 无匹配 → L1 模糊 → L2 通用 → L3 人工+web-access
     │
     ▼
学习 ────────→ +2(确认)/+1(ok)/-1(忽略)/-2(纠正)
                net≥+3→稳定 | net≤-2→不可靠
```

| 能力 | 描述 |
|---|---|
| **8 步算法** | 紧急 → 环境 → 意图 → 信心 → 匹配 → 编排 → 兜底 → 学习 |
| **53 技能路由** | 10 个分类：内容(14)、文档(10)、网络(3)、规划(6)、质量(4)、通讯(2)、智能体(6)、API(2)、工具(4)、设计(3) |
| **常驻钩子** | SessionStart 注入，与 claude-mem 并存，~200 token，macOS/Linux/Windows |
| **中英混合** | 完整的中文触发词，混合中英文意图识别 |
| **环境扫描** | 读取 ~/ 和桌面文件、CWD 状态、历史记忆，个性化路由 |
| **信心公式** | 加权打分：意图匹配(50%)、上下文相关性(30%)、歧义度(20%) |
| **三级兜底** | L1：模糊子串匹配 → L2：原生 Claude 或通用技能 → L3：人工 + web-access GitHub 搜索 |
| **紧急模式** | 检测"救命/立刻/崩了/urgent/critical"，跳过环境扫描，平局时并行展开 |
| **多技能编排** | 串联链（A→B）、并行展开（A∥B∥C）、强制工作流（code→review） |
| **冲突解决** | 修复优先于审查、阻塞优先、具体优先于通用、用户历史胜出 |
| **自学习** | 追踪每对 intent→skill 的 +/- 信号，自动提升/降级，自适应信心阈值 |
| **交互式澄清** | 当信心 <50 时，给出 3 个具体选项，每个映射到一个技能 |
| **状态门** | 当 .cheat-state.json 不存在时，自动重定向 cheat-* 请求到 cheat-init |
| **零依赖** | 纯 markdown + shell + Node.js，不需要 Docker、数据库、Neo4j |
| **跨平台** | 一套代码覆盖 macOS/Linux/Windows，Node.js 钩子自动检测系统 |

### 从竞品整合的功能

| 来源 | 整合的功能 |
|---|---|
| **aiskillstore/router** | 信心公式、结构化意图提取、冲突解决、紧急路由、三级兜底、学习系统 |
| **charon-fan/skill-router** | 多技能编排（串联 + 并行）、交互式澄清 |
| **VCnoC/main-router** | 强制工作流链（code→review、security→audit） |
| **memex-claude** | 路由遥测（已升级为学习系统） |

### 我们独有而竞品没有的

- 常驻 SessionStart 钩子（无需手动调用）
- 完整中文触发词 + 中英混合路由
- 环境感知扫描（~/ + 桌面 + CWD）
- cheat-on-content 状态门集成
- 零基础设施（竞品需要 Docker/Neo4j/MCP 服务器）

---

## 核心原则

```
用户消息 → [紧急?] → 意图 → 信心 → 路由/编排/澄清
                                        ↓ (无匹配)
                                    三级兜底
```

- **检测到紧急？** → 跳过环境扫描，立刻路由
- **意图模糊？** → 交互式澄清（第 5 步）
- **多步骤？** → 编排链（第 4 步）
- **无匹配？** → 三级兜底（第 7 步）
- **用户确认/纠正？** → 学习系统记录信号（第 8 步）

---

## 路由算法（8 步）

### Step -1：紧急检测（在任何其他步骤之前）

检查用户消息中是否有**紧急信号**。如果检测到，跳过 Step 0.5（环境扫描），立刻路由：

**紧急关键词：** 紧急 / urgent / critical / "now" / "ASAP" / "立刻" / "马上" / "崩了" / "挂了" / "broke" / "production down" / "broken" / blocking / "救命"

**紧急模式行为：**
1. 完全跳过环境扫描（节省 10 秒）
2. 从路由表中选出信心最高的匹配，不做澄清
3. 如果 2+ 技能并列 → **并行展开**（同时调用，汇总结果）
4. 路由前加上 🚨 信号，让下游技能知道这是紧急情况
5. 紧急路由日志格式：`[ROUTE] 🚨 {skill} | EMERGENCY | no-context-scan`

### Step 0.5：环境扫描（< 30 秒）

快速环境扫描，尽量并行：

1. **主目录**
   - macOS/Linux: `ls ~/ | head -30`, `ls ~/Desktop/ | head -20`
   - Windows: `dir %USERPROFILE% /B`, `dir %USERPROFILE%\Desktop /B`
2. **当前工作目录**
   - macOS/Linux: `pwd && ls | head -20`
   - Windows: `cd && dir /B`
   - 检查：.cheat-state.json？package.json？go.mod？
3. **"用所有工具"信号** — 同之前的触发条件
4. **重复出现的话题** — 用 mem-search 查之前的会话模式

输出 2-3 个要点。没发现就跳过。

### Step 0.6：主动多技能模式

当检测到"用所有工具"信号时：
1. 始终添加 `mem-search` 作为辅助
2. 学习/研究 → 添加 `youtube-search`
3. 内容创作 → 添加 `cheat-trends`
4. 技术 → 添加 `deep-research`
5. 文档输出 → 可选添加 `theme-factory`

### Step 1：结构化意图提取

提取并打分以下五个维度：

```
意图分析 {
  动作:     修 | 审 | 写 | 测 | 规划 | 探索 | 提交 | 构建 | 部署 | 优化 | 创建 | 分析 | 搜索 | 发布 | 学习 | 转换 | 合并
  领域:     内容 | 网页 | 文档 | 代码 | 记忆 | 设计 | 基础设施 | 学习 | 数据 | 通讯
  范围:     单步 | 多步 | 跨会话
  紧急度:   立刻 | 稍后 | 规划中
  产出物:   [文件路径、扩展名、提到的 URL]
}
```

**动作动词映射** — 动作动词是最强的信号：
- "修/改/fix/debug/报错/bug" → fix → code-review 或 security-review
- "审查/review/检查/audit" → review → review 或 security-review
- "写/撰/生成/create/make/generate" → create → 看领域
- "搜/找/查/search/find/lookup" → search → mem-search 或 web-access 或 youtube-search
- "计划/规划/plan/phase/roadmap" → plan → make-plan（代码）或 doc-coauthoring（非代码）
- "部署/deploy/publish/release" → deploy → claude-code-plugin-release
- "优化/optimize/improve performance" → optimize → cost-aware-llm-pipeline 或 simplify
- "学/study/learn/学习" → learn → doc-coauthoring + youtube-search + mem-search

### Step 2：信心打分公式

对每个候选技能，计算：

```
score = (intentMatch × 0.5) + (contextRelevance × 0.3) + ((1 - ambiguity) × 0.2)
```

其中：
- **intentMatch** (0-1)：动作动词 + 领域与路由表的匹配程度
- **contextRelevance** (0-1)：环境扫描结果对该技能的支持程度（~/ 下相关文件？之前会话匹配？）
- **ambiguity** (0-1)：反向指标——如果用户意图可能意味着 3+ 种不同的事情，歧义度就高

转换为信心级别：
- score ≥ 0.9 → **100 信心**（立刻路由）
- score 0.7-0.89 → **90 信心**（高信心路由）
- score 0.5-0.69 → **70 信心**（路由但留意退路）
- score < 0.5 → **50 或以下** → 触发**交互式澄清**（Step 5）

### Step 3：匹配路由表

读取 `references/routing-table.md`。按以下优先级匹配：

1. **文件扩展名** (.pdf/.xlsx/.docx/.pptx/.csv) → 最强信号，立刻路由。但仍然列出备选。
2. **精确触发词**（信心 100）→ 立刻路由。但仍然列出备选。
3. **领域 + 动作组合**（信心 70-90）→ 路由并标注信心级别
4. **基于上下文** → .cheat-state.json 状态门、Step 0.5 的个人上下文
5. **个人上下文** → 之前会话模式、~/ 下文件

### Step 4：多技能编排

> 具体场景→模式→技能的映射，见 **routing-table.md: 编排模式参考**。

当用户意图需要 2+ 个技能时，选择合适的编排模式：

**模式 A：串联链**（技能 A 的输出是技能 B 的输入）
```
技能 A → 技能 B → 技能 C
示例：deep-research（收集数据）→ doc-coauthoring（写报告）
示例：make-plan（创建计划）→ do（执行计划）
```

**模式 B：并行展开**（独立任务、共享目标）
```
       ┌→ 技能 A（研究日本学术环境）
用户 → ┼→ 技能 B（搜索 YouTube JLPT 学习资源）
       └→ 技能 C（搜索记忆中的学习计划）
                        ↓
              技能 D（doc-coauthoring — 整理成计划）
```

**模式 C：强制工作流**（来自 VCnoC 的强制链）
```
代码生成 → 代码审查（强制）
安全相关 → 安全审查（强制）
cheat-score → cheat-predict（发布前）
```

**编排决策规则：**
- 如果技能 A 的输出喂给技能 B → 串联链
- 如果 2+ 技能可以独立运行 → 并行展开
- 如果领域有强制工作流规则 → 应用它，不要跳过

### Step 5：交互式澄清

当信心 < 50 或歧义度 > 0.5 时：

**不要猜。问。** 给出聚焦的问题（不是开放式的"你想干嘛？"）：

```
我看到你的请求中有几种可能性。你更想让我：

1. [具体选项A — 对应技能 X] — "用 deep-research 做一份详细的研究报告"
2. [具体选项B — 对应技能 Y] — "用 web-access 快速浏览几个网站找答案"
3. [具体选项C — 自己处理] — "不用 skill，直接告诉我"

哪一个更接近你想要的？
```

**澄清规则：**
- 最多 3 个选项，绝不超过
- 每个选项映射到一个具体技能或动作
- 绝对不问"你想做什么？"——始终给出具体路径
- 如果用户忽略澄清说"直接做"→ 选 #1 执行

### Step 6：冲突解决

当 2+ 技能同样有效时，按以下规则打破平局：

1. **修复优先于审查** — 如果一个技能修复问题、另一个审查它，先路由到修复
2. **阻塞问题优先** — 如果一个任务阻塞另一个，先路由阻塞者
3. **具体优先于通用** — `deep-research` 优于 `web-access` 做研究报告；`xlsx` 优于 `canvas-design` 做数据图表
4. **用户历史胜出** — 如果用户对类似请求使用技能 A 的次数是 B 的 3 倍，选 A
5. **强制链优先** — 如果存在强制工作流，按顺序执行

---

## 调用方式

```markdown
Skill(skill="<最佳匹配>", args="<用户消息>")
```

多技能链则依次调用（等第一个完成再调第二个）。

---

## 什么时候不路由

- **用户明确指定了技能**："用 pdf 技能……" → 尊重用户
- **琐碎的一步操作**："2+2"、"谢谢"、"ok"、"ls"
- **纯闲聊**："你好"、"讲个笑话"
- **原生工具足够**：简单"读这个文件"、"列出目录"

---

## 快速参考

| 用户说…… | 路由到 | 模式 |
|---|---|---|
| "帮我分析稿子/打分" | cheat-score（状态门 → cheat-init） | 单技能 |
| "处理 PDF/Excel/Word/PPT" | pdf/xlsx/docx/pptx | 单技能 |
| "深入研究X/写分析报告" | deep-research → doc-coauthoring | 串联 |
| "搜视频/找教程" | youtube-search | 单技能 |
| "写学习计划（把工具都用上）" | doc-coauthoring ∥ youtube-search ∥ mem-search | 并行 |
| "做功能/写plan" | make-plan → do | 串联 |
| "代码审查" | review | 单技能 |
| "我上次怎么做的" | mem-search | 单技能 |

---

## 常见陷阱

1. "计划" → 检查领域。make-plan 用于代码，doc-coauthoring 用于生活/学习
2. 文件扩展名是王道 — .pdf 绝对不会路由到 xlsx
3. 状态门在 cheat-* 路由前**始终**检查
4. 没有 .cheat-state.json 时"打分" → 路由到 cheat-init，不是 cheat-score
5. "用所有工具" → 始终触发主动多技能模式

---

## Step 7：三级兜底（无技能匹配时）

当所有技能的信心都 < 50 时，不要直接失败。逐级升级：

**第一级：模糊匹配** — 扫描所有已安装技能名，找近邻匹配
- 用简单的子串/编辑距离逻辑：用户的意图词是否出现在某个技能名或描述中？
- 示例：用户说"帮我压缩图片" → 无精确匹配 → 模糊匹配也没找到"image-compress"技能 → 降到第二级
- 示例：用户说"帮我commit代码" → 模糊匹配找不到"git"技能名 → 降到第二级
- 如果模糊匹配找到一个 score ≥ 0.4 的候选 → 路由过去并附注："我没有找到完全匹配的 skill，但 `X` 看起来最接近。用这个试试？"

**第二级：通用处理** — 路由到最佳通用处理器
- 编码/技术任务 → 路由到通用 coding agent（原生 Claude 编码，无需专门技能）
- 研究/学习任务 → `deep-research`（即使低信心，总比没有好）
- 内容创作任务 → `cheat-seed`（选题探索）或原生 Claude 写作
- 文档任务 → 原生 Claude（基础操作不需要专门技能）
- 未知领域 → 原生 Claude 附注："我用自己的能力处理这个。如果经常遇到这类请求，建议装一个专门的 skill。"

**第三级：人工介入** — 仅当前两级都失败或用户明显不满时
- 输出清晰有用的信息：

> ⚠️ 我没有找到处理这个请求的专用工具，也无法用通用能力替代。你可以：
> ① 自行下载对应 skill → `git clone <url> ~/.claude/skills/`
> ② 说"帮我用 web-access 找一个能做 X 的 skill"，我帮你在 GitHub 上找
> ③ 告诉我更多细节，也许我能换一种方式帮你

- 如果用户选 ② → 调用 `web-access` 搜索 GitHub 上相关技能，引导下载安装

**兜底决策树：**
```
无匹配（所有信心 < 50）
  → 第一级：模糊匹配 ≥ 0.4？→ 附注路由
  → 第一级失败 → 第二级：原生 Claude 或通用技能能处理吗？→ 原生处理
  → 第二级失败 → 第三级：人工介入，给出 3 个选项
```

---

## Step 8：学习系统（自校准路由器）

路由器通过追踪每次路由决策的信号来不断改进。不需要外部数据——只需要观察用户行为。

### 信号类型

| 信号 | 触发条件 | 效果 |
|---|---|---|
| **+2（强正向）** | 用户明确确认路由（"对"/"yes"/"exactly"） | 将 intent→skill 对的信心提升 0.1 |
| **+1（弱正向）** | 用户静默接受路由，任务无纠正完成 | 小幅提升：标记该对为"已使用" |
| **-1（弱负向）** | 用户忽略路由，问了别的事 | 小幅惩罚：降低该对相关性 |
| **-2（强负向）** | 用户明确纠正（"不对"/"不是这个"/"I meant..."） | 降级该对：设信心上限为 70，下次强制澄清 |

### 稳定性追踪

对每个 intent→skill 对，维护一个计数：
```
{动作}+{领域} → {技能}: +2,+1,+1,-2 = net +2（稳定，低风险）
{动作}+{领域} → {技能}: +1,-2,-2 = net -3（不可靠，永远澄清）
```

**升级阈值：** net ≥ +3 → 该对**稳定**。无需澄清，自动路由。如果经历 5+ 会话，升级到快速参考。

**降级阈值：** net ≤ -2 → 该对**不可靠**。对此对始终显示交互式澄清（Step 5），不自动路由。

**重置：** 30 天无活动后，重置该对为中性（net=0）。意图模式会随时间变化。

### 自适应阈值

"立刻路由 vs 问澄清"的信心阈值根据整体学习健康度自适应：

- **起始：** 阈值 = 90（保守——不确定就问）
- **10+ 稳定对之后：** 阈值 = 70（自信——多路由）
- **3+ 降级之后：** 阈值 = 95（退一步——多问，从错误中学习）

### 学习日志格式

```
[LEARN] {意图} → {技能} | signal={+2/+1/-1/-2} | net={N} | status={stable|unreliable|neutral}
```

来自 Match Telemetry v1（现已合并到学习系统）的路由日志格式：
```
[ROUTE] {技能} | intent={动作}+{领域} | score={0.XX} | pattern={single|sequential|parallel}
```

### 自学习 vs 外部学习

- **内部（本系统）**：追踪路由准确度、调整阈值、提升/降级技能对
- **外部（continuous-learning-v2）**：从完整会话中提取本能、进化技能——互补，不冗余
- 学习系统向 continuous-learning-v2 输送：当某个对变稳定后，建议为它创建专用技能或本能

---

## 常驻架构

Skill-router 通过 **SessionStart 钩子**与 claude-mem 一起注入：

```
SessionStart → claude-mem 钩子（记忆上下文）→ skill-router 钩子（路由层）→ Claude 就绪
```

### 钩子注册（跨平台）

**推荐（所有平台）：Node.js 钩子**
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
Windows：把命令中的 `~/.claude/` 替换为 `%USERPROFILE%\\.claude\\`。

**备用（macOS/Linux）：bash**
```json
{"command": "bash ~/.claude/skills/skill-router/hooks/session-start.sh"}
```

**备用（Windows）：PowerShell**
```json
{"command": "powershell -ExecutionPolicy Bypass -File %USERPROFILE%\\.claude\\skills\\skill-router\\hooks\\session-start.ps1"}
```

### 平台检测

Node.js 钩子自动检测操作系统并调整：
- **路径格式**：Unix 用 `~/`，Windows 用 `%USERPROFILE%`
- **环境扫描命令**：Unix 用 `ls`/`pwd`，Windows 用 `dir`/`cd`
- **技能计数**：读取目录，Windows 上大小写不敏感

---

## 自我维护

- 新技能安装 → 同一会话内更新 `references/routing-table.md`
- 3+ 稳定 intent→skill 对 → 升级到快速参考
- 用户纠正路由 → 降级该对、审查路由表
- 路由表超过 200 行 → 归档过期条目（30+ 天未使用）
