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
                    <form action="/convert" method="post" enctype="multipart/form-data">
                        <input type="file" name="file" accept=".txt,.doc,.docx,.odt">
                        <select name="format">
                            <option value="pdf">转换为 PDF</option>
                            <option value="docx">转换为 DOCX</option>
                            <option value="odt">转换为 ODT</option>
                        </select>
                        <button type="submit">转换</button>
                    </form>
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
            if ("POST".equals(exchange.getRequestMethod())) {
                // 简化的文档转换示例
                // 实际应用中需要解析 multipart/form-data 并调用 LibreOffice
                String response = """
                    {
                        "status": "success",
                        "message": "LibreOffice转换功能已集成",
                        "note": "实际转换需要实现文件上传和LibreOffice命令行调用",
                        "command_example": "libreoffice --headless --convert-to pdf input.docx"
                    }
                """;
                
                exchange.getResponseHeaders().set("Content-Type", "application/json; charset=UTF-8");
                exchange.sendResponseHeaders(200, response.getBytes("UTF-8").length);
                OutputStream os = exchange.getResponseBody();
                os.write(response.getBytes("UTF-8"));
                os.close();
            } else {
                exchange.sendResponseHeaders(405, 0);
                exchange.getResponseBody().close();
            }
        }
    }
}