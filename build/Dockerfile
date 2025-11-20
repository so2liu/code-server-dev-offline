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
    npm install -g @anthropic-ai/claude-code @musistudio/claude-code-router

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

# 复制 Python 依赖配置文件
COPY pyproject.toml /tmp/build/pyproject.toml

# 从 pyproject.toml 生成 requirements 并安装
# 使用缓存挂载加速下载
RUN --mount=type=cache,target=/root/.cache/uv,sharing=locked \
    cd /tmp/build && \
    # 创建临时 README 以满足 hatchling 的要求
    echo "# code-server-dev" > README.md && \
    # 导出主依赖到 requirements.txt
    uv export --no-hashes --no-dev -o requirements.txt && \
    # 导出开发依赖到 requirements-dev.txt
    uv export --no-hashes --only-dev -o requirements-dev.txt && \
    # 安装所有依赖
    uv pip install --system --break-system-packages \
    -r requirements.txt \
    -r requirements-dev.txt && \
    # 清理
    rm -rf /tmp/build

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
