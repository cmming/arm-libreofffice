#!/bin/bash

# 编译和打包 Java 应用的构建脚本

echo "=== ARM CentOS Java 应用构建脚本 ==="

# 创建目标目录
mkdir -p target

# 编译 Java 应用
echo "编译 Java 应用..."
javac -d target java-app-example/SimpleJavaApp.java

if [ $? -eq 0 ]; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

# 创建 JAR 包
echo "创建 JAR 包..."
cd target
jar -cfe app.jar com.example.app.SimpleJavaApp com/
cd ..

if [ -f target/app.jar ]; then
    echo "✅ JAR 包创建成功: target/app.jar"
    ls -la target/app.jar
else
    echo "❌ JAR 包创建失败"
    exit 1
fi

echo ""
echo "=== 下一步操作 ==="
echo "1. 构建基础镜像: docker build -t arm-centos79-java8-libreoffice ."
echo "2. 构建应用镜像: docker build -f Dockerfile.app -t my-java-app ."
echo "3. 运行应用: docker run -p 8080:8080 --platform linux/arm64 my-java-app"