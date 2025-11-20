#!/bin/bash
# GitHub CLI Installation Script
# This script installs the GitHub CLI (gh) on Linux systems

set -e

echo "Installing GitHub CLI (gh)..."

# Get the latest version
LATEST_VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
echo "Latest version: $LATEST_VERSION"

# Remove 'v' prefix from version
VERSION=${LATEST_VERSION#v}

# Download the tarball
cd /tmp
echo "Downloading GitHub CLI $VERSION..."
curl -Lo gh.tar.gz "https://github.com/cli/cli/releases/download/$LATEST_VERSION/gh_${VERSION}_linux_amd64.tar.gz"

# Extract the archive
echo "Extracting archive..."
tar -xzf gh.tar.gz

# Install the binary
echo "Installing to /usr/local/bin..."
cp "gh_${VERSION}_linux_amd64/bin/gh" /usr/local/bin/
chmod +x /usr/local/bin/gh

# Clean up
rm -rf gh.tar.gz "gh_${VERSION}_linux_amd64"

echo "GitHub CLI installed successfully!"
echo "Installed location: $(which gh)"
echo "You can verify the installation by running: gh --version"
