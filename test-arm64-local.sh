#!/bin/bash

# 使用 tonistiigi/binfmt 本地测试 ARM64 镜像脚本
# 使用方法：./test-arm64-local.sh [image-name]

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认镜像名称
DEFAULT_IMAGE="cmming/arm-centos79-java8-libreoffice:latest"
IMAGE_NAME="${1:-$DEFAULT_IMAGE}"

echo -e "${BLUE}=== ARM64 镜像本地测试脚本 ===${NC}"
echo -e "${YELLOW}镜像名称: $IMAGE_NAME${NC}"
echo ""

# 检查 Docker 是否运行
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}错误: Docker 未运行或无法访问${NC}"
    exit 1
fi

# 设置 ARM64 模拟
echo -e "${BLUE}步骤 1: 设置 ARM64 模拟环境${NC}"
echo "安装 tonistiigi/binfmt ARM64 支持..."
docker run --rm --privileged tonistiigi/binfmt --install arm64

echo "验证 binfmt 设置:"
docker run --rm --privileged tonistiigi/binfmt

echo -e "${GREEN}✅ ARM64 模拟环境设置完成${NC}"
echo ""

# 拉取镜像
echo -e "${BLUE}步骤 2: 拉取 ARM64 镜像${NC}"
docker pull --platform linux/arm64 "$IMAGE_NAME"
echo -e "${GREEN}✅ 镜像拉取完成${NC}"
echo ""

# 基础功能测试
echo -e "${BLUE}步骤 3: 基础功能测试${NC}"

echo "测试 Java 版本:"
docker run --rm --platform linux/arm64 "$IMAGE_NAME" java -version
echo ""

echo "测试 LibreOffice 版本:"
docker run --rm --platform linux/arm64 "$IMAGE_NAME" libreoffice --version
echo ""

echo "验证系统架构:"
ARCH=$(docker run --rm --platform linux/arm64 "$IMAGE_NAME" uname -m)
echo "系统架构: $ARCH"
if [ "$ARCH" = "aarch64" ]; then
    echo -e "${GREEN}✅ ARM64 架构验证成功${NC}"
else
    echo -e "${RED}❌ 架构验证失败，期望 aarch64，实际 $ARCH${NC}"
    exit 1
fi
echo ""

# 中文环境测试
echo -e "${BLUE}步骤 4: 中文环境测试${NC}"
docker run --rm --platform linux/arm64 "$IMAGE_NAME" bash -c "
    echo '语言环境:'
    locale | grep LANG
    echo ''
    echo '中文字符测试: 你好世界 Hello World'
    echo ''
    echo '中文字体数量:'
    fc-list | grep -i 'zh\|cjk\|han\|noto\|wqy' | wc -l
"
echo -e "${GREEN}✅ 中文环境测试完成${NC}"
echo ""

# 文档转换测试
echo -e "${BLUE}步骤 5: 文档转换功能测试${NC}"

# 检查测试文档是否存在
if [ ! -f "test-document.txt" ]; then
    echo "创建测试文档..."
    cat > test-document.txt << 'EOF'
LibreOffice 中文测试文档

这是一个用于测试 LibreOffice 命令行转换功能的中文文档。

功能测试内容：
1. 中文字符显示和处理
2. 文档格式转换功能  
3. ARM 架构下的运行稳定性

测试文字：
- 简体中文：你好，世界！这是一个测试文档。
- 繁体中文：您好，世界！這是一個測試文檔。
- 混合内容：Hello World! 123456789 ©®™

如果您看到这些内容，说明 LibreOffice 在 ARM 环境下
能够正常处理中文内容和进行文档转换。

测试时间：$(date)
EOF
fi

# 创建输出目录
mkdir -p test-output

echo "执行文档转换测试..."
docker run --rm --platform linux/arm64 \
    -v $(pwd)/test-document.txt:/tmp/test-document.txt \
    -v $(pwd)/test-output:/output \
    "$IMAGE_NAME" \
    bash -c "
        echo '=== 文档转换测试开始 ==='
        echo '原始文件内容预览:'
        head -5 /tmp/test-document.txt
        echo ''
        
        # 转换为 PDF
        echo '转换为 PDF...'
        libreoffice --headless --convert-to pdf --outdir /output /tmp/test-document.txt
        
        # 转换为 DOCX
        echo '转换为 DOCX...'
        libreoffice --headless --convert-to docx --outdir /output /tmp/test-document.txt
        
        # 转换为 ODT
        echo '转换为 ODT...'
        libreoffice --headless --convert-to odt --outdir /output /tmp/test-document.txt
        
        echo '=== 容器内转换结果 ==='
        ls -la /output/
    "

# 检查转换结果
echo ""
echo "=== 本地转换结果检查 ==="
if [ -d "test-output" ] && [ "$(ls -A test-output)" ]; then
    echo -e "${GREEN}转换成功！生成的文件:${NC}"
    ls -la test-output/
    
    for file in test-output/*; do
        if [ -f "$file" ]; then
            size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file")
            echo "  $(basename "$file"): ${size} bytes"
        fi
    done
else
    echo -e "${RED}❌ 转换失败，未生成输出文件${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 所有测试完成！${NC}"
echo -e "${BLUE}测试总结:${NC}"
echo "  ✅ ARM64 架构验证"
echo "  ✅ Java 8 运行正常"
echo "  ✅ LibreOffice 功能正常"
echo "  ✅ 中文环境支持"
echo "  ✅ 文档转换功能"
echo ""
echo -e "${YELLOW}注意: 由于使用 QEMU 模拟，性能可能比原生 ARM64 设备慢${NC}"

# 清理选项
echo ""
read -p "是否清理测试文件? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf test-output test-document.txt
    echo -e "${GREEN}清理完成${NC}"
fi