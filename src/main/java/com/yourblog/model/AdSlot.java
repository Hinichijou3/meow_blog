package com.yourblog.model;

import java.sql.Timestamp;

public class AdSlot {
    private int id;
    private String name;
    private String description;
    private int width;
    private int height;
    private int maxDuration; // 最大持续时间（秒）
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // 构造函数
    public AdSlot() {}
    
    public AdSlot(String name, String description, int width, int height, int maxDuration) {
        this.name = name;
        this.description = description;
        this.width = width;
        this.height = height;
        this.maxDuration = maxDuration;
        this.status = "active";
    }
    
    // Getter 和 Setter 方法
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public int getWidth() { return width; }
    public void setWidth(int width) { this.width = width; }
    
    public int getHeight() { return height; }
    public void setHeight(int height) { this.height = height; }
    
    public int getMaxDuration() { return maxDuration; }
    public void setMaxDuration(int maxDuration) { this.maxDuration = maxDuration; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}