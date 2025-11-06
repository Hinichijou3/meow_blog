package com.yourblog.dao;

import com.yourblog.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TagDAO {
    
    /**
     * 为文章添加标签
     */
    public boolean addTagsToPost(int postId, List<String> tagNames) {
        System.out.println("=== 为文章添加标签 ===");
        System.out.println("文章ID: " + postId);
        System.out.println("标签: " + tagNames);
        
        String checkTagSql = "SELECT id FROM tags WHERE name = ?";
        String insertTagSql = "INSERT INTO tags (name) VALUES (?)";
        String insertPostTagSql = "INSERT INTO post_tags (post_id, tag_id) VALUES (?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection()) {
            conn.setAutoCommit(false);
            
            try (PreparedStatement checkTagStmt = conn.prepareStatement(checkTagSql);
                 PreparedStatement insertTagStmt = conn.prepareStatement(insertTagSql, Statement.RETURN_GENERATED_KEYS);
                 PreparedStatement insertPostTagStmt = conn.prepareStatement(insertPostTagSql)) {
                
                for (String tagName : tagNames) {
                    if (tagName == null || tagName.trim().isEmpty()) {
                        continue;
                    }
                    
                    tagName = tagName.trim();
                    int tagId;
                    
                    // 检查标签是否已存在
                    checkTagStmt.setString(1, tagName);
                    ResultSet rs = checkTagStmt.executeQuery();
                    
                    if (rs.next()) {
                        // 标签已存在，获取其ID
                        tagId = rs.getInt("id");
                    } else {
                        // 标签不存在，创建新标签
                        insertTagStmt.setString(1, tagName);
                        int affectedRows = insertTagStmt.executeUpdate();
                        
                        if (affectedRows > 0) {
                            ResultSet generatedKeys = insertTagStmt.getGeneratedKeys();
                            if (generatedKeys.next()) {
                                tagId = generatedKeys.getInt(1);
                            } else {
                                throw new SQLException("创建标签失败，无法获取ID");
                            }
                        } else {
                            throw new SQLException("创建标签失败");
                        }
                    }
                    
                    // 关联文章和标签
                    insertPostTagStmt.setInt(1, postId);
                    insertPostTagStmt.setInt(2, tagId);
                    insertPostTagStmt.executeUpdate();
                }
                
                conn.commit();
                System.out.println("✅ 标签添加成功");
                return true;
                
            } catch (SQLException e) {
                conn.rollback();
                System.err.println("❌ 添加标签失败: " + e.getMessage());
                e.printStackTrace();
                return false;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ 数据库连接失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 删除文章的某个标签
     */
    public boolean removeTagFromPost(int postId, String tagName) {
        String sql = "DELETE pt FROM post_tags pt " +
                    "JOIN tags t ON pt.tag_id = t.id " +
                    "WHERE pt.post_id = ? AND t.name = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, postId);
            stmt.setString(2, tagName);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ 删除文章标签失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 更新文章的标签（先删除所有旧标签，再添加新标签）
     */
    public boolean updatePostTags(int postId, List<String> tagNames) {
        System.out.println("=== 更新文章标签 ===");
        System.out.println("文章ID: " + postId);
        System.out.println("新标签: " + tagNames);
        
        // 先删除文章的所有标签
        if (!clearPostTags(postId)) {
            return false;
        }
        
        // 如果新标签列表为空，直接返回成功
        if (tagNames == null || tagNames.isEmpty()) {
            System.out.println("✅ 标签已清空");
            return true;
        }
        
        // 添加新标签
        return addTagsToPost(postId, tagNames);
    }
    
    /**
     * 清空文章的所有标签
     */
    public boolean clearPostTags(int postId) {
        String sql = "DELETE FROM post_tags WHERE post_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, postId);
            stmt.executeUpdate();
            return true;
            
        } catch (SQLException e) {
            System.err.println("❌ 清空文章标签失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 获取所有标签
     */
    public List<String> getAllTags() {
        List<String> tags = new ArrayList<>();
        String sql = "SELECT name FROM tags ORDER BY name";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                tags.add(rs.getString("name"));
            }
            
        } catch (SQLException e) {
            System.err.println("❌ 获取所有标签失败: " + e.getMessage());
            e.printStackTrace();
        }
        
        return tags;
    }
}