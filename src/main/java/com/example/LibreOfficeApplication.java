package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;

@SpringBootApplication
public class LibreOfficeApplication {

    public static void main(String[] args) {
        SpringApplication.run(LibreOfficeApplication.class, args);
    }

    @EventListener(ApplicationReadyEvent.class)
    public void onApplicationReady() {
        System.out.println("🚀 Spring Boot LibreOffice 转换服务启动成功！");
        System.out.println("架构: " + System.getProperty("os.arch"));
        System.out.println("Java版本: " + System.getProperty("java.version"));
        System.out.println("语言环境: " + System.getProperty("user.language"));
        System.out.println("字符编码: " + System.getProperty("file.encoding"));
    }
}