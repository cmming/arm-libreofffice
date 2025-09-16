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