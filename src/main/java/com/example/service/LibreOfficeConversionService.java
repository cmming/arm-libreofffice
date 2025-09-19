package com.example.service;

import com.example.model.ConversionResult;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.io.*;
import java.nio.file.Files;
import java.util.Date;

@Service
public class LibreOfficeConversionService {

    @Value("${app.conversion.download-dir:/tmp/conversions}")
    private String downloadDir;

    @Value("${app.conversion.file-retention-minutes:30}")
    private long fileRetentionMinutes;

    @Value("${app.conversion.temp-dir:/tmp/libreoffice-temp}")
    private String tempDir;

    @PostConstruct
    public void init() {
        // 创建必要的目录
        new File(downloadDir).mkdirs();
        new File(tempDir).mkdirs();
    }

    /**
     * 检查LibreOffice是否可用
     */
    public boolean isLibreOfficeAvailable() {
        try {
            ProcessBuilder pb = new ProcessBuilder("libreoffice", "--version");
            Process process = pb.start();
            int exitCode = process.waitFor();
            return exitCode == 0;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 执行文档转换
     */
    public ConversionResult convertDocument(String content) {
        File tempDirFile = null;
        try {
            // 创建临时目录用于转换
            tempDirFile = File.createTempFile("convert", "");
            tempDirFile.delete();
            tempDirFile.mkdirs();

            // 创建输入文件
            File inputFile = new File(tempDirFile, "input.txt");
            try (FileWriter writer = new FileWriter(inputFile, java.nio.charset.StandardCharsets.UTF_8)) {
                writer.write(content);
            }

            // 执行转换
            ProcessBuilder pb = new ProcessBuilder(
                    "libreoffice", "--headless", "--convert-to", "pdf",
                    "--outdir", tempDirFile.getAbsolutePath(),
                    inputFile.getAbsolutePath()
            );

            Process process = pb.start();
            int exitCode = process.waitFor();

            if (exitCode != 0) {
                return new ConversionResult(false, "LibreOffice conversion failed with exit code: " + exitCode, null, 0, null);
            }

            // 检查输出文件
            File outputFile = new File(tempDirFile, "input.pdf");
            if (!outputFile.exists()) {
                return new ConversionResult(false, "Output file not generated", null, 0, null);
            }

            // 生成唯一文件ID并保存到下载目录
            String fileId = "conv_" + System.currentTimeMillis() + "_" + (int)(Math.random() * 10000);
            String fileName = fileId + ".pdf";
            File savedFile = new File(downloadDir, fileName);

            // 复制文件到下载目录
            Files.copy(outputFile.toPath(), savedFile.toPath());

            return new ConversionResult(true, "Conversion successful", fileName, savedFile.length(), fileId);

        } catch (Exception e) {
            return new ConversionResult(false, "Conversion error: " + e.getMessage(), null, 0, null);
        } finally {
            // 清理临时文件
            if (tempDirFile != null && tempDirFile.exists()) {
                deleteDirectory(tempDirFile);
            }
        }
    }

    /**
     * 生成测试内容
     */
    public String generateTestContent() {
        return String.format("ARM64 Spring Boot LibreOffice 转换测试文档\n\n" +
                "时间：%s\n" +
                "架构：%s\n" +
                "Java版本：%s\n" +
                "框架：Spring Boot 2.7.18\n\n" +
                "这是一个测试转换功能的文档。\n" +
                "包含中文字符测试：你好世界！Spring Boot 很棒！\n" +
                "包含英文字符测试：Hello World! Spring Boot is awesome!\n" +
                "包含数字测试：1234567890\n\n" +
                "功能特性：\n" +
                "- ARM64 架构支持\n" +
                "- 中文字符完美支持\n" +
                "- Spring Boot 集成\n" +
                "- LibreOffice 自动转换\n" +
                "- RESTful API 设计\n" +
                "- Docker 容器化部署\n",
                new Date(),
                System.getProperty("os.arch"),
                System.getProperty("java.version")
        );
    }

    /**
     * 获取文件保留时间（毫秒）
     */
    public long getFileRetentionMs() {
        return fileRetentionMinutes * 60 * 1000;
    }

    /**
     * 递归删除目录
     */
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
}