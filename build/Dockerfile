FROM ubuntu:24.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    CODE_SERVER_VERSION=4.106.2 \
    NODE_MAJOR=22

# 安装基础工具和开发环境
RUN apt-get update && apt-get install -y \
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
    update-locale LANG=en_US.UTF-8 && \
    # 清理
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 创建 coder 用户（先删除可能存在的 UID 1000 用户）
RUN if id -u 1000 >/dev/null 2>&1; then \
        existing_user=$(id -un 1000); \
        userdel -r $existing_user 2>/dev/null || true; \
    fi && \
    useradd -m -s /bin/bash -u 1000 coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/coder && \
    chmod 0440 /etc/sudoers.d/coder

# 安装 Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g pnpm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 安装 code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --version=${CODE_SERVER_VERSION}

# 安装 Claude Code 和 CCR（全局，所有用户可用）
RUN npm install -g @anthropic-ai/claude-code @musistudio/claude-code-router

# 安装 uv (Python 包管理器) - 作为 root 用户
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv* /usr/local/bin/

# 全局安装 Python 依赖 - 作为 root 用户
RUN uv pip install --system --break-system-packages \
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

# 复制辅助脚本
COPY xdg-open /usr/local/bin/
RUN chmod +x /usr/local/bin/xdg-open

# 切换到 coder 用户
USER coder
WORKDIR /home/coder

# 安装 VSCode 插件
COPY --chown=coder:coder install-extensions.sh /tmp/install-extensions.sh
RUN chmod +x /tmp/install-extensions.sh && \
    /tmp/install-extensions.sh && \
    rm /tmp/install-extensions.sh

# 设置工作目录
WORKDIR /workspace

# 暴露端口
EXPOSE 8080 3456

# 设置启动命令
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/bin/bash", "/config/entrypoint.sh"]
