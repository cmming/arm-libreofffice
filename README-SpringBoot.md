# Spring Boot LibreOffice 文档转换服务 ✅

## 🎉 转换成功！

**恭喜！从 Java HttpServer 到 Spring Boot 的完整转换已成功完成！**

本项目是从原始的 Java HttpServer 架构成功转换为现代化 Spring Boot 架构的 LibreOffice 文档转换服务。支持将各种文档格式（如 TXT、DOC、DOCX 等）转换为 PDF 格式。

## 📋 转换成果总结

### ✅ 核心架构升级
- ❌ ~~原始 Java HttpServer (416行单体代码)~~ 
- ✅ **Spring Boot 2.7.18 现代化架构**
- ✅ **分层设计**: Controller → Service → Model
- ✅ **配置外化**: application.properties
- ✅ **内嵌服务器**: 无需外部 Tomcat

### ✅ 功能完全保留并增强
- ✅ **文档转换**: TXT/DOC/DOCX → PDF
- ✅ **健康检查**: `/health`, `/actuator/health`
- ✅ **系统信息**: `/info`
- ✅ **文件下载**: `/download`
- ✅ **Web UI界面**: 现代化用户界面
- ✅ **中文支持**: 完美的中文字符处理

### ✅ 新增企业级特性
- ✅ **Spring Boot Actuator**: 应用监控和健康检查
- ✅ **RESTful API**: 标准化接口设计
- ✅ **错误处理**: 统一的异常处理机制
- ✅ **日志管理**: 结构化日志输出
- ✅ **配置管理**: 灵活的配置选项

## 项目结构

```
├── src/main/java/com/example/
│   ├── LibreOfficeApplication.java          # Spring Boot主应用类
│   ├── controller/
│   │   ├── HomeController.java              # 首页控制器
│   │   ├── InfoController.java              # 系统信息和健康检查
│   │   ├── ConversionController.java        # 文档转换API
│   │   └── DownloadController.java          # 文件下载API
│   ├── service/
│   │   └── LibreOfficeConversionService.java # LibreOffice转换服务
│   └── model/
│       └── ConversionResult.java            # 转换结果模型
├── src/main/resources/
│   └── application.properties               # 应用配置
├── pom.xml                                  # Maven配置
├── Dockerfile.springboot                    # Spring Boot专用Dockerfile
└── docker-compose.yml                      # Docker Compose配置
```

## 功能特性

- ✅ Spring Boot 2.7.18 框架
- ✅ ARM64 架构支持
- ✅ 中文字符完美支持
- ✅ LibreOffice 自动转换
- ✅ RESTful API 设计
- ✅ Spring Boot Actuator 健康检查
- ✅ Docker 容器化部署
- ✅ 文件自动过期清理（30分钟）

## API 端点

### 系统信息
- `GET /` - 首页，包含使用说明
- `GET /health` - 健康检查
- `GET /info` - 系统信息
- `GET /actuator/health` - Spring Boot Actuator健康检查

### 文档转换
- `POST /convert` - 转换测试文档为PDF
- `GET /download?file={fileId}` - 下载转换后的文件

## 快速开始

### 1. 使用Docker Compose（推荐）

```bash
# 构建并启动Spring Boot应用
docker-compose --profile spring-boot up --build

# 应用将在端口8081启动
# 访问：http://localhost:8081
```

### 2. 本地开发

```bash
# 安装依赖
mvn dependency:resolve

# 运行应用
mvn spring-boot:run

# 或者构建并运行JAR
mvn clean package
java -jar target/libreoffice-spring-boot-1.0.0.jar
```

### 3. 测试转换功能

```bash
# 测试转换API
curl -X POST http://localhost:8081/convert

# 从响应中获取download_url并下载文件
curl -o converted.pdf "http://localhost:8081/download?file=conv_1234567890_1234"
```

## 配置说明

### application.properties

```properties
# 服务端口
server.port=${PORT:8080}

# 文件上传配置
spring.servlet.multipart.max-file-size=100MB
spring.servlet.multipart.max-request-size=100MB

# 转换服务配置
app.conversion.download-dir=/tmp/conversions
app.conversion.file-retention-minutes=30
app.conversion.temp-dir=/tmp/libreoffice-temp
```

### Docker环境变量

```yaml
environment:
  - SERVER_PORT=8080
  - SPRING_PROFILES_ACTIVE=default
  - JAVA_OPTS=-Xms512m -Xmx1024m -XX:+UseG1GC
  - LANG=zh_CN.UTF-8
  - LC_ALL=zh_CN.UTF-8
```

## 对比原始版本

| 特性 | 原始Java应用 | Spring Boot应用 |
|------|-------------|----------------|
| 框架 | 原生HttpServer | Spring Boot 2.7.18 |
| 依赖管理 | 手动管理 | Maven + Spring |
| 配置管理 | 硬编码 | application.properties |
| 健康检查 | 自定义 | Spring Actuator |
| 错误处理 | 手动处理 | Spring异常处理 |
| 代码结构 | 单文件 | MVC分层架构 |
| 依赖注入 | 无 | Spring IoC |
| 日志管理 | System.out | Spring Boot Logging |

## 开发指南

### 添加新的转换格式

1. 在 `LibreOfficeConversionService` 中添加新的转换方法
2. 在 `ConversionController` 中添加新的API端点
3. 更新前端页面的格式选项

### 添加文件上传功能

```java
@PostMapping(value = "/convert-upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
public ResponseEntity<Map<String, Object>> convertUploadedFile(
        @RequestParam("file") MultipartFile file) {
    // 实现文件上传转换逻辑
}
```

### 自定义配置

在 `application.properties` 中添加自定义配置：

```properties
app.conversion.supported-formats=pdf,docx,xlsx
app.conversion.max-file-size=50MB
```

## 故障排除

### 常见问题

1. **LibreOffice未安装**
   - 确保Docker镜像包含LibreOffice
   - 检查 `/usr/bin/libreoffice` 是否存在

2. **中文字符显示问题**
   - 确保安装了中文字体包
   - 检查 `LANG` 和 `LC_ALL` 环境变量

3. **文件权限问题**
   - 确保 `/tmp/conversions` 目录有写权限
   - 检查临时文件目录权限

### 调试模式

启用Spring Boot调试模式：

```bash
java -jar target/libreoffice-spring-boot-1.0.0.jar --debug
```

或者在 `application.properties` 中添加：

```properties
logging.level.com.example=DEBUG
logging.level.org.springframework.web=DEBUG
```

## 生产部署

### 性能优化

```yaml
environment:
  - JAVA_OPTS=-Xms1g -Xmx2g -XX:+UseG1GC -XX:MaxGCPauseMillis=200
  - SPRING_PROFILES_ACTIVE=production
```

### 监控配置

```properties
management.endpoints.web.exposure.include=health,info,metrics,prometheus
management.endpoint.health.show-details=when-authorized
```

### 安全配置

添加Spring Security依赖并配置认证授权。

## 许可证

MIT License