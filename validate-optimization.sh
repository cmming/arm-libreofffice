#!/bin/bash
# 验证构建优化效果的脚本

set -e

echo "🚀 验证 GitHub Actions 构建优化效果"
echo "========================================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 1. 检查 GitHub Actions 工作流结构
print_section "验证工作流结构优化"

if grep -q "jobs:" .github/workflows/build-arm-centos.yml; then
    job_count=$(grep -E "^  [a-z-]+:" .github/workflows/build-arm-centos.yml | wc -l)
    echo "工作流任务数量: $job_count"
    
    if [ $job_count -ge 3 ]; then
        print_success "工作流已拆分为多个并行任务"
        grep -E "^  [a-z-]+:" .github/workflows/build-arm-centos.yml | while read -r line; do
            job_name=$(echo "$line" | sed 's/://g' | sed 's/^  //')
            echo "  - $job_name"
        done
    else
        print_warning "工作流任务数量较少，可能还未完全并行化"
    fi
else
    print_error "未找到工作流配置文件"
    exit 1
fi

# 2. 验证缓存配置
print_section "验证 Docker 缓存配置"

if grep -q "cache-from:" .github/workflows/build-arm-centos.yml; then
    cache_sources=$(grep -A5 "cache-from:" .github/workflows/build-arm-centos.yml | grep "type=" | wc -l)
    print_success "已配置 $cache_sources 种缓存源"
    
    if grep -q "type=gha" .github/workflows/build-arm-centos.yml; then
        print_success "GitHub Actions 缓存: 已启用"
    fi
    
    if grep -q "type=registry" .github/workflows/build-arm-centos.yml; then
        print_success "Registry 缓存: 已启用"
    fi
else
    print_warning "未找到缓存配置"
fi

# 3. 检查 Dockerfile 优化
print_section "验证 Dockerfile 层数优化"

if [ -f "Dockerfile" ]; then
    layer_count=$(grep "^RUN\|^COPY\|^ADD" Dockerfile | wc -l)
    echo "Dockerfile 层数: $layer_count"
    
    if [ $layer_count -le 6 ]; then
        print_success "Dockerfile 层数已优化 (≤6 层)"
    else
        print_warning "Dockerfile 层数仍然较多 ($layer_count 层)"
    fi
    
    # 检查是否使用了合并的 RUN 命令
    if grep -q "yum install.*LibreOffice" Dockerfile; then
        print_success "软件包安装已合并到单个 RUN 命令"
    fi
else
    print_error "未找到 Dockerfile"
fi

# 4. 验证条件执行配置
print_section "验证条件执行和测试简化"

if grep -q "if:" .github/workflows/build-arm-centos.yml; then
    conditional_jobs=$(grep -c "if:" .github/workflows/build-arm-centos.yml)
    print_success "已配置 $conditional_jobs 个条件执行步骤"
fi

if grep -q "full_test:" .github/workflows/build-arm-centos.yml; then
    print_success "已添加手动触发的完整测试选项"
fi

# 5. 估算优化效果
print_section "预期优化效果"

echo "基于以下优化措施的预期效果:"
echo ""
echo "🔧 优化措施:"
echo "   • Docker 双重缓存 (GHA + Registry): 节省 8-12 分钟"
echo "   • Dockerfile 层数优化: 节省 2-4 分钟"  
echo "   • 并行任务执行: 节省 1-3 分钟"
echo "   • 简化测试步骤: 节省 1-2 分钟"
echo ""
echo "📊 预期结果:"
echo "   • 原始构建时间: ~16 分钟"
echo "   • 优化后 (首次): ~8-10 分钟"
echo "   • 优化后 (缓存命中): ~4-6 分钟"
echo ""

# 6. 提供测试建议
print_section "测试建议"

echo "推荐测试步骤:"
echo "1. 清除所有缓存后进行首次构建"
echo "2. 立即进行第二次构建验证缓存效果"
echo "3. 使用不同的分支测试缓存作用域"
echo "4. 手动触发完整测试验证功能"
echo ""

echo "GitHub Actions 手动触发命令:"
echo "gh workflow run build-arm-centos.yml --ref main"
echo "gh workflow run build-arm-centos.yml --ref main -f full_test=true"
echo ""

print_success "优化验证完成！建议进行实际构建测试。"