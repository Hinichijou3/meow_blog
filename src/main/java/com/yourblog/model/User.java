package com.yourblog.model;

import java.util.Date;

public class User {
    private int id;
    private String username;
    private String email;
    private String passwordHash;
    private String displayName;
    private String avatarUrl;
    private String headerImageUrl;  // 新增：头图URL
    private String bio;
    private Date createdAt;
    private Date updatedAt;
    private int coins;                    // 当前硬币数
    private int totalCoinsEarned;        // 累计获得硬币数
    private Date lastLoginDate;          // 最后登录日期

    // 构造器
    public User() {}

    // Getter和Setter方法
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getDisplayName() { return displayName; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }

    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }

    public String getHeaderImageUrl() { return headerImageUrl; }  // 新增
    public void setHeaderImageUrl(String headerImageUrl) { this.headerImageUrl = headerImageUrl; }  // 新增

    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }
    
    public int getCoins() { return coins; }
    public void setCoins(int coins) { this.coins = coins; }
    
    public int getTotalCoinsEarned() { return totalCoinsEarned; }
    public void setTotalCoinsEarned(int totalCoinsEarned) { this.totalCoinsEarned = totalCoinsEarned; }
    
    public Date getLastLoginDate() { return lastLoginDate; }
    public void setLastLoginDate(Date lastLoginDate) { this.lastLoginDate = lastLoginDate; }
}