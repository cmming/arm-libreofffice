package com.example.controller;

import com.example.service.LibreOfficeConversionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.File;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@RestController
public class DownloadController {

    @Autowired
    private LibreOfficeConversionService conversionService;

    @Value("${app.conversion.download-dir:/tmp/conversions}")
    private String downloadDir;

    @GetMapping("/download")
    public ResponseEntity<?> download(@RequestParam("file") String fileId) {
        try {
            // 安全检查：只允许字母数字和下划线
            if (!fileId.matches("^[a-zA-Z0-9_]+$")) {
                return ResponseEntity.badRequest()
                        .contentType(MediaType.APPLICATION_JSON)
                        .body(createErrorResponse("Invalid file ID"));
            }

            // 查找匹配的文件
            File downloadDirFile = new File(downloadDir);
            File[] files = downloadDirFile.listFiles((dir, name) ->
                    name.startsWith(fileId + ".") && name.endsWith(".pdf"));

            if (files == null || files.length == 0) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .contentType(MediaType.APPLICATION_JSON)
                        .body(createErrorResponse("File not found or expired"));
            }

            File file = files[0];

            // 检查文件是否过期
            long fileAge = System.currentTimeMillis() - file.lastModified();
            if (fileAge > conversionService.getFileRetentionMs()) {
                file.delete(); // 删除过期文件
                return ResponseEntity.status(HttpStatus.GONE)
                        .contentType(MediaType.APPLICATION_JSON)
                        .body(createErrorResponse("File has expired"));
            }

            // 发送文件
            Resource resource = new FileSystemResource(file);
            
            return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_PDF)
                    .header(HttpHeaders.CONTENT_DISPOSITION, 
                           "attachment; filename=\"converted_document.pdf\"")
                    .body(resource);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(createErrorResponse("Error reading file: " + e.getMessage()));
        }
    }

    private Map<String, Object> createErrorResponse(String error) {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "error");
        response.put("message", error);
        response.put("timestamp", new Date());
        return response;
    }
}