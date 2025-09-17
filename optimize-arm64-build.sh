#!/bin/bash
# ARM64 构建性能优化和测试脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}🚀 $1${NC}"
    echo "$(printf '%.0s=' {1..50})"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

print_header "ARM64 构建优化测试"

# 1. 检查 Docker 和 QEMU 配置
print_header "检查构建环境"

if command -v docker &> /dev/null; then
    print_success "Docker 已安装: $(docker --version)"
else
    echo "❌ Docker 未找到"
    exit 1
fi

# 检查 buildx 支持
if docker buildx version &> /dev/null; then
    print_success "Docker Buildx 可用: $(docker buildx version)"
else
    echo "❌ Docker Buildx 不可用"
    exit 1
fi

# 2. 设置优化的 ARM64 模拟环境
print_header "设置 ARM64 模拟环境"

print_info "安装/更新 binfmt..."
docker run --rm --privileged tonistiigi/binfmt --install arm64

print_info "验证 ARM64 支持..."
docker run --rm --platform linux/arm64 arm64v8/alpine:latest uname -m

print_success "ARM64 模拟环境就绪"

# 3. 创建优化的 buildx 构建器
print_header "创建优化的构建器"

BUILDER_NAME="arm64-optimized"

# 删除现有构建器（如果存在）
docker buildx rm $BUILDER_NAME 2>/dev/null || true

# 创建新的优化构建器
docker buildx create \
    --name $BUILDER_NAME \
    --driver docker-container \
    --driver-opt network=host \
    --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=50000000 \
    --buildkitd-flags '--allow-insecure-entitlement network.host --allow-insecure-entitlement security.insecure' \
    --use

print_success "构建器 '$BUILDER_NAME' 创建完成"

# 4. 预热构建缓存
print_header "预热构建缓存"

print_info "拉取基础镜像..."
docker pull arm64v8/centos:7.9.2009

print_info "预热 buildx 构建器..."
docker buildx inspect --bootstrap

# 5. 执行优化构建测试
print_header "执行优化构建测试"

START_TIME=$(date +%s)

print_info "开始 ARM64 构建..."
docker buildx build \
    --platform linux/arm64 \
    --cache-from type=local,src=/tmp/.buildx-cache \
    --cache-to type=local,dest=/tmp/.buildx-cache,mode=max \
    --allow network.host \
    --allow security.insecure \
    -t arm64-test:latest \
    . || {
    echo "❌ 构建失败"
    exit 1
}

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

print_success "构建完成！耗时: ${DURATION} 秒"

# 6. 功能测试
print_header "功能验证测试"

print_info "测试基础功能..."
docker run --rm --platform linux/arm64 arm64-test:latest bash -c "
    echo '架构验证:' && uname -m && \
    echo 'Java 版本:' && java -version 2>&1 | head -1 && \
    echo 'LibreOffice 版本:' && libreoffice --version 2>&1 | head -1 && \
    echo '语言环境:' && echo \$LANG
"

print_success "功能验证通过"

# 7. 性能分析
print_header "构建性能分析"

echo "构建统计:"
echo "• 总耗时: ${DURATION} 秒"
echo "• 平均层构建时间: $((DURATION / 4)) 秒"

if [ $DURATION -lt 300 ]; then
    print_success "构建性能优秀 (< 5分钟)"
elif [ $DURATION -lt 600 ]; then
    print_info "构建性能良好 (< 10分钟)"
else
    echo "⚠️  构建性能需要进一步优化 (> 10分钟)"
fi

# 8. 清理
print_header "清理资源"

print_info "清理测试镜像..."
docker rmi arm64-test:latest 2>/dev/null || true

print_info "保留构建器和缓存以供下次使用"

print_success "ARM64 构建优化测试完成！"

echo ""
echo "💡 优化建议:"
echo "• 缓存已创建在 /tmp/.buildx-cache"
echo "• 构建器 '$BUILDER_NAME' 已配置并可重复使用"
echo "• 在 GitHub Actions 中使用相同的优化配置"
echo ""
echo "🚀 GitHub Actions 构建命令:"
echo "gh workflow run build-arm-centos.yml --ref main"