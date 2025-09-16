FROM arm64v8/centos:7.9.2009

# 修复 CentOS 7 yum 仓库配置（使用归档仓库）
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*.repo

# 安装中文支持和必要的软件包
RUN yum update -y && \
    yum install -y glibc-common && \
    yum reinstall -y glibc-common

# 设置中文语言环境
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8 && \
    localedef -c -f UTF-8 -i en_US en_US.UTF-8

# 设置环境变量支持中文
ENV LANG=zh_CN.UTF-8
ENV LC_ALL=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_CTYPE=zh_CN.UTF-8

# 安装 Java 8 (OpenJDK)
RUN yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel

# 安装 EPEL 仓库以获取 LibreOffice
RUN yum install -y epel-release

# 安装 LibreOffice 和中文字体支持
RUN yum install -y libreoffice && \
    yum groupinstall -y "Fonts" && \
    yum install -y dejavu-fonts-common dejavu-sans-fonts dejavu-serif-fonts dejavu-sans-mono-fonts && \
    yum install -y wqy-microhei-fonts wqy-zenhei-fonts && \
    yum install -y google-noto-sans-cjk-ttc-fonts google-noto-serif-cjk-ttc-fonts 2>/dev/null || \
    yum install -y cjkuni-uming-fonts cjkuni-ukai-fonts 2>/dev/null || true

# 清理 yum 缓存以减小镜像大小
RUN yum clean all && \
    rm -rf /var/cache/yum

# 更新字体缓存
RUN fc-cache -fv

# 设置 JAVA_HOME 环境变量
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk

# 验证安装和中文支持
RUN java -version && \
    libreoffice --version && \
    echo "Architecture: $(uname -m)" && \
    echo "Locale: $LANG" && \
    echo "中文测试: 你好世界"

# 设置默认命令
CMD ["/bin/bash"]