package com.yourblog.model;

import java.sql.Timestamp;

public class Ad {
    private int id;
    private int userId;
    private String title;
    private String imageUrl;
    private String targetUrl;
    private String adType;
    private int price;
    private String status;
    private int views;
    private int clicks;
    private Timestamp startDate;
    private Timestamp endDate;
    private Timestamp createdAt;
    
    // 构造函数
    public Ad() {}
    
    // Getter和Setter方法
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    
    public String getTargetUrl() { return targetUrl; }
    public void setTargetUrl(String targetUrl) { this.targetUrl = targetUrl; }
    
    public String getAdType() { return adType; }
    public void setAdType(String adType) { this.adType = adType; }
    
    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public int getViews() { return views; }
    public void setViews(int views) { this.views = views; }
    
    public int getClicks() { return clicks; }
    public void setClicks(int clicks) { this.clicks = clicks; }
    
    public Timestamp getStartDate() { return startDate; }
    public void setStartDate(Timestamp startDate) { this.startDate = startDate; }
    
    public Timestamp getEndDate() { return endDate; }
    public void setEndDate(Timestamp endDate) { this.endDate = endDate; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}