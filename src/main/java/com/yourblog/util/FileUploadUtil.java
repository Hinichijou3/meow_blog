package com.yourblog.util;

import jakarta.servlet.http.Part;
import java.io.*;
import java.nio.file.*;
import java.util.UUID;

public class FileUploadUtil {
    
    // 广告图片存储目录
    private static final String AD_IMAGE_DIR = "uploads/ad-images";
    
    /**
     * 保存上传的广告图片
     */
    public static String saveAdImage(Part imagePart, String realPath) throws IOException {
        // 确保上传目录存在
        String uploadDir = realPath + AD_IMAGE_DIR;
        Path uploadPath = Paths.get(uploadDir);
        
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }
        
        // 生成唯一的文件名
        String originalFileName = getFileName(imagePart);
        String fileExtension = getFileExtension(originalFileName);
        String uniqueFileName = UUID.randomUUID().toString() + fileExtension;
        
        // 保存文件
        Path filePath = uploadPath.resolve(uniqueFileName);
        try (InputStream input = imagePart.getInputStream()) {
            Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
        }
        
        // 返回相对路径（用于Web访问）
        return AD_IMAGE_DIR + "/" + uniqueFileName;
    }
    
    /**
     * 获取文件名
     */
    private static String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        String[] tokens = contentDisposition.split(";");
        
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }
    
    /**
     * 获取文件扩展名
     */
    private static String getFileExtension(String fileName) {
        int lastDotIndex = fileName.lastIndexOf(".");
        if (lastDotIndex > 0) {
            return fileName.substring(lastDotIndex);
        }
        return ".jpg"; // 默认扩展名
    }
    
    /**
     * 验证图片文件类型
     */
    public static boolean isValidImageFile(String fileName) {
        String extension = getFileExtension(fileName).toLowerCase();
        return extension.equals(".jpg") || extension.equals(".jpeg") || 
               extension.equals(".png") || extension.equals(".gif") ||
               extension.equals(".webp");
    }
    
    /**
     * 验证图片大小（最大5MB）
     */
    public static boolean isValidImageSize(long size) {
        return size > 0 && size <= 5 * 1024 * 1024; // 5MB
    }
    
    /**
     * 删除广告图片文件
     */
    public static boolean deleteAdImage(String imagePath, String realPath) {
        if (imagePath == null || imagePath.isEmpty()) {
            return false;
        }
        
        try {
            // 确保路径正确（移除开头的斜杠如果存在）
            String cleanPath = imagePath.startsWith("/") ? imagePath.substring(1) : imagePath;
            Path filePath = Paths.get(realPath + cleanPath);
            
            System.out.println("尝试删除图片: " + filePath.toString());
            boolean deleted = Files.deleteIfExists(filePath);
            
            if (deleted) {
                System.out.println("图片删除成功: " + imagePath);
            } else {
                System.out.println("图片文件不存在: " + imagePath);
            }
            
            return deleted;
        } catch (IOException e) {
            System.err.println("删除图片文件失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}