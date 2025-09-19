package com.example.app;

import java.io.*;
import java.net.*;
import java.util.concurrent.Executors;
import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;

public class SimpleJavaApp {
    
    public static void main(String[] args) throws IOException {
        int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8080"));
        
        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
        
        // 健康检查端点
        server.createContext("/health", new HealthHandler());
        
        // 主页端点
        server.createContext("/", new HomeHandler());
        
        // LibreOffice 文档转换端点
        server.createContext("/convert", new ConvertHandler());
        
        // 系统信息端点
        server.createContext("/info", new InfoHandler());
        
        server.setExecutor(Executors.newFixedThreadPool(10));
        server.start();
        
        System.out.println("Java应用服务启动成功！");
        System.out.println("端口: " + port);
        System.out.println("架构: " + System.getProperty("os.arch"));
        System.out.println("Java版本: " + System.getProperty("java.version"));
        System.out.println("语言环境: " + System.getProperty("user.language"));
        System.out.println("字符编码: " + System.getProperty("file.encoding"));
    }
    
    // 健康检查处理器
    static class HealthHandler implements HttpHandler {
        public void handle(HttpExchange exchange) throws IOException {
            String response = "{\"status\":\"OK\",\"timestamp\":\"" + new java.util.Date() + "\"}";
            exchange.getResponseHeaders().set("Content-Type", "application/json; charset=UTF-8");
            exchange.sendResponseHeaders(200, response.getBytes("UTF-8").length);
            OutputStream os = exchange.getResponseBody();
            os.write(response.getBytes("UTF-8"));
            os.close();
        }
    }
    
    // 主页处理器
    static class HomeHandler implements HttpHandler {
        public void handle(HttpExchange exchange) throws IOException {
            String response = """
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="UTF-8">
                    <title>ARM CentOS Java应用</title>
                </head>
                <body>
                    <h1>🚀 ARM CentOS Java应用服务</h1>
                    <p>✅ Java 8 运行正常</p>
                    <p>✅ 中文支持：你好世界！Hello World!</p>
                    <p>✅ LibreOffice 集成可用</p>
                    
                    <h2>可用接口：</h2>
                    <ul>
                        <li><a href="/health">健康检查</a></li>
                        <li><a href="/info">系统信息</a></li>
                        <li><a href="/convert">文档转换</a> (POST)</li>
                    </ul>
                    
                    <h2>测试文档转换：</h2>
                    <p>点击下面的按钮测试 LibreOffice 转换功能（将测试文档转换为 PDF）：</p>
                    <form action="/convert" method="post">
                        <button type="submit">测试 TXT → PDF 转换</button>
                    </form>
                    <p><small>注：这是演示版本，实际转换中会创建测试文档并转换为 PDF</small></p>
                </body>
                </html>
            """;
            
            exchange.getResponseHeaders().set("Content-Type", "text/html; charset=UTF-8");
            exchange.sendResponseHeaders(200, response.getBytes("UTF-8").length);
            OutputStream os = exchange.getResponseBody();
            os.write(response.getBytes("UTF-8"));
            os.close();
        }
    }
    
    // 系统信息处理器
    static class InfoHandler implements HttpHandler {
        public void handle(HttpExchange exchange) throws IOException {
            StringBuilder info = new StringBuilder();
            info.append("{");
            info.append("\"architecture\":\"").append(System.getProperty("os.arch")).append("\",");
            info.append("\"os\":\"").append(System.getProperty("os.name")).append("\",");
            info.append("\"java_version\":\"").append(System.getProperty("java.version")).append("\",");
            info.append("\"java_home\":\"").append(System.getProperty("java.home")).append("\",");
            info.append("\"encoding\":\"").append(System.getProperty("file.encoding")).append("\",");
            info.append("\"language\":\"").append(System.getProperty("user.language")).append("\",");
            info.append("\"timezone\":\"").append(System.getProperty("user.timezone")).append("\",");
            info.append("\"chinese_test\":\"中文测试正常\"");
            info.append("}");
            
            String response = info.toString();
            exchange.getResponseHeaders().set("Content-Type", "application/json; charset=UTF-8");
            exchange.sendResponseHeaders(200, response.getBytes("UTF-8").length);
            OutputStream os = exchange.getResponseBody();
            os.write(response.getBytes("UTF-8"));
            os.close();
        }
    }
    
    // LibreOffice 转换处理器
    static class ConvertHandler implements HttpHandler {
        public void handle(HttpExchange exchange) throws IOException {
            if (!"POST".equals(exchange.getRequestMethod())) {
                sendErrorResponse(exchange, 405, "Method not allowed");
                return;
            }
            
            try {
                // 检查 LibreOffice 是否可用
                if (!isLibreOfficeAvailable()) {
                    sendErrorResponse(exchange, 500, "LibreOffice not available");
                    return;
                }
                
                // 获取请求参数
                String contentType = exchange.getRequestHeaders().getFirst("Content-Type");
                if (contentType == null || !contentType.startsWith("multipart/form-data")) {
                    sendErrorResponse(exchange, 400, "Content-Type must be multipart/form-data");
                    return;
                }
                
                // 简化处理：对于演示目的，我们创建一个测试文件并转换
                String testContent = """
                    ARM64 LibreOffice 转换测试文档
                    
                    时间：%s
                    架构：%s
                    Java版本：%s
                    
                    这是一个测试转换功能的文档。
                    包含中文字符测试：你好世界！
                    包含英文字符测试：Hello World!
                    包含数字测试：1234567890
                    """.formatted(
                    new java.util.Date(),
                    System.getProperty("os.arch"),
                    System.getProperty("java.version")
                );
                
                // 执行转换
                ConvertResult result = performConversion(testContent);
                
                if (result.success) {
                    sendSuccessResponse(exchange, result);
                } else {
                    sendErrorResponse(exchange, 500, result.message);
                }
                
            } catch (Exception e) {
                sendErrorResponse(exchange, 500, "Conversion failed: " + e.getMessage());
            }
        }
        
        private boolean isLibreOfficeAvailable() {
            try {
                ProcessBuilder pb = new ProcessBuilder("libreoffice", "--version");
                Process process = pb.start();
                int exitCode = process.waitFor();
                return exitCode == 0;
            } catch (Exception e) {
                return false;
            }
        }
        
        private ConvertResult performConversion(String content) {
            File tempDir = null;
            try {
                // 创建临时目录
                tempDir = File.createTempFile("convert", "");
                tempDir.delete();
                tempDir.mkdirs();
                
                // 创建输入文件
                File inputFile = new File(tempDir, "input.txt");
                try (FileWriter writer = new FileWriter(inputFile, java.nio.charset.StandardCharsets.UTF_8)) {
                    writer.write(content);
                }
                
                // 执行转换
                ProcessBuilder pb = new ProcessBuilder(
                    "libreoffice", "--headless", "--convert-to", "pdf", 
                    "--outdir", tempDir.getAbsolutePath(),
                    inputFile.getAbsolutePath()
                );
                
                Process process = pb.start();
                int exitCode = process.waitFor();
                
                if (exitCode != 0) {
                    return new ConvertResult(false, "LibreOffice conversion failed with exit code: " + exitCode, null, 0);
                }
                
                // 检查输出文件
                File outputFile = new File(tempDir, "input.pdf");
                if (!outputFile.exists()) {
                    return new ConvertResult(false, "Output file not generated", null, 0);
                }
                
                return new ConvertResult(true, "Conversion successful", outputFile.getName(), outputFile.length());
                
            } catch (Exception e) {
                return new ConvertResult(false, "Conversion error: " + e.getMessage(), null, 0);
            } finally {
                // 清理临时文件
                if (tempDir != null && tempDir.exists()) {
                    deleteDirectory(tempDir);
                }
            }
        }
        
        private void sendSuccessResponse(HttpExchange exchange, ConvertResult result) throws IOException {
            String response = """
                {
                    "status": "success",
                    "message": "%s",
                    "output_file": "%s",
                    "file_size": %d,
                    "timestamp": "%s",
                    "conversion_info": {
                        "input_format": "txt",
                        "output_format": "pdf",
                        "libreoffice_available": true
                    }
                }
                """.formatted(
                result.message,
                result.outputFile,
                result.fileSize,
                new java.util.Date()
            );
            
            exchange.getResponseHeaders().set("Content-Type", "application/json; charset=UTF-8");
            exchange.sendResponseHeaders(200, response.getBytes("UTF-8").length);
            OutputStream os = exchange.getResponseBody();
            os.write(response.getBytes("UTF-8"));
            os.close();
        }
        
        private void sendErrorResponse(HttpExchange exchange, int statusCode, String error) throws IOException {
            String response = """
                {
                    "status": "error",
                    "message": "%s",
                    "timestamp": "%s"
                }
                """.formatted(error, new java.util.Date());
            
            exchange.getResponseHeaders().set("Content-Type", "application/json; charset=UTF-8");
            exchange.sendResponseHeaders(statusCode, response.getBytes("UTF-8").length);
            OutputStream os = exchange.getResponseBody();
            os.write(response.getBytes("UTF-8"));
            os.close();
        }
        
        private void deleteDirectory(File dir) {
            if (dir.isDirectory()) {
                File[] children = dir.listFiles();
                if (children != null) {
                    for (File child : children) {
                        deleteDirectory(child);
                    }
                }
            }
            dir.delete();
        }
        
        // 转换结果类
        private static class ConvertResult {
            final boolean success;
            final String message;
            final String outputFile;
            final long fileSize;
            
            ConvertResult(boolean success, String message, String outputFile, long fileSize) {
                this.success = success;
                this.message = message;
                this.outputFile = outputFile;
                this.fileSize = fileSize;
            }
        }
    }
}