// Tag.java
package com.yourblog.model;

import java.util.Date;

public class Tag {
    private int id;
    private String name;
    private Date createdAt;
    private int postCount; // 使用该标签的文章数量

    // 构造器、Getter 和 Setter
    public Tag() {}
    
    public Tag(int id, String name) {
        this.id = id;
        this.name = name;
    }

    // Getter 和 Setter 方法...
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    
    public int getPostCount() { return postCount; }
    public void setPostCount(int postCount) { this.postCount = postCount; }
}