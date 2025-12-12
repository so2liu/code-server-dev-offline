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
    # gRPC 和 Protobuf 依赖
    libgrpc-dev libgrpc++-dev libprotobuf-dev protobuf-compiler protobuf-compiler-grpc \
    libssl-dev libcurl4-openssl-dev libcares-dev \
    # gRPC 额外依赖
    libabsl-dev \
    libre2-dev \
    libz-dev zlib1g-dev \
    # gRPC 调试和测试工具
    grpcurl \
    # HTTP/2 相关 (gRPC 基于 HTTP/2)
    libnghttp2-dev \
    # 序列化相关 (可能用到的其他格式)
    libflatbuffers-dev flatbuffers-compiler \
    libjsoncpp-dev nlohmann-json3-dev \
    # 多语言 gRPC 支持
    python3-grpcio python3-grpc-tools \
    # Python 环境
    python3 python3-pip python3-dev python3-venv \
    # 其他工具
    man-db pandoc dumb-init openssh-client \
    && \
    # 配置语言环境
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# ============================================
# 阶段2: 安装 nvm 和 Node.js
# ============================================
ENV NVM_DIR=/root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && \
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
RUN --mount=type=cache,target=/root/.npm,sharing=locked \
    npm install -g @anthropic-ai/claude-code @musistudio/claude-code-router opencode-ai

# ============================================
# 阶段5: 安装 uv
# ============================================
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv* /usr/local/bin/

# ============================================
# 阶段6: 安装 Python 依赖
# ============================================
RUN --mount=type=cache,target=/root/.cache/uv,sharing=locked \
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
RUN chmod +x /usr/local/bin/xdg-open /usr/local/bin/pip

# ============================================
# 阶段8.1: 创建入口点脚本和默认配置
# ============================================
RUN mkdir -p /root/.config/code-server && \
    cat > /usr/bin/entrypoint.sh << 'ENTRYPOINT_EOF'
#!/bin/bash
set -eu

echo "Starting Code-Server development environment..."

# Initialize nvm (for compatibility with blade-code-server users)
if [ -s "/root/.nvm/nvm.sh" ]; then
    echo "Loading nvm environment..."
    . /root/.nvm/nvm.sh
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
    --config /root/.config/code-server/config.yaml \
    --user-data-dir /root/.local/share/code-server \
    --extensions-dir /root/.local/share/code-server/extensions \
    /workspace
ENTRYPOINT_EOF

RUN cat > /root/.config/code-server/config.yaml << 'CONFIG_EOF'
bind-addr: 0.0.0.0:8080
auth: password
password: "bladeai2025"
cert: false
CONFIG_EOF

RUN chmod +x /usr/bin/entrypoint.sh

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
RUN mkdir -p /root/.local/share/code-server/User && \
    echo '{"vim.disableExtension": true}' > /root/.local/share/code-server/User/settings.json

# ============================================
# 最终配置
# ============================================
WORKDIR /workspace

# 暴露端口
EXPOSE 8080 3456

# 设置启动命令
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/bin/bash", "/usr/bin/entrypoint.sh"]
