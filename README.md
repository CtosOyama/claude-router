# Skill Router

> Claude Code 的常驻意图路由层 — 53 个技能，1 个调度器，零配置。
>
> Always-on intent routing layer for Claude Code — 53 skills, one dispatcher, zero config.

[:globe_with_meridians: 双语网站 / Bilingual Website](https://ctosoyama.github.io/claude-router)

---

## 它做了什么

你每次跟 Claude Code 说话，Skill Router 会在后台自动做一件事：**你说的这句话，用哪个技能最合适？**

用大白话讲，它就像一个 smart 接线员：

| 步骤 | 做了什么 | 比喻 |
|---|---|---|
| 🚨 | 先看是不是紧急情况（"救命""挂了"）→ 是就直接转接 | 119 火警电话 |
| 🔍 | 扫一眼你的桌面、文件夹、历史记录 → 了解你在干什么 | 接线员问"你现在在哪" |
| 🎯 | 从你的话里拆出：想干什么 + 在什么领域 + 多复杂 | 接线员理解你的诉求 |
| 📊 | 给每个候选技能打个分 → 分数高的胜出 | 接线员判断该转哪个部门 |
| 🔗 | 如果一个技能不够 → 自动串联或并行多个 | 复杂问题转接多个部门 |
| 🛟 | 实在匹配不上 → 模糊找、通用处理、最后问你 | 实在不行人工台 |
| 📚 | 记住你的每次反馈 → 对的加强、错的修正 → 越用越懂你 | 老接线员记住你的习惯 |

---

## 举个例子

你说一句稀松平常的话，它会自动找到对应的技能：

| 你说 | 路由器调用 |
|---|---|
| "帮我处理这个 PDF 文件" | `pdf` |
| "把这个 Excel 做成图表" | `xlsx` |
| "帮我写一份调研报告" | `deep-research` → `doc-coauthoring`（串联） |
| "搜索这个技术的视频教程" | `youtube-search` |
| "制定学习计划（所有工具都上）" | `doc-coauthoring` ∥ `youtube-search` ∥ `web-access`（并行） |
| "帮我审查这段代码" | `review` |
| "上次那个 bug 怎么修的" | `mem-search` |
| "救命线上挂了" | 🚨 紧急模式 → 立刻路由 |

---

## 安装

### macOS / Linux — 一条命令

```bash
curl -fsSL https://raw.githubusercontent.com/CtosOyama/claude-router/main/install-remote.sh | bash
```

### Windows — 一条命令

```powershell
git clone https://github.com/CtosOyama/claude-router.git $env:TEMP\skill-router; cd $env:TEMP\skill-router; powershell -ExecutionPolicy Bypass -File install.ps1
```

### 手动安装

1. 复制本仓库到 `~/.claude/skills/skill-router/`
2. 在 `~/.claude/settings.local.json` 中添加：

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

## 文件结构

```
skill-router/
├── SKILL.md                 完整路由算法文档
├── README.md                你正在读
├── index.html               双语网站页面
├── install.sh               macOS/Linux 安装器
├── install.ps1              Windows 安装器
├── install-remote.sh        远程一键安装
├── hooks/
│   ├── session-start.js     Node.js 钩子（推荐）
│   ├── session-start.sh     Bash 备用
│   └── session-start.ps1    PowerShell 备用
└── references/
    └── routing-table.md     53 技能路由表
```

---

## 卸载

```bash
rm -rf ~/.claude/skills/skill-router
# 然后从 ~/.claude/settings.local.json 中移除 hook
```

## 更新

```bash
cd /tmp/skill-router && git pull
# macOS/Linux 上 symlink 自动更新，Windows 上重新运行 install.ps1
```
