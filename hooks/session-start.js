#!/usr/bin/env node
/**
 * skill-router v5 — Context-Aware Dynamic Router
 *
 * What it actually computes (not prints as prose):
 *   1. Scans ~/.claude/skills/ for real installed skills → count
 *   2. Reads ~/Desktop/ for file extensions → maps to relevant skill hints
 *   3. Checks for cheat-state.json → gate for cheat-* skills
 *   4. Loads router state file → session continuity hints
 *   5. Detects dead references (common skills not installed)
 *   6. Multi-step orchestration hint
 *
 * Output target: < 10 lines. Dynamic. Actually useful.
 */

const os = require('os');
const fs = require('fs');
const path = require('path');

const HOME = os.homedir();
const SKILLS_DIR = path.join(HOME, '.claude', 'skills');
const DESKTOP = path.join(HOME, 'Desktop');
const STATE_DIR = path.join(HOME, '.claude', 'skills', 'skill-router', 'state');
const STATE_FILE = path.join(STATE_DIR, 'router-state.json');
const CHEAT_STATE = path.join(HOME, 'cheat-on-content', '.cheat-state.json');

// ── 1. Skill scanner ──────────────────────────────────────────
function scanSkills() {
  const names = [];
  try {
    for (const entry of fs.readdirSync(SKILLS_DIR, { withFileTypes: true })) {
      if (entry.isDirectory() || entry.isSymbolicLink()) {
        const skillMd = path.join(SKILLS_DIR, entry.name, 'SKILL.md');
        try { if (fs.statSync(skillMd).isFile()) names.push(entry.name); }
        catch (_) { /* no SKILL.md — skip */ }
      }
    }
  } catch (_) { /* skills dir missing */ }
  return names;
}

// ── 2. Desktop scanner ─────────────────────────────────────────
const EXT_TO_SKILL = {
  '.pdf': 'pdf', '.xlsx': 'xlsx', '.xls': 'xlsx', '.csv': 'xlsx',
  '.docx': 'docx', '.ppt': 'pptx', '.pptx': 'pptx',
  '.png': 'canvas-design', '.jpg': 'canvas-design', '.jpeg': 'canvas-design',
};

function scanDesktop() {
  const skills = new Set();
  try {
    const entries = fs.readdirSync(DESKTOP, { withFileTypes: true });
    for (const entry of entries) {
      if (!entry.isFile()) continue;
      const ext = path.extname(entry.name).toLowerCase();
      const s = EXT_TO_SKILL[ext];
      if (s) skills.add(s);
    }
  } catch (_) { /* desktop unreadable */ }
  return [...skills];
}

// ── 3. Cheat state gate ────────────────────────────────────────
function hasCheatState() {
  try { fs.statSync(CHEAT_STATE); return true; }
  catch (_) { return false; }
}

// ── 4. State engine ────────────────────────────────────────────
function loadState() {
  try { return JSON.parse(fs.readFileSync(STATE_FILE, 'utf8')); }
  catch (_) { return null; }
}

function saveState(state) {
  try {
    fs.mkdirSync(STATE_DIR, { recursive: true });
    fs.writeFileSync(STATE_FILE, JSON.stringify(state, null, 2));
  } catch (_) { /* no-op */ }
}

// ── 5. Dead reference detection ────────────────────────────────
const COMMONLY_REFERENCED = [
  'deep-research', 'web-access', 'youtube-search', 'mem-search',
  'pdf', 'xlsx', 'docx', 'pptx', 'canvas-design',
  'make-plan', 'do', 'review', 'security-review',
  'frontend-design', 'wowerpoint', 'blueprint', 'babysit',
];

function detectDeadRefs(installed) {
  const set = new Set(installed);
  return COMMONLY_REFERENCED.filter(s => !set.has(s));
}

// ── 6. Build output ────────────────────────────────────────────
function buildOutput() {
  const skills = scanSkills();
  const deskHints = scanDesktop();
  const state = loadState();
  const deadRefs = detectDeadRefs(skills);
  const cheatReady = hasCheatState();
  const platform = os.platform();

  const lines = [];

  // Core line
  let core = `## Router v5: ${skills.length} skills | ${platform}`;
  if (deskHints.length > 0) core += ` | 桌面: ${deskHints.join(',')}`;
  if (cheatReady) core += ` | cheat就绪`;
  lines.push(core);

  // Session continuity
  if (state && state.skillsUsed && state.skillsUsed.length > 0) {
    lines.push(`上次会话: ${state.skillsUsed.slice(-5).join(' → ')}`);
  }

  // Dead refs (only if found)
  if (deadRefs.length > 0) {
    lines.push(`未安装: ${deadRefs.slice(0, 5).join(', ')}`);
  }

  // Orchestration hint
  lines.push('编排: deep-research→wowerpoint | make-plan→do | xlsx→pptx');

  // Update / create state
  if (state) {
    state.lastSession = new Date().toISOString();
    saveState(state);
  } else {
    saveState({
      version: 1,
      lastSession: new Date().toISOString(),
      skillsUsed: [],
    });
  }

  return `<system-reminder>\n${lines.join('\n')}\n</system-reminder>`;
}

// ── 7. Output ──────────────────────────────────────────────────
console.log(buildOutput());
console.log(JSON.stringify({ continue: true, suppressOutput: false }));
