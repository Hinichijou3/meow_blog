package com.yourblog.model;

import java.util.Date;

public class Post {
    private int id;
    private String title;
    private String content;
    private String excerpt;
    private String author;
    private int userId;  // 新增：关联用户ID
    private Date createdAt;
    private Date updatedAt;
    private int viewCount;
    private String status;
    private int commentCount;

    // 构造器
    public Post() {}

    public Post(int id, String title, String content, String excerpt, String author, 
                int userId, Date createdAt, Date updatedAt, int viewCount, String status) {
        this.id = id;
        this.title = title;
        this.content = content;
        this.excerpt = excerpt;
        this.author = author;
        this.userId = userId;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.viewCount = viewCount;
        this.status = status;
    }

    // Getter 和 Setter 方法
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getExcerpt() { return excerpt; }
    public void setExcerpt(String excerpt) { this.excerpt = excerpt; }

    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }

    public int getUserId() { return userId; }  // 新增
    public void setUserId(int userId) { this.userId = userId; }  // 新增

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }

    public int getViewCount() { return viewCount; }
    public void setViewCount(int viewCount) { this.viewCount = viewCount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public int getCommentCount() { return commentCount; }
    public void setCommentCount(int commentCount) { this.commentCount = commentCount; }
}