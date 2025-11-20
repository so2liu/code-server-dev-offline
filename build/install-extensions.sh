#!/bin/bash
set -e

# VSCode extensions installation script for code-server
# This script installs extensions directly into the code-server extensions directory

EXTENSIONS=(
    # Python development
    "ms-python.python"
    "ms-python.debugpy"
    "ms-python.vscode-python-envs"
    "ms-pyright.pyright"

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

    # Additional Python tools
    "magicstack.magicpython"
)

echo "Installing VSCode extensions for code-server..."

for extension in "${EXTENSIONS[@]}"; do
    echo "Installing: $extension"
    code-server --install-extension "$extension" || echo "Failed to install $extension, continuing..."
done

echo "Extension installation complete!"
