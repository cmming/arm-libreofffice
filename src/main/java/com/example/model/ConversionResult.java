package com.example.model;

public class ConversionResult {
    private final boolean success;
    private final String message;
    private final String outputFile;
    private final long fileSize;
    private final String fileId;

    public ConversionResult(boolean success, String message, String outputFile, long fileSize, String fileId) {
        this.success = success;
        this.message = message;
        this.outputFile = outputFile;
        this.fileSize = fileSize;
        this.fileId = fileId;
    }

    public boolean isSuccess() {
        return success;
    }

    public String getMessage() {
        return message;
    }

    public String getOutputFile() {
        return outputFile;
    }

    public long getFileSize() {
        return fileSize;
    }

    public String getFileId() {
        return fileId;
    }
}