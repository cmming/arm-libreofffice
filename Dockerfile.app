# 基于基础镜像构建 Java 应用
FROM arm-centos79-java8-libreoffice:latest

# 设置工作目录
WORKDIR /app

# 创建必要的目录
RUN mkdir -p /app/config /app/logs /tmp/converts

# 复制 Java 应用代码
COPY java-app-example/SimpleJavaApp.java /app/src/
COPY config/application.properties /app/config/

# 编译 Java 应用
RUN cd /app/src && javac SimpleJavaApp.java

# 安装 curl 用于健康检查
RUN yum install -y curl && yum clean all

# 设置环境变量
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

# 暴露端口
EXPOSE 8080 5005

# 创建启动脚本
RUN cat > /app/start.sh << 'EOF' && \
#!/bin/bash
set -e

echo "=== 启动 Java 应用 ==="
echo "Java 版本: $(java -version 2>&1 | head -1)"
echo "LibreOffice 版本: $(libreoffice --version)"
echo "工作目录: $(pwd)"
echo "环境变量:"
env | grep -E "(JAVA|LANG|LC_)" | sort

cd /app/src
exec java $JAVA_OPTS SimpleJavaApp
EOF

RUN chmod +x /app/start.sh

# 启动命令
CMD ["/app/start.sh"]