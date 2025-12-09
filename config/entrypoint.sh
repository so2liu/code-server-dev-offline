#!/bin/bash
set -eu

echo "Starting Code-Server development environment..."

# Initialize nvm (for compatibility with blade-code-server users)
if [ -s "/root/.nvm/nvm.sh" ]; then
    echo "Loading nvm environment..."
    . /root/.nvm/nvm.sh
fi

# Start CCR (Claude Code Router) in background
echo "Starting CCR (Claude Code Router)..."
ccr ui &

# Wait a moment for CCR to start
sleep 2

echo "CCR started on port 3456"
echo "Access CCR UI at: http://localhost:3456/ui"

# Start code-server
echo "Starting code-server..."
exec code-server \
    --bind-addr 0.0.0.0:8080 \
    --config /root/.config/code-server/config.yaml \
    --user-data-dir /root/.local/share/code-server \
    --extensions-dir /root/.local/share/code-server/extensions \
    /workspace
