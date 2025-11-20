# Docker 构建优化说明

本文档说明了对 Dockerfile 进行的优化，以提高构建速度和缓存利用率。

## 主要优化

### 1. TikToken 离线支持

**问题**: 镜像中安装了 `langchain-openai` 包（依赖 `tiktoken`），但 tiktoken 在首次使用时会从网络下载模型文件，导致在离线环境中无法使用。

**解决方案**:
- 添加了 `download-tiktoken-models.py` 脚本
- 在构建时预下载所有常用的 tiktoken 编码模型：
  - `cl100k_base` (GPT-4, GPT-3.5-turbo)
  - `p50k_base` (Codex)
  - `r50k_base` (GPT-3)
  - `o200k_base` (GPT-4o)
- 这些模型会被缓存在镜像中，确保离线环境可用

### 2. Docker BuildKit 缓存挂载

**优化**: 使用 BuildKit 的 `--mount=type=cache` 功能缓存包下载

**好处**:
- APT 包缓存: `/var/cache/apt` 和 `/var/lib/apt`
- NPM 包缓存: `/root/.npm`
- UV (Python) 包缓存: `/root/.cache/uv`
- 即使层缓存失效，包下载也会被缓存，大幅加快构建速度

**使用方法**:
```bash
# 需要使用 DOCKER_BUILDKIT=1 或在 daemon.json 中启用
DOCKER_BUILDKIT=1 docker build -t code-server-dev:latest .
```

### 3. 层次结构优化

**原理**: Docker 构建时，如果某一层的内容发生变化，该层及之后的所有层都会被重新构建。

**优化策略**: 将变化频率不同的操作分离到不同的层，按照变化频率从低到高排序：

1. **系统依赖** (很少变化)
   - 基础工具安装
   - 语言环境配置

2. **用户创建** (很少变化)
   - coder 用户和权限设置

3. **Node.js 安装** (很少变化)
   - Node.js 和 pnpm

4. **code-server 安装** (很少变化)
   - code-server 版本锁定

5. **全局 npm 包** (较少变化)
   - Claude Code 和 CCR

6. **UV 安装** (很少变化)
   - Python 包管理器

7. **Python 依赖** (中等频率变化)
   - 先 COPY pyproject.toml
   - 再安装依赖
   - 只有 pyproject.toml 变化时才重新安装

8. **TikToken 模型** (很少变化)
   - 下载离线模型

9. **辅助脚本** (较少变化)
   - xdg-open 等工具脚本

10. **VSCode 插件** (中等频率变化)
    - 先 COPY install-extensions.sh
    - 再安装插件
    - 只有脚本变化时才重新安装

### 4. 依赖文件分离

**关键优化**: 将依赖配置文件（pyproject.toml, install-extensions.sh）与安装步骤分离

**示例**:
```dockerfile
# 先复制依赖配置文件
COPY pyproject.toml /tmp/build/pyproject.toml

# 再安装依赖（只有 pyproject.toml 变化时才重新运行）
# 使用 uv export 从 pyproject.toml 生成 requirements 文件
RUN --mount=type=cache,target=/root/.cache/uv,sharing=locked \
    cd /tmp/build && \
    uv export --no-hashes --no-dev -o requirements.txt && \
    uv export --no-hashes --only-dev -o requirements-dev.txt && \
    uv pip install --system --break-system-packages \
    -r requirements.txt -r requirements-dev.txt && \
    rm -rf /tmp/build
```

**效果**:
- 添加新的 Python 包：只需修改 pyproject.toml，Docker 会重新安装 Python 依赖，但不会重新构建之前的层
- 添加新的 VSCode 插件：只需修改 install-extensions.sh，Docker 会重新安装插件，但不会重新安装 Python 依赖
- 修改代码或配置：完全不影响镜像构建

## 构建性能对比

### 首次构建
- 原版: ~15-20 分钟
- 优化版: ~15-20 分钟 (首次构建差不多)

### 添加一个 Python 包
- 原版: ~10-15 分钟 (重新安装所有 Python 包)
- 优化版: ~2-3 分钟 (只重新安装 Python 依赖，利用 uv 缓存)

### 添加一个 VSCode 插件
- 原版: ~5-10 分钟 (重新安装所有插件)
- 优化版: ~1-2 分钟 (只重新安装插件部分)

### 修改配置文件或代码
- 原版: 几秒钟 (如果只修改运行时配置)
- 优化版: 几秒钟 (完全利用缓存)

## 最佳实践

### 1. 启用 BuildKit

在 `/etc/docker/daemon.json` 中启用：
```json
{
  "features": {
    "buildkit": true
  }
}
```

或在构建时使用环境变量：
```bash
DOCKER_BUILDKIT=1 docker build -t code-server-dev:latest .
```

### 2. 使用 BuildKit 缓存后端

对于 CI/CD 环境，可以使用外部缓存：
```bash
docker buildx build \
  --cache-from type=registry,ref=myregistry/myimage:cache \
  --cache-to type=registry,ref=myregistry/myimage:cache,mode=max \
  -t myregistry/myimage:latest \
  .
```

### 3. 定期清理缓存

虽然缓存可以加速构建，但也会占用磁盘空间：
```bash
# 清理构建缓存
docker builder prune

# 清理所有未使用的缓存
docker system prune -a
```

### 4. 添加依赖的正确姿势

**添加 Python 包**:
1. 修改 `build/pyproject.toml`，添加新包
2. 重新构建镜像 - 只会重新运行 Python 依赖安装层及之后的层

**添加 VSCode 插件**:
1. 修改 `build/install-extensions.sh`，添加插件 ID
2. 重新构建镜像 - 只会重新运行插件安装层

## 技术细节

### BuildKit 缓存挂载

`--mount=type=cache` 创建一个持久的缓存目录，在多次构建之间共享：

```dockerfile
RUN --mount=type=cache,target=/root/.cache/uv,sharing=locked \
    uv pip install package
```

- `target`: 缓存目录路径
- `sharing=locked`: 允许多个构建并发访问缓存，但会加锁防止冲突

### 语法版本

Dockerfile 第一行指定了 BuildKit 语法版本：
```dockerfile
# syntax=docker/dockerfile:1.4
```

这确保了所有高级功能（如缓存挂载）都可用。

## 故障排除

### 缓存未生效

1. 确认 BuildKit 已启用
2. 检查是否修改了缓存层之前的内容
3. 尝试清理缓存后重新构建

### 构建失败

1. 检查网络连接（首次构建需要下载包）
2. 查看具体错误信息
3. 尝试禁用缓存构建：`docker build --no-cache`

### TikToken 仍然无法离线使用

1. 确认构建过程中 download-tiktoken-models.py 成功执行
2. 检查日志中是否有 "✓" 标记表示模型下载成功
3. 进入容器验证：
   ```bash
   docker run -it code-server-dev:latest python3 -c "import tiktoken; tiktoken.get_encoding('cl100k_base').encode('test')"
   ```

## 参考资料

- [Docker BuildKit 文档](https://docs.docker.com/build/buildkit/)
- [Dockerfile 最佳实践](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [BuildKit 缓存挂载](https://docs.docker.com/build/guide/mounts/)
