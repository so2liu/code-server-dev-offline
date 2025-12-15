FROM ubuntu:24.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    CODE_SERVER_VERSION=4.106.2 \
    NODE_MAJOR=22

# ============================================
# 阶段1: 安装系统依赖和基础工具
# 这一层很少变化，可以充分利用缓存
# ============================================
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
    # 基础工具
    curl wget git vim nano sudo ca-certificates gnupg lsb-release locales \
    # 命令行工具
    htop tree jq yq zip unzip bzip2 xz-utils rsync lsof strace socat \
    # 网络工具
    net-tools iputils-ping dnsutils telnet traceroute netcat-openbsd \
    # C/C++ 编译工具链
    build-essential gcc g++ gdb cmake make automake autoconf libtool pkg-config \
    # Python 环境
    python3 python3-pip python3-dev python3-venv \
    # 其他工具
    man-db pandoc dumb-init openssh-client \
    && \
    # 配置语言环境
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# ============================================
# Stage 1.1: Create non-root user and install fixuid + gosu
# ============================================
# Remove existing user/group with UID/GID 1000 if any, then create coder user
RUN (getent passwd 1000 | cut -d: -f1 | xargs -r userdel -r 2>/dev/null || true) && \
    (getent group 1000 | cut -d: -f1 | xargs -r groupdel 2>/dev/null || true) && \
    groupadd -g 1000 coder && \
    useradd -m -u 1000 -g 1000 -s /bin/bash coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

# Install fixuid for UID/GID remapping and gosu for user switching
RUN ARCH="$(dpkg --print-architecture)" && \
    curl -fsSL "https://github.com/boxboat/fixuid/releases/download/v0.6.0/fixuid-0.6.0-linux-${ARCH}.tar.gz" | \
    tar -C /usr/local/bin -xzf - && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: coder\ngroup: coder\npaths:\n  - /home/coder\n  - /workspace\n" > /etc/fixuid/config.yml && \
    curl -fsSL "https://github.com/tianon/gosu/releases/download/1.17/gosu-${ARCH}" -o /usr/local/bin/gosu && \
    chmod +x /usr/local/bin/gosu

# Update fixuid config to only include /workspace (not /home/coder)
# This prevents fixuid from changing ownership of home directory files
RUN mkdir -p /workspace && \
    chown coder:coder /workspace && \
    printf "user: coder\ngroup: coder\npaths:\n  - /workspace\n" > /etc/fixuid/config.yml

# ============================================
# 阶段2: 安装 nvm 和 Node.js
# ============================================
ENV NVM_DIR=/home/coder/.nvm
RUN mkdir -p "$NVM_DIR" && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install ${NODE_MAJOR} && \
    nvm alias default ${NODE_MAJOR} && \
    nvm use default && \
    # Create a symlink to make node available without sourcing nvm
    ln -s "$(which node)" /usr/local/bin/node && \
    ln -s "$(which npm)" /usr/local/bin/npm && \
    ln -s "$(which npx)" /usr/local/bin/npx

# 安装 pnpm
RUN . "$NVM_DIR/nvm.sh" && npm install -g pnpm && \
    ln -s "$(which pnpm)" /usr/local/bin/pnpm

# ============================================
# 阶段3: 安装 code-server
# ============================================
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --version=${CODE_SERVER_VERSION}

# ============================================
# 阶段4: 安装全局 npm 包
# ============================================
RUN --mount=type=cache,target=/home/coder/.npm,sharing=locked \
    npm install -g @anthropic-ai/claude-code @musistudio/claude-code-router opencode-ai

# ============================================
# 阶段5: 安装 uv
# ============================================
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv* /usr/local/bin/ && \
    rm -rf /root/.local

# ============================================
# 阶段6: 安装 Python 依赖
# ============================================
RUN --mount=type=cache,target=/home/coder/.cache/uv,sharing=locked \
    uv pip install --system --break-system-packages \
    loguru==0.7.3 \
    matplotlib==3.10.1 \
    pyproj==3.7.1 \
    fastapi==0.115.11 \
    uvicorn==0.34.0 \
    jsonschema==4.23.0 \
    langchain-openai==0.3.9 \
    langchain==0.3.9 \
    langgraph==0.3.16 \
    prompt-toolkit==3.0.50 \
    pydantic[email]==2.10.6 \
    pydantic-settings==2.8.1 \
    pyyaml==6.0.2 \
    rich==13.9.4 \
    sqlmodel>=0.0.24 \
    psycopg2-binary>=2.9.10 \
    asyncpg>=0.30.0 \
    mcp[cli]>=1.9.1 \
    langchain-mcp-adapters>=0.1.7 \
    claude-code-sdk>=0.0.17 \
    httpx[socks]>=0.28.1 \
    minio>=7.2.15 \
    langfuse>=3.1.3 \
    fastmcp>=2.9.2 \
    itsdangerous>=2.2.0 \
    passlib>=1.7.4 \
    chardet>=5.2.0 \
    langgraph-checkpoint-sqlite>=2.0.10 \
    aiofiles>=24.1.0 \
    grandalf>=0.8 \
    python-jose>=3.5.0 \
    openapi-pydantic>=0.5.1 \
    pyjwt>=2.10.1 \
    json-repair>=0.47.6 \
    httpx-sse>=0.4.0 \
    psutil>=6.1.0 \
    sentry-sdk>=2.34.1 \
    python-socketio[asyncio]==5.11.4 \
    jinja2>=3.1.6 \
    cachetools>=6.2.0 \
    openapi-python-client>=0.21.6 \
    pandoc>=2.4 \
    pypandoc>=1.13 \
    python-docx>=1.1.2 \
    ipykernel>=6.29.5 \
    debugpy>=1.8.0 \
    pytest>=8.4.1 \
    pytest-asyncio>=1.0.0 \
    ruff>=0.11.6 \
    requests>=2.32.0

# ============================================
# 阶段7: 下载 TikToken 模型（离线支持）
# ============================================
COPY download-tiktoken-models.py /tmp/download-tiktoken-models.py
RUN python3 /tmp/download-tiktoken-models.py && \
    rm /tmp/download-tiktoken-models.py

# ============================================
# 阶段8: 复制辅助脚本
# ============================================
COPY xdg-open pip /usr/local/bin/
RUN chmod 755 /usr/local/bin/xdg-open /usr/local/bin/pip

# ============================================
# 阶段8.1: 创建默认配置
# ============================================
RUN mkdir -p /home/coder/.config/code-server && \
    cat > /home/coder/.config/code-server/config.yaml << 'CONFIG_EOF'
bind-addr: 0.0.0.0:8080
auth: password
password: "bladeai2025"
cert: false
CONFIG_EOF

# ============================================
# 阶段9: 打包项目文档（离线环境支持）
# ============================================
COPY . /tmp/code-server-docs/
RUN cd /tmp/code-server-docs && \
    rm -rf .git .gitignore .github && \
    mkdir -p /opt/docs && \
    tar czf /opt/docs/code-server-dev-docs.tar.gz . && \
    rm -rf /tmp/code-server-docs && \
    chmod 644 /opt/docs/code-server-dev-docs.tar.gz

# ============================================
# 阶段10: 安装 VSCode 插件
# ============================================
COPY install-extensions.sh /tmp/install-extensions.sh
RUN chmod +x /tmp/install-extensions.sh && \
    /tmp/install-extensions.sh && \
    rm /tmp/install-extensions.sh

# ============================================
# 阶段11: 配置 code-server user settings
# ============================================
RUN mkdir -p /home/coder/.local/share/code-server/User && \
    echo '{"vim.disableExtension": true}' > /home/coder/.local/share/code-server/User/settings.json

# ============================================
# 阶段12: 安装 gRPC 和 Protobuf 开发依赖
# ============================================
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
    # gRPC 和 Protobuf 核心
    libgrpc-dev libgrpc++-dev libprotobuf-dev protobuf-compiler protobuf-compiler-grpc \
    # gRPC 依赖库
    libssl-dev libcurl4-openssl-dev libc-ares-dev libabsl-dev libre2-dev \
    libz-dev zlib1g-dev libnghttp2-dev \
    # 序列化相关
    libflatbuffers-dev flatbuffers-compiler libjsoncpp-dev nlohmann-json3-dev \
    # Python gRPC
    python3-grpcio python3-grpc-tools

# ============================================
# 阶段12.1: 安装 grpcurl (不在 apt 仓库中)
# ============================================
RUN GRPCURL_VERSION=1.9.1 && \
    curl -sSL "https://github.com/fullstorydev/grpcurl/releases/download/v${GRPCURL_VERSION}/grpcurl_${GRPCURL_VERSION}_linux_x86_64.tar.gz" | tar -xz -C /usr/local/bin grpcurl

# ============================================
# 阶段13: 安装 grpcio (pip 最新版本)
# ============================================
RUN --mount=type=cache,target=/home/coder/.cache/uv,sharing=locked \
    uv pip install --system --break-system-packages \
    grpcio

# ============================================
# 最终配置
# ============================================
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh && \
    chown -R coder:coder /home/coder

WORKDIR /workspace

# NOTE: Do NOT set USER here - fixuid needs root to run first, then drops privileges

# 暴露端口
EXPOSE 8080 3456

# 设置启动命令
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/bin/entrypoint.sh"]
