package com.yourblog.model;

import java.sql.Timestamp;

public class Message {
    private int id;
    private int userId;           // 接收消息的用户ID
    private String type;          // 消息类型：like, coin, comment
    private String content;       // 消息内容
    private int sourceUserId;     // 触发消息的用户ID
    private int postId;           // 相关的文章ID
    private int commentId;        // 相关的评论ID（如果是评论消息）
    private boolean isRead;       // 是否已读
    private Timestamp createdAt;  // 创建时间
    
    // 关联的用户信息（用于显示）
    private String sourceUsername;
    private String sourceDisplayName;
    private String sourceAvatarUrl;
    private String postTitle;
    
    // 构造方法
    public Message() {}
    
    public Message(int userId, String type, String content, int sourceUserId, int postId) {
        this.userId = userId;
        this.type = type;
        this.content = content;
        this.sourceUserId = sourceUserId;
        this.postId = postId;
        this.isRead = false;
    }
    
    // getter 和 setter 方法
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    
    public int getSourceUserId() { return sourceUserId; }
    public void setSourceUserId(int sourceUserId) { this.sourceUserId = sourceUserId; }
    
    public int getPostId() { return postId; }
    public void setPostId(int postId) { this.postId = postId; }
    
    public int getCommentId() { return commentId; }
    public void setCommentId(int commentId) { this.commentId = commentId; }
    
    public boolean getIsRead() { return isRead; }
    public void setIsRead(boolean isRead) { this.isRead = isRead; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public String getSourceUsername() { return sourceUsername; }
    public void setSourceUsername(String sourceUsername) { this.sourceUsername = sourceUsername; }
    
    public String getSourceDisplayName() { return sourceDisplayName; }
    public void setSourceDisplayName(String sourceDisplayName) { this.sourceDisplayName = sourceDisplayName; }
    
    public String getSourceAvatarUrl() { return sourceAvatarUrl; }
    public void setSourceAvatarUrl(String sourceAvatarUrl) { this.sourceAvatarUrl = sourceAvatarUrl; }
    
    public String getPostTitle() { return postTitle; }
    public void setPostTitle(String postTitle) { this.postTitle = postTitle; }
}