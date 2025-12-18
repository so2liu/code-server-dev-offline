# Code-Server 开发镜像

一个功能完整的离线开发环境镜像，基于 Code-Server，集成 AI 工具和多种开发环境。

## 特性

- **基础系统**: Ubuntu 24.04 LTS (AMD64)
- **开发环境**:
  - C/C++ 完整编译工具链 (build-essential, gcc, g++, cmake, make)
  - Python 3.12 + uv 包管理器
  - Node.js 22 (通过 nvm) + pnpm
  - 常用命令工具 (git, vim, tree, jq, rsync, lsof, strace, socat, pandoc 等)
- **Code-Server**: 4.106.2
  - 通过浏览器访问 (端口 8080)
  - 预装常用插件 (Python, GitLens, Ruff, SQLTools, YAML, vim, React, Cline)
- **AI 工具**:
  - Claude Code CLI
  - CCR (Claude Code Router) - 支持多 AI 提供商路由
  - 默认配置智谱 AI
- **Python 依赖**: LangChain, FastAPI, MCP, Claude SDK 等完整 AI 开发工具链
- **离线支持**:
  - 预下载 TikToken 模型，确保完全离线环境可用
  - 内置完整项目文档（`/opt/docs/code-server-dev-docs.tar.gz`），方便离线查阅
- **构建优化**: 使用 Docker BuildKit 缓存，大幅提升重复构建速度

## 快速开始

### 1. 克隆仓库

```bash
git clone <repository-url>
cd code-server-dev-offline
```

### 2. 配置 Docker Compose

```bash
# 复制示例配置
cp docker-compose.example.yaml docker-compose.yaml

# 编辑配置，设置您的 API 密钥
vim docker-compose.yaml
```

### 3. 启动容器

有两种方式：

**方式 A: 使用预构建镜像（推荐）**

```bash
# 拉取镜像
docker pull ghcr.io/so2liu/code-server-dev:latest

# 启动
docker-compose up -d
```

**方式 B: 本地构建**

```bash
# 构建镜像（推荐使用 BuildKit 以获得更好的缓存性能）
cd build
DOCKER_BUILDKIT=1 docker build -t code-server-dev:latest --platform linux/amd64 .

# 返回项目根目录并启动
cd ..
docker-compose up -d
```

> **提示**: 镜像已优化缓存策略，添加新的 Python 包或 VSCode 插件时只需重新构建相关层，大幅节省时间。详见 [Docker 优化说明](build/DOCKER_OPTIMIZATION.md)

### 4. 访问

- **Code-Server Web IDE**: http://localhost:8080
- **CCR 管理界面**: http://localhost:3456/ui
- **默认密码**: `bladeai2025` (可在 config/config.yaml 中修改)

## 配置说明

### 目录结构

```
code-server-dev-offline/
├── build/                      # Docker 镜像构建文件
│   ├── Dockerfile              # 主 Dockerfile
│   ├── pyproject.toml          # Python 依赖配置
│   └── install-extensions.sh   # VSCode 插件安装脚本
├── config/                     # 运行时配置文件
│   ├── entrypoint.sh           # 容器启动脚本
│   ├── config.yaml             # Code-Server 配置
│   ├── workspace.code-workspace # VSCode 工作区配置
│   ├── .claude-code-router/    # CCR 配置
│   ├── .vscode/                # VSCode 设置（调试等）
│   └── .claude/                # Claude Code 配置
├── data/                       # 工作目录（会被挂载到容器）
├── docker-compose.yaml         # Docker Compose 配置
└── README.md
```

### 环境变量

在 `docker-compose.yaml` 中配置：

- `ANTHROPIC_BASE_URL`: CCR 服务地址（默认 http://localhost:3456）
- `ANTHROPIC_AUTH_TOKEN`: API 密钥（需要自行配置）

### 自定义 AI 提供商

编辑 `config/.claude-code-router/config.json` 可以配置不同的 AI 提供商。

默认配置为智谱 AI (GLM-4.5)，支持 65K token 上下文。

## 预装插件列表

- **Python 开发**:
  - Python (ms-python.python)
  - Debugpy (ms-python.debugpy)
  - Pyright (ms-pyright.pyright)
  - Ruff (charliermarsh.ruff)

- **AI 辅助编码**:
  - Cline (saoudrizwan.claude-dev)

- **版本控制**:
  - GitLens (eamodio.gitlens)

- **数据库**:
  - SQLTools (mtxr.sqltools)
  - SQLTools PostgreSQL Driver (mtxr.sqltools-driver-pg)
  - SQLite Viewer (qwtel.sqlite-viewer)

- **React 开发**:
  - ES7+ React/Redux Snippets (dsznajder.es7-react-js-snippets)
  - Prettier (esbenp.prettier-vscode)

- **YAML**:
  - YAML (redhat.vscode-yaml)

- **其他**:
  - Vim (vscodevim.vim)
  - Error Lens (usernamehw.errorlens)

## Python 开发

### 虚拟环境

容器内已配置 Python 虚拟环境在 `/home/coder/.venv`。

使用 uv 管理依赖：

```bash
# 添加新依赖
uv add package-name

# 安装依赖
uv sync
```

### 调试

VSCode 已预配置 4 种调试场景：

1. **Python: 当前文件** - 调试正在编辑的文件
2. **Python: FastAPI** - 调试 FastAPI 应用（支持热重载）
3. **Python: FastAPI (自定义)** - 可配置模块和端口
4. **Python: 附加到进程** - 连接到运行中的 Python 进程

## 包管理器

- **Python**: uv
- **JavaScript/TypeScript**: pnpm

## CI/CD

项目包含 GitHub Actions 工作流，自动构建和推送镜像到 GitHub Container Registry。

创建 tag 时会自动触发构建：

```bash
git tag v1.0.0
git push origin v1.0.0
```

## 离线环境使用

### 访问内置文档

镜像中已内置完整的项目文档，位于 `/opt/docs/code-server-dev-docs.tar.gz`。

在容器内解压查看：

```bash
# 进入容器
docker exec -it code-server-dev bash

# 解压文档到临时目录
mkdir -p ~/docs
cd ~/docs
tar xzf /opt/docs/code-server-dev-docs.tar.gz

# 查看文档
cat README.md
```

文档包含：
- README.md - 完整使用说明
- build/ - Dockerfile 和构建脚本
- config/ - 配置文件示例
- docker-compose.example.yaml - Docker Compose 配置示例

## 常见问题

### 如何修改登录密码？

编辑 `config/config.yaml`，修改 `password` 字段。

### 如何添加新的 VSCode 插件？

1. 编辑 `build/install-extensions.sh`，添加插件 ID
2. 重新构建镜像（由于使用了缓存优化，只会重新安装插件部分，非常快）

```bash
cd build
DOCKER_BUILDKIT=1 docker build -t code-server-dev:latest .
```

### 如何更新 Python 依赖？

1. 编辑 `build/pyproject.toml`，添加或更新包
2. 重新构建镜像（缓存优化使得只重新安装 Python 依赖）

```bash
cd build
DOCKER_BUILDKIT=1 docker build -t code-server-dev:latest .
```

### 容器内如何访问宿主机服务？

使用 `host.docker.internal` 作为主机地址（仅 Docker Desktop）。

Linux 系统需要在 docker-compose.yaml 中添加：

```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

### TikToken 在离线环境中无法使用？

本镜像已预下载所有常用的 TikToken 模型文件，包括：
- cl100k_base (GPT-4, GPT-3.5-turbo)
- p50k_base (Codex)
- r50k_base (GPT-3)
- o200k_base (GPT-4o)

如果遇到问题，请检查构建日志确认模型下载成功。

### CCR 提示 "Read-only file system" 错误？

如果在容器内运行 `ccr ui` 时遇到以下错误：

```
Failed to create default configuration: ENOENT: no such file or directory, mkdir '/home/coder/.claude-code-router/plugins'
mkdir: cannot create directory '/home/coder/.claude-code-router/plugins': Read-only file system
```

这是因为 `.claude-code-router` 目录被挂载为只读。解决方法：

1. 确保 `config/.claude-code-router/plugins` 目录存在：
   ```bash
   mkdir -p config/.claude-code-router/plugins
   ```

2. 在 `docker-compose.yaml` 中移除 `:ro` 标志（已在示例配置中修复）：
   ```yaml
   - ./config/.claude-code-router:/home/coder/.claude-code-router
   ```

3. 重启容器：
   ```bash
   docker-compose restart
   ```

## 性能优化

本项目使用了 Docker BuildKit 和分层缓存策略，大幅提升构建性能：

- **首次构建**: ~15-20 分钟
- **添加 Python 包**: ~2-3 分钟（vs 原来的 10-15 分钟）
- **添加 VSCode 插件**: ~1-2 分钟（vs 原来的 5-10 分钟）

详细的优化说明和最佳实践请参见 [Docker 优化文档](build/DOCKER_OPTIMIZATION.md)。

## License

MIT

## 维护者

[@so2liu](https://github.com/so2liu)
