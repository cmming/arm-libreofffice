package com.example.controller;

import com.example.model.ConversionResult;
import com.example.service.LibreOfficeConversionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@RestController
public class ConversionController {

    @Autowired
    private LibreOfficeConversionService conversionService;

    @PostMapping(value = "/convert", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Map<String, Object>> convert() {
        try {
            // 检查 LibreOffice 是否可用
            if (!conversionService.isLibreOfficeAvailable()) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body(createErrorResponse("LibreOffice not available"));
            }

            // 生成测试内容并执行转换
            String testContent = conversionService.generateTestContent();
            ConversionResult result = conversionService.convertDocument(testContent);

            if (result.isSuccess()) {
                return ResponseEntity.ok(createSuccessResponse(result));
            } else {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body(createErrorResponse(result.getMessage()));
            }

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Conversion failed: " + e.getMessage()));
        }
    }

    private Map<String, Object> createSuccessResponse(ConversionResult result) {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "success");
        response.put("message", result.getMessage());
        response.put("output_file", result.getOutputFile());
        response.put("file_size", result.getFileSize());
        response.put("file_id", result.getFileId());
        response.put("download_url", "/download?file=" + result.getFileId());
        response.put("timestamp", new Date());

        Map<String, Object> conversionInfo = new HashMap<>();
        conversionInfo.put("input_format", "txt");
        conversionInfo.put("output_format", "pdf");
        conversionInfo.put("libreoffice_available", true);
        conversionInfo.put("retention_minutes", 30);
        conversionInfo.put("framework", "Spring Boot");
        
        response.put("conversion_info", conversionInfo);
        
        return response;
    }

    private Map<String, Object> createErrorResponse(String error) {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "error");
        response.put("message", error);
        response.put("timestamp", new Date());
        return response;
    }
}