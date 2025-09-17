# Docker Hub 推送配置指南

## 🚀 快速开始

### 方法一：GitHub Actions 自动推送（推荐）

#### 1. 配置 GitHub Secrets

在 GitHub 仓库中设置以下 Secrets：

1. 访问 GitHub 仓库 → Settings → Secrets and variables → Actions
2. 点击 "New repository secret" 添加：

```
DOCKERHUB_USERNAME: 你的DockerHub用户名
DOCKERHUB_TOKEN: 你的DockerHub访问令牌
```

#### 2. 创建 Docker Hub 访问令牌

1. 登录 [Docker Hub](https://hub.docker.com/)
2. 点击头像 → Account Settings → Security
3. 点击 "New Access Token"
4. 输入令牌名称（如：github-actions）
5. 选择权限：Read, Write, Delete
6. 复制生成的令牌到 GitHub Secrets

#### 3. 触发自动构建和推送

- **推送到 main 分支**：自动触发构建和推送
- **创建 Pull Request**：只构建，不推送
- **手动触发**：在 Actions 页面手动运行工作流

### 方法二：本地手动推送

#### 1. 构建镜像

```bash
# 构建 ARM64 镜像
docker build --platform linux/arm64 -t arm-centos79-java8-libreoffice:latest .
```

#### 2. 登录 Docker Hub

```bash
docker login
# 输入用户名和密码（或访问令牌）
```

#### 3. 使用推送脚本

```bash
# 使用脚本推送（推荐）
./push-to-dockerhub.sh your-dockerhub-username

# 或者手动推送
docker tag arm-centos79-java8-libreoffice:latest your-username/arm-centos79-java8-libreoffice:latest
docker push your-username/arm-centos79-java8-libreoffice:latest
```

## 🏷️ 镜像标签说明

- `latest`: 最新版本
- `stable`: 稳定版本
- `YYYYMMDD`: 日期版本（如：20240916）
- `sha-xxxxxxx`: Git 提交版本
- `main`: 主分支版本

## 📋 使用推送后的镜像

### 拉取镜像

```bash
# 拉取最新版本
docker pull your-username/arm-centos79-java8-libreoffice:latest

# 拉取稳定版本
docker pull your-username/arm-centos79-java8-libreoffice:stable
```

### 运行容器

```bash
# 交互式运行
docker run -it --platform linux/arm64 your-username/arm-centos79-java8-libreoffice:latest

# 后台运行 Java 应用
docker run -d -p 8080:8080 --platform linux/arm64 your-username/arm-centos79-java8-libreoffice:latest
```

### 作为基础镜像

```dockerfile
FROM your-username/arm-centos79-java8-libreoffice:latest

WORKDIR /app
COPY app.jar .
CMD ["java", "-jar", "app.jar"]
```

## 🔧 Docker Compose 集成

```yaml
version: '3.8'
services:
  app:
    image: your-username/arm-centos79-java8-libreoffice:latest
    platform: linux/arm64
    ports:
      - "8080:8080"
```

## 🛠️ 故障排除

### 常见问题

1. **推送权限错误**
   ```
   denied: requested access to the resource is denied
   ```
   - 确认 Docker Hub 用户名正确
   - 确认访问令牌有写入权限

2. **架构不匹配**
   ```
   no matching manifest for linux/amd64
   ```
   - 确保使用 `--platform linux/arm64` 参数

3. **GitHub Actions 失败**
   - 检查 Secrets 配置是否正确
   - 确认 Docker Hub 令牌未过期

### 调试命令

```bash
# 检查本地镜像
docker images | grep arm-centos79

# 检查镜像架构
docker manifest inspect your-username/arm-centos79-java8-libreoffice:latest

# 检查 Docker Hub 登录状态
docker info | grep Username

# 测试拉取
docker pull your-username/arm-centos79-java8-libreoffice:latest
```

## 📊 镜像信息

- **基础系统**: CentOS 7.9.2009
- **架构**: ARM64 (aarch64)
- **Java版本**: OpenJDK 8
- **LibreOffice**: EPEL 版本
- **中文支持**: 完整
- **镜像大小**: 约 1.5-2GB