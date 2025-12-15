#!/bin/bash
set -eu

# Fix UID/GID to match mounted volumes
fixuid -q

# Support dynamic user renaming via DOCKER_USER env var
if [ "${DOCKER_USER-}" ]; then
  USER_NAME="$DOCKER_USER"
  if [ -z "$(id -u "$DOCKER_USER" 2>/dev/null)" ]; then
    echo "$DOCKER_USER ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers.d/nopasswd > /dev/null
    usermod --login "$DOCKER_USER" coder
    groupmod -n "$DOCKER_USER" coder
    sed -i "/coder/d" /etc/sudoers.d/nopasswd
  fi
else
  USER_NAME="coder"
fi

# Switch to coder user and run the rest of the script
exec gosu "$USER_NAME" /bin/bash << 'USERSCRIPT'
set -eu

echo "Starting Code-Server development environment..."

# Initialize nvm
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    echo "Loading nvm environment..."
    . "$NVM_DIR/nvm.sh"
fi

# Start CCR in background
echo "Starting CCR (Claude Code Router)..."
ccr ui &
sleep 2
echo "CCR started on port 3456"
echo "Access CCR UI at: http://localhost:3456/ui"

# Start code-server
echo "Starting code-server..."
exec code-server \
    --bind-addr 0.0.0.0:8080 \
    --config "$HOME/.config/code-server/config.yaml" \
    --user-data-dir "$HOME/.local/share/code-server" \
    --extensions-dir "$HOME/.local/share/code-server/extensions" \
    /workspace
USERSCRIPT
