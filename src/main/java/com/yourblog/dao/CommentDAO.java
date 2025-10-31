package com.yourblog.dao;

import com.yourblog.model.Comment;
import com.yourblog.model.*;
import com.yourblog.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CommentDAO {
    
    /**
     * 获取文章的所有评论（包含用户信息）
     */
    public List<Comment> getCommentsByPostId(int postId) {
        List<Comment> comments = new ArrayList<>();
        String sql = "SELECT c.*, u.username, u.display_name, u.avatar_url " +
                    "FROM comments c " +
                    "JOIN users u ON c.user_id = u.id " +
                    "WHERE c.post_id = ? AND c.status = 'approved' " +
                    "ORDER BY c.created_at ASC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, postId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Comment comment = extractCommentFromResultSet(rs);
                comments.add(comment);
            }
        } catch (SQLException e) {
            System.err.println("获取评论列表失败: " + e.getMessage());
            e.printStackTrace();
        }
        return comments;
    }
    
    /**
     * 获取文章的评论数量
     */
    public int getCommentCountByPostId(int postId) {
        String sql = "SELECT COUNT(*) as count FROM comments WHERE post_id = ? AND status = 'approved'";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, postId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException e) {
            System.err.println("获取评论数量失败: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
    
    /**
     * 添加新评论
     */
    public boolean addComment(Comment comment) {
        // 根据 parentId 是否为 0 来决定 SQL 语句
        String sql;
        if (comment.getParentId() > 0) {
            sql = "INSERT INTO comments (post_id, user_id, content, parent_id) VALUES (?, ?, ?, ?)";
        } else {
            sql = "INSERT INTO comments (post_id, user_id, content) VALUES (?, ?, ?)";
        }
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, comment.getPostId());
            stmt.setInt(2, comment.getUserId());
            stmt.setString(3, comment.getContent());
            
            if (comment.getParentId() > 0) {
                stmt.setInt(4, comment.getParentId());
            }
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                // 获取生成的评论ID
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    comment.setId(generatedKeys.getInt(1));
                }
                
                // 更新文章的评论计数
                updatePostCommentCount(comment.getPostId());
                // 生成评论消息
                generateCommentMessage(comment);
                
                System.out.println("✅ 评论添加成功，ID: " + comment.getId());
                return true;
            }
        } catch (SQLException e) {
            System.err.println("❌ 添加评论失败: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * 删除评论
     */
    public boolean deleteComment(int commentId, int userId) {
        String sql = "DELETE FROM comments WHERE id = ? AND user_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, commentId);
            stmt.setInt(2, userId);
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                // 更新文章的评论计数（需要知道文章ID）
                // 这里简化处理，实际应该先查询评论获取post_id
                return true;
            }
        } catch (SQLException e) {
            System.err.println("删除评论失败: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * 生成评论消息
     */
    private void generateCommentMessage(Comment comment) {
        try {
            // 获取文章信息
            String postSql = "SELECT p.title, p.user_id as author_id FROM posts p WHERE p.id = ?";
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement postStmt = conn.prepareStatement(postSql)) {
                
                postStmt.setInt(1, comment.getPostId());
                ResultSet rs = postStmt.executeQuery();
                
                if (rs.next()) {
                    int authorId = rs.getInt("author_id");
                    String postTitle = rs.getString("title");
                    
                    // 获取评论用户信息
                    String userSql = "SELECT username, display_name FROM users WHERE id = ?";
                    try (PreparedStatement userStmt = conn.prepareStatement(userSql)) {
                        userStmt.setInt(1, comment.getUserId());
                        ResultSet userRs = userStmt.executeQuery();
                        
                        if (userRs.next()) {
                            String displayName = userRs.getString("display_name");
                            if (displayName == null || displayName.isEmpty()) {
                                displayName = userRs.getString("username");
                            }
                            
                            // 创建消息
                            Message message = new Message();
                            message.setUserId(authorId);
                            message.setType("comment");
                            message.setContent(displayName + " 评论了你的文章《" + postTitle + "》： " + 
                                             (comment.getContent().length() > 50 ? 
                                              comment.getContent().substring(0, 50) + "..." : 
                                              comment.getContent()));
                            message.setSourceUserId(comment.getUserId());
                            message.setPostId(comment.getPostId());
                            message.setCommentId(comment.getId());
                            
                            MessageDAO messageDao = new MessageDAO();
                            messageDao.addMessage(message);
                        }
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("生成评论消息失败: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    
    /**
     * 更新文章的评论计数
     */
    private void updatePostCommentCount(int postId) {
        String sql = "UPDATE posts SET comment_count = (SELECT COUNT(*) FROM comments WHERE post_id = ? AND status = 'approved') WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, postId);
            stmt.setInt(2, postId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            System.err.println("更新评论计数失败: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * 从ResultSet中提取评论信息
     */
    private Comment extractCommentFromResultSet(ResultSet rs) throws SQLException {
        Comment comment = new Comment();
        comment.setId(rs.getInt("id"));
        comment.setPostId(rs.getInt("post_id"));
        comment.setUserId(rs.getInt("user_id"));
        comment.setContent(rs.getString("content"));
        comment.setCreatedAt(rs.getTimestamp("created_at"));
        comment.setUpdatedAt(rs.getTimestamp("updated_at"));
        comment.setStatus(rs.getString("status"));
        comment.setParentId(rs.getInt("parent_id"));
        
        // 用户信息
        comment.setUsername(rs.getString("username"));
        comment.setDisplayName(rs.getString("display_name"));
        comment.setAvatarUrl(rs.getString("avatar_url"));
        
        return comment;
    }
}