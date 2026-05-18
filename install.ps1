# skill-router v4 — Windows PowerShell Installer
# Run: powershell -ExecutionPolicy Bypass -File install.ps1
# Or right-click → "Run with PowerShell"

$ErrorActionPreference = "Stop"
$SkillName = "skill-router"
$SkillDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeSkills = "$env:USERPROFILE\.claude\skills"
$SettingsFile = "$env:USERPROFILE\.claude\settings.local.json"

Write-Host "┌─────────────────────────────────────────┐" -ForegroundColor Cyan
Write-Host "│  skill-router v4 — Windows Installer    │" -ForegroundColor Cyan
Write-Host "│  Platform: Windows                      │" -ForegroundColor Cyan
Write-Host "└─────────────────────────────────────────┘" -ForegroundColor Cyan
Write-Host ""

# ── Check prerequisites ─────────────────────────────────
if (-not (Test-Path $ClaudeSkills)) {
    Write-Host "✗ $ClaudeSkills not found. Is Claude Code installed?" -ForegroundColor Red
    Write-Host "  Install Claude Code first: https://claude.ai/code"
    exit 1
}
Write-Host "✓ Claude Code found" -ForegroundColor Green

# ── Remove old install ───────────────────────────────────
$TargetDir = "$ClaudeSkills\$SkillName"
if (Test-Path $TargetDir) {
    Write-Host "⚠ Removing previous install..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $TargetDir
}

# ── Install (copy — Windows has no symlink) ──────────────
Write-Host ""
Write-Host "Installing skill files..." -ForegroundColor Cyan
Copy-Item -Recurse -Force "$SkillDir" "$TargetDir"
Write-Host "✓ Copied to $TargetDir" -ForegroundColor Green

# Verify key files
@("SKILL.md", "references\routing-table.md", "hooks\session-start.js", "hooks\session-start.ps1") | ForEach-Object {
    if (Test-Path "$TargetDir\$_") {
        Write-Host "✓ $_" -ForegroundColor Green
    } else {
        Write-Host "✗ $_ MISSING" -ForegroundColor Red
    }
}

# ── Choose hook ──────────────────────────────────────────
Write-Host ""
Write-Host "Registering SessionStart hook..." -ForegroundColor Cyan

$HookCmd = $null
$nodePath = (Get-Command node -ErrorAction SilentlyContinue).Source

if ($nodePath) {
    $escapedPath = $TargetDir -replace '\\', '\\'
    $HookCmd = "node $escapedPath\\hooks\\session-start.js"
    Write-Host "✓ Using Node.js hook" -ForegroundColor Green
} else {
    $HookCmd = "powershell -ExecutionPolicy Bypass -File `"$TargetDir\hooks\session-start.ps1`""
    Write-Host "⚠ Node.js not found. Using PowerShell fallback." -ForegroundColor Yellow
}

# ── Register hook ────────────────────────────────────────
try {
    if (-not (Test-Path $SettingsFile)) {
        @{} | ConvertTo-Json | Set-Content $SettingsFile
        Write-Host "✓ Created $SettingsFile" -ForegroundColor Green
    }

    $settings = Get-Content $SettingsFile -Raw | ConvertFrom-Json -AsHashtable

    if (-not $settings.hooks) { $settings.hooks = @{} }
    if (-not $settings.hooks.SessionStart) { $settings.hooks.SessionStart = @() }

    $alreadyRegistered = $false
    foreach ($entry in $settings.hooks.SessionStart) {
        if ($entry.hooks[0].command -like "*skill-router*") {
            $alreadyRegistered = $true
            break
        }
    }

    if (-not $alreadyRegistered) {
        $hookEntry = @{
            matcher = "startup|clear|compact"
            hooks = @(@{ type = "command"; command = $HookCmd })
        }
        $settings.hooks.SessionStart += $hookEntry

        $settings | ConvertTo-Json -Depth 10 | Set-Content $SettingsFile
        Write-Host "✓ Hook registered" -ForegroundColor Green
    } else {
        Write-Host "⚠ Hook already registered. Skipping." -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Failed to register hook. Add this manually to $SettingsFile`:" -ForegroundColor Red
    Write-Host "  $HookCmd" -ForegroundColor Yellow
}

# ── Verify ───────────────────────────────────────────────
Write-Host ""
Write-Host "Verifying installation..." -ForegroundColor Cyan

if ($nodePath) {
    $output = & node "$TargetDir\hooks\session-start.js" 2>&1
    if ($output -match "skill-router") {
        Write-Host "✓ Hook script works (Node.js)" -ForegroundColor Green
    } else {
        Write-Host "✗ Hook script failed" -ForegroundColor Red
    }
}

$skillCount = (Get-ChildItem -Path $ClaudeSkills -Directory).Count
Write-Host "✓ $skillCount skills in $ClaudeSkills" -ForegroundColor Green

# ── Done ─────────────────────────────────────────────────
Write-Host ""
Write-Host "┌─────────────────────────────────────────┐" -ForegroundColor Green
Write-Host "│  ✅ skill-router v4 installed!           │" -ForegroundColor Green
Write-Host "└─────────────────────────────────────────┘" -ForegroundColor Green
Write-Host ""
Write-Host "  Next steps:"
Write-Host "  1. Restart Claude Code (or /clear)"
Write-Host "  2. The router activates automatically"
Write-Host "  3. Missing a skill? Ask: 'help me find a skill for X'"
Write-Host ""
Write-Host "  Uninstall: Remove-Item -Recurse -Force $TargetDir"
Write-Host "  Update: cd $SkillDir; git pull"
