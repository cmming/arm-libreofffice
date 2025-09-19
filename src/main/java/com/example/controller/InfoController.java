package com.example.controller;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@RestController
public class InfoController {

    @GetMapping(value = "/health", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "OK");
        response.put("timestamp", new Date());
        return ResponseEntity.ok(response);
    }

    @GetMapping(value = "/info", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Map<String, Object>> info() {
        Map<String, Object> info = new HashMap<>();
        info.put("architecture", System.getProperty("os.arch"));
        info.put("os", System.getProperty("os.name"));
        info.put("java_version", System.getProperty("java.version"));
        info.put("java_home", System.getProperty("java.home"));
        info.put("encoding", System.getProperty("file.encoding"));
        info.put("language", System.getProperty("user.language"));
        info.put("timezone", System.getProperty("user.timezone"));
        info.put("chinese_test", "中文测试正常");
        
        return ResponseEntity.ok(info);
    }
}