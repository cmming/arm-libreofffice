# 基于我们构建的 ARM CentOS 镜像运行 Java 应用
# 使用方式：
# 1. 先构建基础镜像：docker build -t arm-centos79-java8-libreoffice .
# 2. 构建应用镜像：docker build -f Dockerfile.app -t my-java-app .

FROM arm-centos79-java8-libreoffice:latest

# 设置工作目录
WORKDIR /app

# 创建应用用户（安全最佳实践）
RUN useradd -m -s /bin/bash appuser && \
    chown -R appuser:appuser /app

# 复制 Java 应用 JAR 文件
COPY --chown=appuser:appuser target/*.jar app.jar

# 可选：复制配置文件
COPY --chown=appuser:appuser config/ ./config/

# 可选：复制其他资源文件
COPY --chown=appuser:appuser resources/ ./resources/

# 暴露应用端口（根据你的应用调整）
EXPOSE 8080

# 切换到应用用户
USER appuser

# 设置 JVM 参数（针对容器优化）
ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC -XX:+UseContainerSupport -Dfile.encoding=UTF-8 -Duser.timezone=Asia/Shanghai"

# 健康检查（可选）
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# 启动应用
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]