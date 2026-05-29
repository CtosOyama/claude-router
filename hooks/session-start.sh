#!/bin/bash
# skill-router v5 — bash fallback (when Node.js unavailable)
# Tries Node.js first; falls back to minimal static output.

NODE_SCRIPT="$HOME/.claude/skills/skill-router/hooks/session-start.js"

if command -v node &>/dev/null && [ -f "$NODE_SCRIPT" ]; then
  node "$NODE_SCRIPT"
  exit $?
fi

# Minimal fallback when Node.js is absent
cat << 'ROUTER_CONTEXT'
<system-reminder>
## Router v5: skill routing active (Node.js unavailable; static fallback)
编排: deep-research→wowerpoint | make-plan→do | xlsx→pptx
</system-reminder>
ROUTER_CONTEXT

echo '{"continue":true,"suppressOutput":false}'
