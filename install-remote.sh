#!/bin/bash
# skill-router one-liner remote installer
# Usage: curl -fsSL https://raw.githubusercontent.com/ctosOyama/skill-router/main/install-remote.sh | bash
set -e

REPO="https://github.com/ctosOyama/skill-router.git"
TMPDIR="/tmp/skill-router"

echo "📦 skill-router — one-liner installer"
echo ""

# Clone
if [ -d "$TMPDIR" ]; then
    echo "⏭  $TMPDIR exists, pulling latest..."
    cd "$TMPDIR" && git pull --ff-only 2>/dev/null || rm -rf "$TMPDIR" && git clone "$REPO" "$TMPDIR"
else
    git clone "$REPO" "$TMPDIR"
fi

# Run local installer
cd "$TMPDIR" && bash install.sh
