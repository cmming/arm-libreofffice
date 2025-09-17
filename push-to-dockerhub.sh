#!/bin/bash

# Docker Hub 推送脚本
# 使用方法：./push-to-dockerhub.sh [your-dockerhub-username]

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 获取 Docker Hub 用户名
DOCKERHUB_USERNAME="${1:-${DOCKERHUB_USERNAME}}"
if [ -z "$DOCKERHUB_USERNAME" ]; then
    echo -e "${RED}错误: 请提供 Docker Hub 用户名${NC}"
    echo "使用方法: $0 <dockerhub-username>"
    echo "或者设置环境变量: export DOCKERHUB_USERNAME=your-username"
    exit 1
fi

# 镜像名称和标签
IMAGE_NAME="arm-centos79-java8-libreoffice"
LOCAL_IMAGE="$IMAGE_NAME:latest"
REMOTE_IMAGE="$DOCKERHUB_USERNAME/$IMAGE_NAME"

echo -e "${BLUE}=== ARM CentOS 7.9 Docker 镜像推送脚本 ===${NC}"
echo -e "${YELLOW}Docker Hub 用户名: $DOCKERHUB_USERNAME${NC}"
echo -e "${YELLOW}镜像名称: $IMAGE_NAME${NC}"
echo ""

# 检查是否已登录 Docker Hub
echo -e "${BLUE}检查 Docker Hub 登录状态...${NC}"
if ! docker info | grep -q "Username: $DOCKERHUB_USERNAME"; then
    echo -e "${YELLOW}请先登录 Docker Hub:${NC}"
    docker login
    echo ""
fi

# 检查本地镜像是否存在
echo -e "${BLUE}检查本地镜像...${NC}"
if ! docker images | grep -q "$IMAGE_NAME"; then
    echo -e "${RED}错误: 本地镜像 $LOCAL_IMAGE 不存在${NC}"
    echo -e "${YELLOW}请先构建镜像:${NC}"
    echo "  docker build --platform linux/arm64 -t $LOCAL_IMAGE ."
    exit 1
fi

# 显示本地镜像信息
echo -e "${GREEN}找到本地镜像:${NC}"
docker images | grep "$IMAGE_NAME" | head -1

# 标记镜像
echo -e "${BLUE}为镜像添加 Docker Hub 标签...${NC}"
docker tag "$LOCAL_IMAGE" "$REMOTE_IMAGE:latest"
docker tag "$LOCAL_IMAGE" "$REMOTE_IMAGE:stable"

# 获取当前日期作为版本标签
DATE_TAG=$(date +%Y%m%d)
docker tag "$LOCAL_IMAGE" "$REMOTE_IMAGE:$DATE_TAG"

echo -e "${GREEN}已添加标签:${NC}"
echo "  $REMOTE_IMAGE:latest"
echo "  $REMOTE_IMAGE:stable"
echo "  $REMOTE_IMAGE:$DATE_TAG"
echo ""

# 推送镜像
echo -e "${BLUE}推送镜像到 Docker Hub...${NC}"
echo -e "${YELLOW}这可能需要一些时间...${NC}"

docker push "$REMOTE_IMAGE:latest"
docker push "$REMOTE_IMAGE:stable"
docker push "$REMOTE_IMAGE:$DATE_TAG"

echo ""
echo -e "${GREEN}✅ 镜像推送成功！${NC}"
echo ""
echo -e "${BLUE}Docker Hub 地址:${NC}"
echo "  https://hub.docker.com/r/$DOCKERHUB_USERNAME/$IMAGE_NAME"
echo ""
echo -e "${BLUE}使用方法:${NC}"
echo "  # 拉取最新版本"
echo "  docker pull $REMOTE_IMAGE:latest"
echo ""
echo "  # 运行容器"
echo "  docker run -it --platform linux/arm64 $REMOTE_IMAGE:latest"
echo ""
echo "  # 作为 Java 应用基础镜像"
echo "  FROM $REMOTE_IMAGE:latest"
echo ""

# 清理本地标签（可选）
read -p "是否清理本地临时标签? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}清理本地标签...${NC}"
    docker rmi "$REMOTE_IMAGE:latest" "$REMOTE_IMAGE:stable" "$REMOTE_IMAGE:$DATE_TAG" 2>/dev/null || true
    echo -e "${GREEN}清理完成${NC}"
fi

echo -e "${GREEN}🎉 Docker Hub 推送流程完成！${NC}"