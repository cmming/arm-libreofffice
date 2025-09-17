# ARM LibreOffice

使用 GitHub Actions 自动构建 ARM 架构的 CentOS 7.9 Docker 镜像，内置 Java 8 和 LibreOffice。

## 系统要求

- CPU 架构：ARM64 (aarch64)
- 操作系统：CentOS 7.9.2009
- Java 版本：OpenJDK 8
- 办公软件：LibreOffice

## 获取镜像

### 从 Docker Hub 拉取（推荐）

```bash
# 拉取最新版本
docker pull cmming/arm-centos79-java8-libreoffice:latest

# 拉取稳定版本  
docker pull cmming/arm-centos79-java8-libreoffice:stable
```

### 本地构建

```bash
# 克隆仓库
git clone https://github.com/cmming/arm-libreofffice.git
cd arm-libreofffice

# 使用 Docker Buildx 构建 ARM64 镜像
docker buildx build --platform linux/arm64 -t arm-centos79-java8-libreoffice:latest .
```

## 推送到 Docker Hub

详细的推送指南请查看 [DOCKER-HUB-GUIDE.md](DOCKER-HUB-GUIDE.md)

### GitHub Actions 自动推送

1. 在 GitHub 仓库设置中添加 Secrets：
   - `DOCKERHUB_USERNAME`: 你的 Docker Hub 用户名
   - `DOCKERHUB_TOKEN`: 你的 Docker Hub 访问令牌

2. 推送代码到 main 分支即可自动构建并推送到 Docker Hub

### 本地手动推送

```bash
# 使用推送脚本
./push-to-dockerhub.sh your-dockerhub-username

# 或手动推送
docker tag arm-centos79-java8-libreoffice:latest your-username/arm-centos79-java8-libreoffice:latest
docker push your-username/arm-centos79-java8-libreoffice:latest
```

## 使用方法

### 运行容器

```bash
# 从 Docker Hub 拉取并运行
docker run -it --platform linux/arm64 cmming/arm-centos79-java8-libreoffice:latest

# 验证 Java 安装
docker run --rm --platform linux/arm64 cmming/arm-centos79-java8-libreoffice:latest java -version

# 验证 LibreOffice 安装
docker run --rm --platform linux/arm64 cmming/arm-centos79-java8-libreoffice:latest libreoffice --version

# 验证架构
docker run --rm --platform linux/arm64 cmming/arm-centos79-java8-libreoffice:latest uname -m
```

### 导入下载的镜像

如果从 GitHub Actions Artifacts 下载了镜像文件：

```bash
# 解压并导入镜像
gunzip arm-centos79-java8-libreoffice.tar.gz
docker load < arm-centos79-java8-libreoffice.tar
```

## 镜像信息

- **基础镜像**：`arm64v8/centos:7.9.2009`
- **Java 版本**：OpenJDK 1.8.0
- **LibreOffice 版本**：通过 EPEL 仓库安装的最新版本
- **JAVA_HOME**：`/usr/lib/jvm/java-1.8.0-openjdk`

## 注意事项

- 此镜像专为 ARM64 架构设计，在 x86_64 系统上运行需要 QEMU 模拟支持
- 构建过程需要较长时间，因为需要模拟 ARM 架构
- 镜像大小较大，包含完整的 LibreOffice 办公套件

## 自动化构建

GitHub Actions 工作流会在以下情况下自动触发构建：
- 推送到 main 分支
- 创建 Pull Request 到 main 分支
- 手动触发工作流

### 🏗️ **架构说明**

- **构建环境**: GitHub Actions (x86_64)
- **目标架构**: ARM64 (aarch64)
- **构建方法**: 使用 QEMU 模拟和 Docker Buildx

### ⚠️ **测试限制**

由于 GitHub Actions runner 运行在 x86_64 架构上，无法直接运行 ARM64 容器进行交互测试。但我们提供了以下验证方法：

1. **构建时验证**: 在 Dockerfile 中已包含所有必要的验证步骤
2. **推送后验证**: 检查 Docker Hub 上的镜像 manifest
3. **ARM64 环境测试**: 使用专门的测试工作流 (`.github/workflows/test-arm64.yml`)

### 🧪 **在真实 ARM64 环境中测试**

我们现在使用 `tonistiigi/binfmt` 提供更好的 ARM64 模拟支持：

```bash
# 方法一：使用提供的测试脚本（推荐）
./test-arm64-local.sh

# 方法二：手动设置和测试
docker run --rm --privileged tonistiigi/binfmt --install arm64
docker pull cmming/arm-centos79-java8-libreoffice:latest
docker run -it --platform linux/arm64 cmming/arm-centos79-java8-libreoffice:latest

# 方法三：在真实 ARM64 设备上测试
# 拉取并测试镜像（无需模拟）
docker pull cmming/arm-centos79-java8-libreoffice:latest
docker run -it cmming/arm-centos79-java8-libreoffice:latest
```

### ⚡ **性能对比**

| 环境 | 性能 | 兼容性 | 使用场景 |
|------|------|--------|----------|
| 原生 ARM64 | 100% | 完美 | 生产环境 |
| binfmt 模拟 | ~60-80% | 优秀 | 开发测试 |
| 标准 QEMU | ~20-40% | 良好 | 基础验证 |

## 作为 Java 服务基础镜像使用

这个镜像可以作为基础镜像来运行 Java 应用服务。我们提供了完整的示例和配置文件。

### 🚀 快速开始

#### 1. 构建和运行 Java 应用

```bash
```bash
# 构建基础镜像
docker build --platform linux/arm64 -t arm-centos79-java8-libreoffice .

# 或从 Docker Hub 拉取
docker pull cmming/arm-centos79-java8-libreoffice:latest

# 构建应用镜像
docker build --platform linux/arm64 -f Dockerfile.app -t my-java-app .

# 运行应用
docker run -p 8080:8080 --platform linux/arm64 my-java-app
```

#### 2. 使用 Docker Compose（推荐）

更新 docker-compose.yml 中的镜像名称：

```yaml
services:
  java-app:
    image: cmming/arm-centos79-java8-libreoffice:latest
    # ... 其他配置
```

然后运行：

```bash
# 构建并启动应用
docker-compose --profile app up --build

# 开发环境（包含调试端口）
docker-compose --profile dev up --build
```
```

#### 2. 使用 Docker Compose（推荐）

```bash
# 构建并启动应用
docker-compose --profile app up --build

# 开发环境（包含调试端口）
docker-compose --profile dev up --build

# 只构建基础镜像
docker-compose --profile build up --build
```

### 📁 项目结构

```
├── Dockerfile              # 基础镜像（CentOS 7.9 + Java 8 + LibreOffice）
├── Dockerfile.app          # Java 应用镜像
├── docker-compose.yml      # Docker Compose 配置
├── build-java-app.sh       # Java 应用构建脚本
├── java-app-example/       # 示例 Java 应用
│   └── SimpleJavaApp.java
├── config/                 # 应用配置文件
│   └── application.properties
└── test-document.txt       # 中文文档转换测试文件
```

### 🔧 Java 应用功能

示例应用提供以下功能：

- **健康检查**: `GET /health` - 应用健康状态
- **系统信息**: `GET /info` - ARM 架构和 Java 环境信息
- **主页**: `GET /` - 功能介绍和测试界面
- **文档转换**: `POST /convert` - LibreOffice 文档转换（示例）

### ⚙️ 配置说明

#### JVM 优化参数
```bash
JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC -XX:+UseContainerSupport -Dfile.encoding=UTF-8 -Duser.timezone=Asia/Shanghai"
```

#### 环境变量
- `PORT`: 应用端口（默认 8080）
- `JAVA_OPTS`: JVM 参数
- `LANG`: 语言环境（zh_CN.UTF-8）

#### 数据卷挂载
- `/app/config`: 配置文件目录
- `/app/logs`: 日志文件目录
- `/tmp/converts`: 文档转换临时目录

### 🛠️ 自定义应用

1. **替换 Java 应用**：
   ```dockerfile
   # 在 Dockerfile.app 中使用 Docker Hub 镜像
   FROM cmming/arm-centos79-java8-libreoffice:latest
   
   COPY --chown=appuser:appuser your-app.jar app.jar
   ```

2. **直接使用镜像**：
   ```bash
   # 运行你的 Java 应用
   docker run -v /path/to/your/app.jar:/app/app.jar \
              -p 8080:8080 --platform linux/arm64 \
              cmming/arm-centos79-java8-libreoffice:latest \
              java -jar /app/app.jar
   ```

3. **添加依赖**：
   ```dockerfile
   # 基于现有镜像添加额外软件
   FROM cmming/arm-centos79-java8-libreoffice:latest
   RUN yum install -y your-package
   ```

### 📊 性能考虑

- **内存设置**: 根据应用需求调整 `-Xms` 和 `-Xmx`
- **垃圾收集器**: 推荐使用 G1GC（`-XX:+UseG1GC`）
- **容器优化**: 启用 `UseContainerSupport` 自动检测容器资源限制
- **字符编码**: 强制使用 UTF-8 支持中文

### 🐛 调试模式

开发环境支持 Java 远程调试：

```bash
# 启动调试模式
docker-compose --profile dev up

# 连接调试器到端口 5005
# IDE 中配置远程调试：localhost:5005
```