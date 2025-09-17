#!/bin/bash
# GitHub Actions 缓存使用情况检查脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}🎯 $1${NC}"
    echo "$(printf '%.0s=' {1..50})"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header "GitHub Actions 缓存配置检查"

# 检查工作流中的缓存配置
if [ ! -f ".github/workflows/build-arm-centos.yml" ]; then
    print_error "工作流文件未找到"
    exit 1
fi

WORKFLOW_FILE=".github/workflows/build-arm-centos.yml"

# 1. 检查 actions/cache 使用情况
print_header "检查 actions/cache 配置"

CACHE_STEPS=$(grep -c "uses: actions/cache@" "$WORKFLOW_FILE" 2>/dev/null || echo "0")
echo "发现 actions/cache 步骤数量: $CACHE_STEPS"

if [ "$CACHE_STEPS" -gt 0 ]; then
    print_success "已配置 GitHub Actions 原生缓存"
    
    echo "缓存步骤详情:"
    grep -A 10 -B 1 "uses: actions/cache@" "$WORKFLOW_FILE" | while IFS= read -r line; do
        if [[ "$line" =~ name:.* ]]; then
            cache_name=$(echo "$line" | sed 's/.*name: //' | sed 's/^[[:space:]]*//')
            echo "  • $cache_name"
        fi
    done
else
    print_info "未配置 GitHub Actions 原生缓存"
fi

# 2. 检查 Docker BuildKit GHA 缓存
print_header "检查 Docker BuildKit 缓存"

if grep -q "type=gha" "$WORKFLOW_FILE"; then
    print_success "已配置 Docker BuildKit GHA 缓存"
    
    GHA_CACHE_COUNT=$(grep -c "type=gha" "$WORKFLOW_FILE")
    echo "GHA 缓存引用数量: $GHA_CACHE_COUNT"
    
    # 检查缓存作用域
    if grep -q "scope=" "$WORKFLOW_FILE"; then
        print_success "已配置缓存作用域"
        echo "缓存作用域:"
        grep "scope=" "$WORKFLOW_FILE" | sed 's/.*scope=/  • scope=/' | sed 's/,.*$//'
    fi
else
    print_info "未配置 Docker BuildKit GHA 缓存"
fi

# 3. 检查 Docker Registry 缓存
print_header "检查 Docker Registry 缓存"

if grep -q "type=registry" "$WORKFLOW_FILE"; then
    print_success "已配置 Docker Registry 缓存"
    
    REGISTRY_CACHE_COUNT=$(grep -c "type=registry" "$WORKFLOW_FILE")
    echo "Registry 缓存引用数量: $REGISTRY_CACHE_COUNT"
    
    # 检查缓存标签
    echo "Registry 缓存标签:"
    grep "type=registry" "$WORKFLOW_FILE" | sed 's/.*ref=/  • /' | sed 's/,.*$//' | sed 's/:/ → tag: /'
else
    print_info "未配置 Docker Registry 缓存"
fi

# 4. 缓存策略分析
print_header "缓存策略分析"

echo "当前缓存架构:"

if [ "$CACHE_STEPS" -gt 0 ] && grep -q "type=gha" "$WORKFLOW_FILE" && grep -q "type=registry" "$WORKFLOW_FILE"; then
    print_success "三重缓存策略 - 最优配置"
    echo "  1. GitHub Actions Cache (actions/cache) - 工具和环境缓存"
    echo "  2. Docker BuildKit GHA Cache - Docker 层缓存"
    echo "  3. Docker Registry Cache - 持久化镜像缓存"
elif grep -q "type=gha" "$WORKFLOW_FILE" && grep -q "type=registry" "$WORKFLOW_FILE"; then
    print_success "双重 Docker 缓存策略 - 良好配置"
    echo "  1. Docker BuildKit GHA Cache"
    echo "  2. Docker Registry Cache"
elif grep -q "type=gha" "$WORKFLOW_FILE"; then
    print_info "单一 GHA 缓存 - 基础配置"
else
    print_error "未发现有效缓存配置"
fi

# 5. 缓存效果预估
print_header "缓存效果预估"

if [ "$CACHE_STEPS" -gt 0 ] && grep -q "type=gha" "$WORKFLOW_FILE" && grep -q "type=registry" "$WORKFLOW_FILE"; then
    echo "预期缓存效果 (三重缓存):"
    echo "  📊 首次构建: ~8-10 分钟"
    echo "  📊 缓存命中: ~4-6 分钟"
    echo "  📊 节省时间: 60-75%"
    echo "  📊 预期命中率: 85-95%"
elif grep -q "type=registry" "$WORKFLOW_FILE"; then
    echo "预期缓存效果 (双重缓存):"
    echo "  📊 首次构建: ~10-12 分钟"
    echo "  📊 缓存命中: ~6-8 分钟"
    echo "  📊 节省时间: 40-50%"
    echo "  📊 预期命中率: 70-85%"
else
    echo "预期缓存效果 (有限):"
    echo "  📊 节省时间: <30%"
    echo "  📊 需要优化缓存配置"
fi

# 6. 缓存监控建议
print_header "缓存监控建议"

echo "GitHub CLI 缓存监控命令:"
echo "  gh cache list                    # 查看所有缓存"
echo "  gh cache list --key buildx       # 查看特定缓存"
echo "  gh cache delete --key <key>      # 删除缓存"
echo ""

echo "缓存配额监控:"
echo "  • 免费配额: 10 GB"
echo "  • 自动清理: 7天未使用"
echo "  • 查看使用情况: GitHub Settings → Actions → Caches"

# 7. 优化建议
print_header "进一步优化建议"

echo "缓存优化机会:"

# 检查是否缺少某些缓存
if [ "$CACHE_STEPS" -eq 0 ]; then
    echo "  📈 添加 actions/cache 缓存构建工具"
fi

if ! grep -q "qemu" "$WORKFLOW_FILE"; then
    echo "  📈 缓存 QEMU 二进制文件以加速 ARM64 模拟"
fi

if ! grep -q "scope=" "$WORKFLOW_FILE"; then
    echo "  📈 添加缓存作用域以提高命中率"
fi

# 检查缓存键设计
if grep -q "github.sha" "$WORKFLOW_FILE"; then
    print_success "缓存键包含 SHA，有助于版本控制"
else
    echo "  📈 考虑在缓存键中包含文件哈希"
fi

print_header "缓存配置验证完成"

if [ "$CACHE_STEPS" -gt 0 ] && grep -q "type=gha" "$WORKFLOW_FILE" && grep -q "type=registry" "$WORKFLOW_FILE"; then
    print_success "缓存配置优秀！已实现多重缓存策略。"
else
    print_info "缓存配置可以进一步优化，参考上述建议。"
fi

echo ""
echo "🚀 触发构建测试缓存效果:"
echo "   gh workflow run build-arm-centos.yml --ref main"