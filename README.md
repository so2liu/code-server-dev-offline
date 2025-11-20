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
  - 预装常用插件 (Python, GitLens, Ruff, SQLTools, vim, React, Cline)
- **AI 工具**:
  - Claude Code CLI
  - CCR (Claude Code Router) - 支持多 AI 提供商路由
  - 默认配置智谱 AI
- **Python 依赖**: LangChain, FastAPI, MCP, Claude SDK 等完整 AI 开发工具链

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
# 构建镜像
cd build
docker build -t code-server-dev:latest --platform linux/amd64 .

# 返回项目根目录并启动
cd ..
docker-compose up -d
```

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

## 常见问题

### 如何修改登录密码？

编辑 `config/config.yaml`，修改 `password` 字段。

### 如何添加新的 VSCode 插件？

1. 编辑 `build/install-extensions.sh`，添加插件 ID
2. 重新构建镜像

### 如何更新 Python 依赖？

编辑 `build/pyproject.toml`，然后重新构建镜像。

### 容器内如何访问宿主机服务？

使用 `host.docker.internal` 作为主机地址（仅 Docker Desktop）。

Linux 系统需要在 docker-compose.yaml 中添加：

```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

## License

MIT

## 维护者

[@so2liu](https://github.com/so2liu)
