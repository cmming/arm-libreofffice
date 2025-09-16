# ARM LibreOffice

使用 GitHub Actions 自动构建 ARM 架构的 CentOS 7.9 Docker 镜像，内置 Java 8 和 LibreOffice。

## 系统要求

- CPU 架构：ARM64 (aarch64)
- 操作系统：CentOS 7.9.2009
- Java 版本：OpenJDK 8
- 办公软件：LibreOffice

## 构建方法

### 1. 使用 GitHub Actions 自动构建

1. Fork 或克隆此仓库
2. 在 GitHub 仓库的 Actions 标签页中，点击 "Build ARM CentOS 7.9 with Java8 and LibreOffice" 工作流
3. 点击 "Run workflow" 按钮手动触发构建
4. 构建完成后，可以在 Artifacts 中下载生成的 Docker 镜像 tar.gz 文件

### 2. 本地构建（需要支持 ARM64 模拟）

```bash
# 克隆仓库
git clone https://github.com/cmming/arm-libreofffice.git
cd arm-libreofffice

# 使用 Docker Buildx 构建 ARM64 镜像
docker buildx build --platform linux/arm64 -t arm-centos79-java8-libreoffice:latest .
```

## 使用方法

### 运行容器

```bash
# 交互式运行容器
docker run -it --platform linux/arm64 arm-centos79-java8-libreoffice:latest

# 验证 Java 安装
docker run --rm --platform linux/arm64 arm-centos79-java8-libreoffice:latest java -version

# 验证 LibreOffice 安装
docker run --rm --platform linux/arm64 arm-centos79-java8-libreoffice:latest libreoffice --version

# 验证架构
docker run --rm --platform linux/arm64 arm-centos79-java8-libreoffice:latest uname -m
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

## 作为 Java 服务基础镜像使用

这个镜像可以作为基础镜像来运行 Java 应用服务。我们提供了完整的示例和配置文件。

### 🚀 快速开始

#### 1. 构建和运行 Java 应用

```bash
# 1. 构建基础镜像
docker build --platform linux/arm64 -t arm-centos79-java8-libreoffice .

# 2. 编译 Java 应用（可选，已提供示例）
./build-java-app.sh

# 3. 构建应用镜像
docker build --platform linux/arm64 -f Dockerfile.app -t my-java-app .

# 4. 运行应用
docker run -p 8080:8080 --platform linux/arm64 my-java-app
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
   # 在 Dockerfile.app 中
   COPY --chown=appuser:appuser your-app.jar app.jar
   ```

2. **添加依赖**：
   ```dockerfile
   # 在基础镜像中添加额外软件
   RUN yum install -y your-package
   ```

3. **修改配置**：
   ```bash
   # 编辑 config/application.properties
   # 或通过环境变量覆盖
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