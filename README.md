# Skill Router v5

> Claude Code 技能的动态上下文路由层。SessionStart hook 注入实时扫描的技能计数、桌面文件提示和多步骤编排模式。

## 与 v4 的区别

v4 是静态提示词注入——每次输出 35 行相同文本，带有硬编码的 "53 skills" 声明和一个 LLM 需要在脑子里执行的虚构"8步算法"。

v5 运行真实的计算：
- **实时扫描** `~/.claude/skills/` 获取实际已安装技能数量
- **检测桌面文件**并按扩展名映射到对应技能 (pdf → pdf, xlsx → xlsx...)
- **追踪会话连续性**：记录上次使用的技能，下次提示
- **检测失效引用**：常见技能未安装时发出警告
- **多步骤编排提示**：显示 deep-research→wowerpoint, make-plan→do 等模式
- **输出 ~5 行**，而非 35 行

## 安装

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/CtosOyama/claude-router/main/install-remote.sh | bash
```

### 手动安装

1. 把仓库放到 `~/.claude/skills/skill-router/`
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

## 卸载

```bash
rm -rf ~/.claude/skills/skill-router
# 然后从 ~/.claude/settings.local.json 移除对应的 hook 条目
```

## 更新

```bash
cd ~/.claude/skills/skill-router && git pull
```

## 文件

```
skill-router/
├── SKILL.md                 技能定义
├── hooks/
│   ├── session-start.js     Node.js hook (推荐)
│   ├── session-start.sh     Bash 备用
│   └── session-start.ps1    PowerShell 备用
└── references/
    └── routing-table.md     技能路由索引
```
