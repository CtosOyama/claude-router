# skill-router v5 — PowerShell fallback (when Node.js unavailable)
# Tries Node.js first; falls back to minimal static output.

$nodeScript = "$env:USERPROFILE\.claude\skills\skill-router\hooks\session-start.js"

if (Get-Command node -ErrorAction SilentlyContinue) {
  if (Test-Path $nodeScript) {
    node $nodeScript
    exit $LASTEXITCODE
  }
}

# Minimal fallback
Write-Output @"
<system-reminder>
## Router v5: skill routing active (Node.js unavailable; static fallback)
Orchestration: deep-research→wowerpoint | make-plan→do | xlsx→pptx
</system-reminder>
"@

Write-Output '{"continue":true,"suppressOutput":false}'
