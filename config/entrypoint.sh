#!/bin/bash
set -eu

echo "Starting Code-Server development environment..."

# Initialize uv
if [ -s "/home/coder/.local/bin/env" ]; then
    echo "Loading uv environment..."
    . /home/coder/.local/bin/env
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
    --config /config/config.yaml \
    --user-data-dir /home/coder/.local/share/code-server \
    --extensions-dir /home/coder/.local/share/code-server/extensions \
    /workspace
