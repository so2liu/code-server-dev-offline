#!/bin/bash
set -e

# VSCode extensions installation script for code-server
# This script installs extensions directly into the code-server extensions directory

# Set extensions directory to coder user's location
EXTENSIONS_DIR="/home/coder/.local/share/code-server/extensions"
mkdir -p "$EXTENSIONS_DIR"

EXTENSIONS=(
    # Python development
    "ms-python.python"
    "ms-python.debugpy"
    "ms-python.vscode-python-envs"
    "detachhead.basedpyright"

    # Code quality
    "charliermarsh.ruff"
    "usernamehw.errorlens"

    # AI coding assistant
    "saoudrizwan.claude-dev"

    # Version control
    "eamodio.gitlens"

    # Database tools
    "mtxr.sqltools"
    "mtxr.sqltools-driver-pg"
    "qwtel.sqlite-viewer"

    # React development
    "dsznajder.es7-react-js-snippets"
    "esbenp.prettier-vscode"

    # Vim
    "vscodevim.vim"
)

echo "Installing VSCode extensions for code-server..."

for extension in "${EXTENSIONS[@]}"; do
    echo "Installing: $extension"
    code-server --extensions-dir "$EXTENSIONS_DIR" --install-extension "$extension" || echo "Failed to install $extension, continuing..."
done

echo "Extension installation complete!"
