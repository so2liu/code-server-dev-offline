# syntax=docker/dockerfile:1.4
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
    htop tree jq zip unzip rsync lsof strace socat \
    # 网络工具
    net-tools iputils-ping dnsutils telnet traceroute netcat-openbsd \
    # C/C++ 编译工具链
    build-essential gcc g++ gdb cmake make automake autoconf libtool pkg-config \
    # Python 环境
    python3 python3-pip python3-dev python3-venv \
    # 其他工具
    man-db pandoc dumb-init \
    && \
    # 配置语言环境
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# ============================================
# 阶段2: 创建用户
# 这一层很少变化，可以充分利用缓存
# ============================================
RUN if id -u 1000 >/dev/null 2>&1; then \
        existing_user=$(id -un 1000); \
        userdel -r $existing_user 2>/dev/null || true; \
    fi && \
    useradd -m -s /bin/bash -u 1000 coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/coder && \
    chmod 0440 /etc/sudoers.d/coder

# ============================================
# 阶段3: 安装 Node.js
# 这一层很少变化，可以充分利用缓存
# ============================================
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - && \
    apt-get install -y nodejs

# 安装 pnpm (使用缓存)
RUN --mount=type=cache,target=/root/.npm,sharing=locked \
    npm install -g pnpm

# ============================================
# 阶段4: 安装 code-server
# 这一层很少变化，可以充分利用缓存
# ============================================
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --version=${CODE_SERVER_VERSION}

# ============================================
# 阶段5: 安装全局 npm 包
# 这一层较少变化，可以充分利用缓存
# ============================================
RUN --mount=type=cache,target=/root/.npm,sharing=locked \
    npm install -g @anthropic-ai/claude-code @musistudio/claude-code-router @cline/cli

# ============================================
# 阶段6: 安装 uv
# 这一层很少变化，可以充分利用缓存
# ============================================
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv* /usr/local/bin/

# ============================================
# 阶段7: 安装 Python 依赖
# 关键优化：先复制 pyproject.toml，只有它变化时才重新安装依赖
# 使用 BuildKit 缓存挂载加速下载
# ============================================

# 安装 Python 依赖
# 使用缓存挂载加速下载
# 注意：这里直接列出依赖，这样当依赖变化时只重新安装这一层
RUN --mount=type=cache,target=/root/.cache/uv,sharing=locked \
    uv pip install --system --break-system-packages \
    loguru==0.7.3 \
    matplotlib==3.10.1 \
    fastapi==0.115.11 \
    uvicorn==0.34.0 \
    langchain-openai==0.3.9 \
    langchain==0.3.9 \
    langgraph==0.3.16 \
    pydantic[email]==2.10.6 \
    pydantic-settings==2.8.1 \
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
    ipykernel>=6.29.5 \
    debugpy>=1.8.0 \
    pytest>=8.4.1 \
    pytest-asyncio>=1.0.0 \
    ruff>=0.11.6

# ============================================
# 阶段8: 下载 TikToken 模型（离线支持）
# 这一层只在需要时运行一次
# ============================================
COPY download-tiktoken-models.py /tmp/download-tiktoken-models.py
RUN python3 /tmp/download-tiktoken-models.py && \
    rm /tmp/download-tiktoken-models.py

# ============================================
# 阶段9: 复制辅助脚本
# 这一层在脚本变化时才重新构建
# ============================================
COPY xdg-open /usr/local/bin/
RUN chmod +x /usr/local/bin/xdg-open

# ============================================
# 阶段10: 切换到 coder 用户并安装 VSCode 插件
# 关键优化：先复制插件列表，只有它变化时才重新安装插件
# ============================================
USER coder
WORKDIR /home/coder

# 先复制插件安装脚本
COPY --chown=coder:coder install-extensions.sh /tmp/install-extensions.sh
RUN chmod +x /tmp/install-extensions.sh

# 安装插件（这一步只在 install-extensions.sh 变化时重新运行）
RUN /tmp/install-extensions.sh && \
    rm /tmp/install-extensions.sh

# ============================================
# 最终配置
# ============================================
WORKDIR /workspace

# 暴露端口
EXPOSE 8080 3456

# 设置启动命令
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/bin/bash", "/config/entrypoint.sh"]
