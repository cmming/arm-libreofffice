FROM arm64v8/centos:7.9.2009

# 设置构建时优化环境变量
ENV BUILDKIT_INLINE_CACHE=1

# 修复 CentOS 7 yum 仓库配置（使用归档仓库）并优化 yum 性能
RUN set -ex && \
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*.repo && \
    # yum 性能优化配置
    echo "fastestmirror=1" >> /etc/yum.conf && \
    echo "deltarpm=0" >> /etc/yum.conf && \
    echo "keepcache=0" >> /etc/yum.conf && \
    echo "max_parallel_downloads=8" >> /etc/yum.conf && \
    yum clean all

# 一次性安装所有必需软件包（最关键的缓存层）
RUN set -ex && \
    yum update -y && \
    # 基础工具和 Java 8
    yum install -y \
        glibc-common wget curl tar \
        java-1.8.0-openjdk java-1.8.0-openjdk-devel \
        epel-release && \
    # 重新安装并设置语言环境
    yum reinstall -y glibc-common && \
    localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8 && \
    localedef -c -f UTF-8 -i en_US en_US.UTF-8 && \
    # LibreOffice 安装（一次性完成）
    yum install -y libreoffice && \
    # 字体包安装（并行处理错误）
    yum groupinstall -y "Fonts" 2>/dev/null || true && \
    yum install -y \
        dejavu-fonts-common dejavu-sans-fonts dejavu-serif-fonts dejavu-sans-mono-fonts \
        wqy-microhei-fonts wqy-zenhei-fonts 2>/dev/null || true && \
    yum install -y \
        google-noto-sans-cjk-ttc-fonts google-noto-serif-cjk-ttc-fonts \
        cjkuni-uming-fonts cjkuni-ukai-fonts 2>/dev/null || true && \
    # 立即清理缓存减少层大小
    yum clean all && \
    rm -rf /var/cache/yum /tmp/* /var/tmp/*

# 设置环境变量（修复 JAVA_HOME 引用问题）
ENV LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_CTYPE=zh_CN.UTF-8 \
    JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk

# 更新 PATH 环境变量
ENV PATH=$JAVA_HOME/bin:$PATH

# 字体缓存更新和最终验证（快速完成的层）
RUN set -ex && \
    fc-cache -fv && \
    # 构建时验证（减少日志输出）
    java -version >/dev/null 2>&1 && \
    libreoffice --version >/dev/null 2>&1 && \
    echo "✅ ARM64 构建完成: $(uname -m)" && \
    echo "✅ 语言环境: $LANG" && \
    rm -rf /tmp/* /var/tmp/*

# 安装更新版本的 Maven（解决版本冲突）
RUN set -ex && \
    # 下载并安装 Maven 3.9.6
    MAVEN_VERSION=3.9.6 && \
    wget -q https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt && \
    ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven && \
    rm -f apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    # 清理临时文件
    rm -rf /tmp/* /var/tmp/*

# 更新环境变量，添加 Maven
ENV MAVEN_HOME=/opt/maven \
    PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH

# 验证 Maven 和 Java 安装
RUN set -ex && \
    java -version && \
    mvn -version && \
    echo "✅ Maven 安装完成: $(mvn -version | head -n 1)"

# 设置工作目录
WORKDIR /app

# 复制 Maven 配置文件
COPY pom.xml .

# 下载依赖（利用 Docker 缓存层）
RUN mvn dependency:go-offline -B

# 复制源代码
COPY src/ src/

# 构建应用
RUN mvn clean package -DskipTests

# 暴露端口
EXPOSE 8080

# 启动应用
CMD ["java", "-jar", "target/libreoffice-spring-boot-1.0.0.jar"]