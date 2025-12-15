# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker image project for an offline-capable development environment based on Code-Server. The image includes AI tools (Claude Code, CCR), Python/Node.js development environments, and pre-installed VS Code extensions.

## Build Commands

```bash
# Build Docker image locally (from project root)
cd build && DOCKER_BUILDKIT=1 docker build -t code-server-dev:latest --platform linux/amd64 .

# Run with docker-compose
docker-compose up -d

# Pull pre-built image
docker pull ghcr.io/so2liu/code-server-dev:latest
```

## CI/CD

Push to `main` branch or create a tag (`v*`) triggers GitHub Actions to build and push to `ghcr.io/so2liu/code-server-dev`.

## Architecture

### Dockerfile Layer Strategy

The `build/Dockerfile` uses a layered caching strategy. Layers are ordered from least to most frequently changed:

1. **Stage 1**: Base system packages (apt) - rarely changes
2. **Stage 2-3**: Node.js (nvm) and code-server
3. **Stage 4**: Global npm packages (claude-code, ccr, opencode-ai)
4. **Stage 5-6**: Python (uv) and pip packages
5. **Stage 7-11**: TikToken models, scripts, extensions, settings
6. **Stage 12+**: New packages should be added here to maximize cache reuse

**Important**: When adding new apt packages, add them as a new stage at the end of the Dockerfile rather than modifying Stage 1, to preserve build cache.

### Key Files

- `build/Dockerfile` - Main image definition
- `build/install-extensions.sh` - VS Code extension list
- `docker-compose.example.yaml` - Reference configuration
- `config/` - Runtime configuration files (mounted into container)

### Container Entry Points

- Port 8080: Code-Server Web IDE
- Port 3456: CCR (Claude Code Router) management UI
- Default password: `bladeai2025`

## Adding New Dependencies

### System packages (apt)
Add to a new RUN stage at the end of `build/Dockerfile`:
```dockerfile
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y <packages>
```

### Python packages
Add to Stage 6 in `build/Dockerfile` (the `uv pip install` block).

### VS Code extensions
Add extension ID to the `EXTENSIONS` array in `build/install-extensions.sh`.
