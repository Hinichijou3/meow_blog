package com.yourblog.model;

import java.util.Date;

public class Comment {
    private int id;
    private int postId;
    private int userId;
    private String content;
    private Date createdAt;
    private Date updatedAt;
    private String status;
    private int parentId;
    
    // 关联的用户信息（用于显示）
    private String username;
    private String displayName;
    private String avatarUrl;
    
    // 构造器
    public Comment() {}
    
    public Comment(int id, int postId, int userId, String content, Date createdAt, String status) {
        this.id = id;
        this.postId = postId;
        this.userId = userId;
        this.content = content;
        this.createdAt = createdAt;
        this.status = status;
    }

    // Getter和Setter方法
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getPostId() { return postId; }
    public void setPostId(int postId) { this.postId = postId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getParentId() { return parentId; }
    public void setParentId(int parentId) { this.parentId = parentId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getDisplayName() { return displayName; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }

    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }
}