package com.yourblog.dao;

import com.yourblog.model.Post;
import com.yourblog.model.Tag;
import com.yourblog.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PostDAO {
    
	public List<Post> getAllPublishedPostsWithUsers() {
	    List<Post> posts = new ArrayList<>();
	    String sql = "SELECT p.*, u.username, u.display_name, u.avatar_url " +
	                "FROM posts p JOIN users u ON p.user_id = u.id " +
	                "WHERE p.status = 'published' " +
	                "ORDER BY p.created_at DESC";
	    
	    System.out.println("=== 开始获取文章列表 ===");
	    System.out.println("SQL: " + sql);
	    
	    try (Connection conn = DatabaseUtil.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(sql);
	         ResultSet rs = stmt.executeQuery()) {
	        
	        System.out.println("✅ 数据库查询执行成功");
	        
	        int count = 0;
	        while (rs.next()) {
	            count++;
	            System.out.println("处理第 " + count + " 篇文章:");
	            System.out.println("  - ID: " + rs.getInt("id"));
	            System.out.println("  - 标题: " + rs.getString("title"));
	            System.out.println("  - 状态: " + rs.getString("status"));
	            System.out.println("  - 用户ID: " + rs.getInt("user_id"));
	            
	            Post post = extractPostFromResultSet(rs);
	            post.setAuthor(rs.getString("display_name"));
	            
	            // 获取评论数
	            int commentCount = getCommentCountByPostId(post.getId());
	            post.setCommentCount(commentCount);
	            
	            posts.add(post);
	        }
	        
	        System.out.println("✅ 总共获取到 " + count + " 篇文章");
	        
	    } catch (SQLException e) {
	        System.err.println("❌ 获取文章列表失败: " + e.getMessage());
	        e.printStackTrace();
	    }
	    
	    System.out.println("=== 文章列表获取完成 ===");
	    return posts;
	}
	
    public List<Post> getPostsByUserId(int userId) {
        List<Post> posts = new ArrayList<>();
        String sql = "SELECT p.*, u.username, u.display_name " +
                    "FROM posts p JOIN users u ON p.user_id = u.id " +
                    "WHERE p.user_id = ? AND p.status = 'published' " +
                    "ORDER BY p.created_at DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Post post = extractPostFromResultSet(rs);
                post.setAuthor(rs.getString("display_name"));
                posts.add(post);
            }
        } catch (SQLException e) {
            System.err.println("获取用户文章失败: " + e.getMessage());
            e.printStackTrace();
        }
        return posts;
    }
    
    /**
     * 根据文章ID获取单篇文章
     */
    public Post getPostById(int postId) {
        Post post = null;
        String sql = "SELECT p.*, u.username, u.display_name, u.avatar_url " +
                    "FROM posts p JOIN users u ON p.user_id = u.id " +
                    "WHERE p.id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, postId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                post = extractPostFromResultSet(rs);
                post.setAuthor(rs.getString("display_name"));
            }
        } catch (SQLException e) {
            System.err.println("获取文章详情失败: " + e.getMessage());
            e.printStackTrace();
        }
        return post;
    }
    
    /**
     * 创建新文章
     */
    public boolean createPost(Post post) {
        String sql = "INSERT INTO posts (title, content, excerpt, user_id, status) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, post.getTitle());
            stmt.setString(2, post.getContent());
            stmt.setString(3, post.getExcerpt());
            stmt.setInt(4, post.getUserId());
            stmt.setString(5, post.getStatus());
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                // 获取生成的文章ID
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    post.setId(generatedKeys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            System.err.println("创建文章失败: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * 更新文章
     */
    public boolean updatePost(Post post) {
        String sql = "UPDATE posts SET title = ?, content = ?, excerpt = ?, status = ? WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, post.getTitle());
            stmt.setString(2, post.getContent());
            stmt.setString(3, post.getExcerpt());
            stmt.setString(4, post.getStatus());
            stmt.setInt(5, post.getId());
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("更新文章失败: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    

    /**
     * 删除文章
     */
    public boolean deletePost(int postId) {
        System.out.println("执行数据库删除，文章ID: " + postId);
        
        String sql = "DELETE FROM posts WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, postId);
            int affectedRows = stmt.executeUpdate();
            
            System.out.println("数据库影响行数: " + affectedRows);
            
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("数据库删除失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 增加文章阅读量
     */
    public boolean incrementViewCount(int postId) {
        System.out.println("增加文章阅读量，ID: " + postId);
        
        String sql = "UPDATE posts SET view_count = view_count + 1 WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, postId);
            int affectedRows = stmt.executeUpdate();
            
            System.out.println("阅读量更新影响行数: " + affectedRows);
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("增加阅读量失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 从ResultSet中提取文章信息的通用方法
     */
    private Post extractPostFromResultSet(ResultSet rs) throws SQLException {
        Post post = new Post();
        try {
            post.setId(rs.getInt("id"));
            post.setTitle(rs.getString("title"));
            post.setContent(rs.getString("content"));
            post.setExcerpt(rs.getString("excerpt"));
            post.setAuthor(rs.getString("author"));
            post.setUserId(rs.getInt("user_id"));
            post.setCreatedAt(rs.getTimestamp("created_at"));
            post.setUpdatedAt(rs.getTimestamp("updated_at"));
            post.setViewCount(rs.getInt("view_count"));
            post.setStatus(rs.getString("status"));
            
            // 尝试获取comment_count字段，如果不存在则使用默认值0
            try {
                post.setCommentCount(rs.getInt("comment_count"));
            } catch (SQLException e) {
                System.out.println("⚠️ comment_count字段不存在，使用默认值0");
                post.setCommentCount(0);
            }
            
        } catch (SQLException e) {
            System.err.println("❌ 提取文章信息失败: " + e.getMessage());
            throw e;
        }
        return post;
    }
    
    /**
     * 兼容旧代码的方法 - 获取所有已发布文章（不包含用户信息）
     */
    public List<Post> getAllPublishedPosts() {
        // 直接调用新方法，保持兼容性
        return getAllPublishedPostsWithUsers();
    }
    
    //更新文章状态
    public boolean updatePostStatus(int postId, String status) {
        String sql = "UPDATE posts SET status = ? WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, status);
            stmt.setInt(2, postId);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("更新文章状态失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 获取文章的评论数量
     */
    public int getCommentCountByPostId(int postId) {
        String sql = "SELECT comment_count FROM posts WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, postId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("comment_count");
            }
        } catch (SQLException e) {
            System.err.println("获取评论数量失败: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
    
    /**
     * 搜索文章（标题、内容、标签）
     */
    public List<Post> searchPosts(String keyword) {
        List<Post> posts = new ArrayList<>();
        String sql = "SELECT DISTINCT p.*, u.username, u.display_name, u.avatar_url " +
                    "FROM posts p " +
                    "JOIN users u ON p.user_id = u.id " +
                    "LEFT JOIN post_tags pt ON p.id = pt.post_id " +
                    "LEFT JOIN tags t ON pt.tag_id = t.id " +
                    "WHERE p.status = 'published' " +
                    "AND (p.title LIKE ? OR p.content LIKE ? OR p.excerpt LIKE ? OR t.name LIKE ?) " +
                    "ORDER BY p.created_at DESC";
        
        System.out.println("=== 搜索文章 ===");
        System.out.println("关键词: " + keyword);
        System.out.println("SQL: " + sql);
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            stmt.setString(1, searchPattern);
            stmt.setString(2, searchPattern);
            stmt.setString(3, searchPattern);
            stmt.setString(4, searchPattern);
            
            ResultSet rs = stmt.executeQuery();
            
            int count = 0;
            while (rs.next()) {
                count++;
                Post post = extractPostFromResultSet(rs);
                post.setAuthor(rs.getString("display_name"));
                
                // 获取文章的标签
                List<String> tags = getTagsByPostId(post.getId());
                post.setTags(tags);
                
                posts.add(post);
            }
            
            System.out.println("✅ 搜索到 " + count + " 篇文章");
            
        } catch (SQLException e) {
            System.err.println("❌ 搜索文章失败: " + e.getMessage());
            e.printStackTrace();
        }
        
        return posts;
    }
    
    /**
     * 根据标签搜索文章
     */
    public List<Post> searchPostsByTag(String tagName) {
        List<Post> posts = new ArrayList<>();
        String sql = "SELECT p.*, u.username, u.display_name, u.avatar_url " +
                    "FROM posts p " +
                    "JOIN users u ON p.user_id = u.id " +
                    "JOIN post_tags pt ON p.id = pt.post_id " +
                    "JOIN tags t ON pt.tag_id = t.id " +
                    "WHERE t.name = ? AND p.status = 'published' " +
                    "ORDER BY p.created_at DESC";
        
        System.out.println("=== 根据标签搜索文章 ===");
        System.out.println("标签: " + tagName);
        
        try (Connection conn = DatabaseUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
               
               stmt.setString(1, tagName);
               ResultSet rs = stmt.executeQuery();
               
               int count = 0;
               while (rs.next()) {
                   count++;
                   Post post = extractPostFromResultSet(rs);
                   post.setAuthor(rs.getString("display_name"));
                   
                   // 获取文章的标签
                   List<String> tags = getTagsByPostId(post.getId());
                   post.setTags(tags);
                   
                   posts.add(post);
               }
               
               System.out.println("✅ 找到 " + count + " 篇带有标签 '" + tagName + "' 的文章");
               
           } catch (SQLException e) {
               System.err.println("❌ 根据标签搜索失败: " + e.getMessage());
               e.printStackTrace();
           }
           
           return posts;
       }
    /**
     * 获取热门标签
     */
    public List<String> getPopularTags(int limit) {
        List<String> tags = new ArrayList<>();
        String sql = "SELECT t.name, COUNT(pt.post_id) as count " +
                    "FROM tags t " +
                    "JOIN post_tags pt ON t.id = pt.tag_id " +
                    "GROUP BY t.id, t.name " +
                    "ORDER BY count DESC " +
                    "LIMIT ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
        	
        	stmt.setInt(1, limit);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                tags.add(rs.getString("name"));
            }
            
        } catch (SQLException e) {
            System.err.println("❌ 获取热门标签失败: " + e.getMessage());
            e.printStackTrace();
        }
        
        return tags;
    }
    
    /**
     * 获取文章的标签列表
     */
    public List<String> getTagsByPostId(int postId) {
        List<String> tags = new ArrayList<>();
        String sql = "SELECT t.name FROM tags t " +
                    "JOIN post_tags pt ON t.id = pt.tag_id " +
                    "WHERE pt.post_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, postId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                tags.add(rs.getString("name"));
            }
            
        } catch (SQLException e) {
            System.err.println("❌ 获取文章标签失败: " + e.getMessage());
            e.printStackTrace();
        }
        
        return tags;
    }
}