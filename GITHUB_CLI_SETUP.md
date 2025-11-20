# GitHub CLI (gh) Setup

This document describes the installation of GitHub CLI in this development environment.

## Installation Details

- **Tool**: GitHub CLI (gh)
- **Version**: 2.83.1
- **Installation Date**: 2025-11-20
- **Install Location**: `/usr/local/bin/gh`
- **Platform**: Linux (Ubuntu 24.04.3 LTS)

## Installation Method

The GitHub CLI was installed by downloading the official binary release from GitHub:

1. Downloaded the latest release (v2.83.1) from: https://github.com/cli/cli/releases
2. Extracted the tarball
3. Copied the binary to `/usr/local/bin/gh`
4. Made the binary executable

## Automated Installation

An installation script is provided: `install-gh-cli.sh`

To reinstall or update GitHub CLI, run:
```bash
bash install-gh-cli.sh
```

## Verification

To verify the installation:
```bash
which gh
# Output: /usr/local/bin/gh

gh --version
# Output: gh version 2.83.1 (...)
```

## Usage

For help with GitHub CLI commands:
```bash
gh --help
```

Common commands:
- `gh auth login` - Authenticate with GitHub
- `gh repo clone <repo>` - Clone a repository
- `gh issue list` - List issues in current repository
- `gh pr list` - List pull requests
- `gh pr create` - Create a pull request

## Documentation

Official documentation: https://cli.github.com/manual/
