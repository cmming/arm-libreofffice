#!/bin/bash
# 本地完整文档转换测试脚本

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

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

IMAGE_TAG="arm64-test:local"

print_header "=== 文档转换功能测试（完整版）==="
echo "使用镜像: $IMAGE_TAG"

# 检查镜像是否存在
if ! docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "$IMAGE_TAG"; then
    print_error "镜像 $IMAGE_TAG 不存在"
    echo "请先运行以下命令构建镜像:"
    echo "docker buildx build --platform linux/arm64 --load -t arm64-test:local ."
    exit 1
fi

# 设置 ARM64 模拟环境
echo "设置 ARM64 模拟环境..."
docker run --rm --privileged tonistiigi/binfmt --install arm64 > /dev/null 2>&1

# 创建测试文档
print_info "创建测试文档..."
cat > test-document.txt << 'EOF'
ARM64 CentOS LibreOffice 测试文档

这是一个用于测试文档转换功能的示例文件。

测试内容：
1. 中文字符支持测试：你好世界
2. 英文字符支持测试：Hello World  
3. 数字支持测试：1234567890
4. 特殊字符测试：@#$%^&*()

构建架构：ARM64 (aarch64)
操作系统：CentOS 7.9.2009
Java 版本：OpenJDK 1.8
LibreOffice 版本：5.3.6.1

测试时间：$(date)
EOF

print_success "测试文档创建完成"

# 创建测试输出目录
mkdir -p test-output

print_info "开始文档转换测试..."

# 测试多种格式转换
docker run --rm --platform linux/arm64 \
  -v $(pwd)/test-document.txt:/tmp/test-document.txt \
  -v $(pwd)/test-output:/output \
  "$IMAGE_TAG" \
  bash -c "
    echo '转换测试文件为多种格式:'
    
    echo '• 转换为 PDF...'
    libreoffice --headless --convert-to pdf --outdir /output /tmp/test-document.txt &
    
    echo '• 转换为 DOCX...'  
    libreoffice --headless --convert-to docx --outdir /output /tmp/test-document.txt &
    
    echo '• 转换为 ODT...'
    libreoffice --headless --convert-to odt --outdir /output /tmp/test-document.txt &
    
    echo '等待转换完成...'
    wait
    
    echo '转换完成，检查结果:'
    ls -la /output/
    
    echo '验证文件大小:'
    for file in /output/*; do
      if [ -f \"\$file\" ]; then
        size=\$(stat -c%s \"\$file\")
        echo \"✅ \$(basename \$file): \$size 字节\"
      else
        echo \"❌ 文件不存在: \$file\"
      fi
    done
  "

print_header "验证转换结果"

# 检查输出文件
files_created=0
expected_files=("test-document.pdf" "test-document.docx" "test-document.odt")

for file in "${expected_files[@]}"; do
    if [ -f "test-output/$file" ]; then
        size=$(stat -c%s "test-output/$file")
        print_success "$file 创建成功 ($size 字节)"
        files_created=$((files_created + 1))
    else
        print_error "$file 创建失败"
    fi
done

echo ""
if [ $files_created -eq 3 ]; then
    print_success "所有格式转换测试通过！"
    echo "转换的文件保存在 test-output/ 目录中"
elif [ $files_created -gt 0 ]; then
    print_info "部分格式转换成功 ($files_created/3)"
else
    print_error "所有格式转换失败"
fi

print_success "完整文档转换测试完成"

# 清理选项
echo ""
read -p "是否清理测试文件？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf test-output test-document.txt
    print_info "测试文件已清理"
else
    print_info "测试文件保留在当前目录"
fi

echo ""
echo "🎯 这个脚本模拟了 GitHub Actions 中的完整文档转换测试"
echo "如果本地测试通过，GitHub Actions 中的测试也应该能正常工作"