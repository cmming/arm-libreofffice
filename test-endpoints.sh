#!/bin/bash

echo "🔍 测试 Spring Boot 应用端点..."

# 等待应用启动
echo "等待应用启动..."
sleep 10

echo ""
echo "1. 测试健康检查端点:"
curl -s http://localhost:8080/health || echo "健康检查失败"

echo ""
echo "2. 测试系统信息端点:"
curl -s http://localhost:8080/info || echo "系统信息获取失败"

echo ""
echo "3. 测试主页面:"
curl -s -I http://localhost:8080/ | head -1 || echo "主页面访问失败"

echo ""
echo "4. 测试Spring Boot Actuator健康端点:"
curl -s http://localhost:8080/actuator/health || echo "Actuator健康检查失败"

echo ""
echo "✅ 端点测试完成！"