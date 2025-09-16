FROM arm64v8/centos:7.9.2009

# 安装 Java 8 (OpenJDK)
RUN yum update -y && \
    yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel

# 安装 EPEL 仓库以获取 LibreOffice
RUN yum install -y epel-release

# 安装 LibreOffice
RUN yum install -y libreoffice

# 清理 yum 缓存以减小镜像大小
RUN yum clean all && \
    rm -rf /var/cache/yum

# 设置 JAVA_HOME 环境变量
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk

# 验证安装
RUN java -version && \
    libreoffice --version && \
    echo "Architecture: $(uname -m)"

# 设置默认命令
CMD ["/bin/bash"]