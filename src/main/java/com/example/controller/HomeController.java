package com.example.controller;

import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class HomeController {

    @GetMapping(value = "/", produces = MediaType.TEXT_HTML_VALUE)
    @ResponseBody
    public String home() {
        return "<!DOCTYPE html>\n" +
                "<html>\n" +
                "<head>\n" +
                "    <meta charset=\"UTF-8\">\n" +
                "    <title>ARM Spring Boot LibreOffice应用</title>\n" +
                "    <style>\n" +
                "        body { font-family: Arial, sans-serif; margin: 40px; }\n" +
                "        h1 { color: #2e7d32; }\n" +
                "        h2 { color: #1976d2; }\n" +
                "        .status { color: #388e3c; font-weight: bold; }\n" +
                "        .endpoint { margin: 5px 0; }\n" +
                "        .endpoint a { text-decoration: none; color: #1976d2; }\n" +
                "        .endpoint a:hover { text-decoration: underline; }\n" +
                "        form { margin: 20px 0; }\n" +
                "        button { background-color: #2e7d32; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; }\n" +
                "        button:hover { background-color: #1b5e20; }\n" +
                "        ol { line-height: 1.6; }\n" +
                "    </style>\n" +
                "</head>\n" +
                "<body>\n" +
                "    <h1>🚀 ARM Spring Boot LibreOffice应用服务</h1>\n" +
                "    <p class=\"status\">✅ Spring Boot 运行正常</p>\n" +
                "    <p class=\"status\">✅ 中文支持：你好世界！Hello World!</p>\n" +
                "    <p class=\"status\">✅ LibreOffice 集成可用</p>\n" +
                "    \n" +
                "    <h2>可用接口：</h2>\n" +
                "    <ul>\n" +
                "        <li class=\"endpoint\"><a href=\"/health\">健康检查</a></li>\n" +
                "        <li class=\"endpoint\"><a href=\"/info\">系统信息</a></li>\n" +
                "        <li class=\"endpoint\"><a href=\"/actuator/health\">Spring Boot Actuator 健康检查</a></li>\n" +
                "        <li class=\"endpoint\">/convert (POST) - 文档转换</li>\n" +
                "        <li class=\"endpoint\">/download?file=example - 文件下载 (需要文件ID)</li>\n" +
                "    </ul>\n" +
                "    \n" +
                "    <h2>测试文档转换：</h2>\n" +
                "    <p>点击下面的按钮测试 LibreOffice 转换功能（将测试文档转换为 PDF）：</p>\n" +
                "    <form action=\"/convert\" method=\"post\">\n" +
                "        <button type=\"submit\">测试 TXT → PDF 转换</button>\n" +
                "    </form>\n" +
                "    <p><small>转换成功后，响应中会包含下载链接，文件保留30分钟</small></p>\n" +
                "    \n" +
                "    <h3>使用说明：</h3>\n" +
                "    <ol>\n" +
                "        <li>点击 \"测试 TXT → PDF 转换\" 按钮</li>\n" +
                "        <li>从响应的JSON中复制 download_url</li>\n" +
                "        <li>访问下载链接获取转换后的PDF文件</li>\n" +
                "        <li>文件将在30分钟后自动删除</li>\n" +
                "    </ol>\n" +
                "    \n" +
                "    <h3>技术栈：</h3>\n" +
                "    <ul>\n" +
                "        <li>Spring Boot 2.7.18</li>\n" +
                "        <li>Spring MVC</li>\n" +
                "        <li>Java 8</li>\n" +
                "        <li>LibreOffice</li>\n" +
                "        <li>ARM64 架构支持</li>\n" +
                "    </ul>\n" +
                "</body>\n" +
                "</html>";
    }
}