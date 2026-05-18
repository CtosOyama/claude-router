<div align="right">

[**English**](./README_EN.md) | **中文**

</div>

# Skill Router

> 53 个 Claude Code 技能的自动调度层。随会话启动，静默运行，零配置。

---

## 用途

你每次对 Claude Code 说话，Skill Router 都会在后台回答一个问题：**这句话该交给哪个技能处理。**

它本质上是一个调度策略——不执行具体任务，只是把每条指令调度到最合适的目的地。

| 环节 | 任务 | 类比 |
|---|---|---|
| 🚨 | 识别紧急信号（"救命""挂了"），命中则跳过后续直接调技能 | 急诊分诊 |
| 🔍 | 扫一眼桌面、工作目录、历史会话，建立上下文 | 了解现场 |
| 🎯 | 从句子中拆出：要做什么、在哪个领域、多大范围 | 意图拆解 |
| 📊 | 给每个候选技能打分，高分胜出 | 匹配度计算 |
| 🔗 | 复杂任务自动编排多个技能，决定串行还是并行 | 任务编排 |
| 🛟 | 匹配不上时逐级降级：模糊匹配→通用处理→交还用户 | 兜底策略 |
| 📚 | 记录每次调度结果的用户反馈，自动调整后续决策 | 自校准 |

---

## 示例

日常指令与调度结果：

| 用户输入 | 调度结果 |
|---|---|
| "帮我处理这个 PDF" | `pdf` |
| "把这 Excel 做成图表" | `xlsx` |
| "写一份行业调研报告" | `deep-research` → `doc-coauthoring`（串行） |
| "搜一下这个技术的视频教程" | `youtube-search` |
| "出个学习计划（能用的工具都上）" | `doc-coauthoring` ∥ `youtube-search` ∥ `web-access`（并行） |
| "审查一下这段代码" | `review` |
| "上次那个 bug 怎么修的来着" | `mem-search` |
| "救命，线上挂了" | 🚨 直接调度 |

---

## 安装

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/CtosOyama/claude-router/main/install-remote.sh | bash
```

### Windows

```powershell
git clone https://github.com/CtosOyama/claude-router.git $env:TEMP\skill-router; cd $env:TEMP\skill-router; powershell -ExecutionPolicy Bypass -File install.ps1
```

### 手动安装

1. 把仓库复制到 `~/.claude/skills/skill-router/`
2. 编辑 `~/.claude/settings.local.json`：

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

## 文件

```
skill-router/
├── SKILL.md                 完整调度算法（英文）
├── SKILL_CN.md              完整调度算法（中文）
├── README.md                本文件（中文）
├── README_EN.md             英文版
├── index.html               双语站点
├── install.sh               macOS/Linux 安装
├── install.ps1              Windows 安装
├── install-remote.sh        远程一键安装
├── hooks/
│   ├── session-start.js     Node.js 钩子（推荐）
│   ├── session-start.sh     Bash 备用
│   └── session-start.ps1    PowerShell 备用
└── references/
    └── routing-table.md     53 技能路由映射表
```

---

## 卸载

```bash
rm -rf ~/.claude/skills/skill-router
# 随后从 ~/.claude/settings.local.json 里移除对应的 hook 条目
```

## 更新

```bash
cd /tmp/skill-router && git pull
# macOS/Linux 上 symlink 会自动指向新版本。Windows 需重新运行 install.ps1
```
