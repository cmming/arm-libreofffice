#!/bin/bash
# 本地快速功能验证测试脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header "=== 快速功能验证 ==="

# 使用我们之前构建的本地镜像
IMAGE_TAG="arm64-test:local"

echo "测试镜像: $IMAGE_TAG"

# 检查镜像是否存在
if ! docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "$IMAGE_TAG"; then
    print_error "镜像 $IMAGE_TAG 不存在"
    echo "请先运行以下命令构建镜像:"
    echo "docker buildx build --platform linux/arm64 --load -t arm64-test:local ."
    exit 1
fi

print_success "找到测试镜像: $IMAGE_TAG"

# 设置 ARM64 模拟环境
echo "设置 ARM64 模拟环境..."
docker run --rm --privileged tonistiigi/binfmt --install arm64 > /dev/null 2>&1

print_header "运行并行基础测试..."

# 创建临时文件存储测试结果
JAVA_RESULT=$(mktemp)
LIBREOFFICE_RESULT=$(mktemp)
ARCH_RESULT=$(mktemp)

# 并行运行基础测试
(
    echo "Java 测试:" > "$JAVA_RESULT"
    docker run --rm --platform linux/arm64 "$IMAGE_TAG" java -version 2>&1 | head -3 >> "$JAVA_RESULT"
) &
JAVA_PID=$!

(
    echo "LibreOffice 测试:" > "$LIBREOFFICE_RESULT"
    docker run --rm --platform linux/arm64 "$IMAGE_TAG" libreoffice --version 2>&1 | head -1 >> "$LIBREOFFICE_RESULT"
) &
LIBREOFFICE_PID=$!

(
    echo "架构验证:" > "$ARCH_RESULT"
    docker run --rm --platform linux/arm64 "$IMAGE_TAG" uname -m 2>&1 >> "$ARCH_RESULT"
) &
ARCH_PID=$!

# 等待所有后台任务完成
echo "等待测试完成..."
wait $JAVA_PID $LIBREOFFICE_PID $ARCH_PID

# 显示结果
echo ""
echo "=== 测试结果 ==="
echo ""

print_header "Java 测试结果:"
cat "$JAVA_RESULT"

echo ""
print_header "LibreOffice 测试结果:"
cat "$LIBREOFFICE_RESULT"

echo ""
print_header "架构验证结果:"
cat "$ARCH_RESULT"

# 验证结果
echo ""
print_header "结果验证:"

# 检查 Java 版本
if grep -q "openjdk version" "$JAVA_RESULT"; then
    print_success "Java 8 OpenJDK 正常运行"
else
    print_error "Java 测试失败"
fi

# 检查 LibreOffice 版本
if grep -q "LibreOffice" "$LIBREOFFICE_RESULT"; then
    print_success "LibreOffice 正常运行"
else
    print_error "LibreOffice 测试失败"
fi

# 检查架构
if grep -q "aarch64" "$ARCH_RESULT"; then
    print_success "ARM64 架构验证成功"
else
    print_error "架构验证失败"
fi

# 清理临时文件
rm -f "$JAVA_RESULT" "$LIBREOFFICE_RESULT" "$ARCH_RESULT"

print_success "基础功能验证完成"

echo ""
echo "🎯 这个脚本模拟了 GitHub Actions 中的快速功能测试"
echo "如果本地测试通过，GitHub Actions 中的测试也应该能正常工作"