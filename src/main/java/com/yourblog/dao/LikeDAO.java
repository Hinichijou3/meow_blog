package com.yourblog.dao;

import com.yourblog.util.DatabaseUtil;
import com.yourblog.model.*;
import java.sql.*;

public class LikeDAO {
    
    // 点赞文章
	public boolean likePost(int userId, int postId) {
	    String sql = "INSERT INTO likes (user_id, post_id) VALUES (?, ?)";
	    try (Connection conn = DatabaseUtil.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(sql)) {
	        stmt.setInt(1, userId);
	        stmt.setInt(2, postId);
	        int affectedRows = stmt.executeUpdate();
	        
	        if (affectedRows > 0) {
	            // 生成点赞消息
	            generateLikeMessage(userId, postId);
	            return true;
	        }
	        return false;
	    } catch (SQLException e) {
	        // 如果是重复点赞，忽略错误
	        if (e.getErrorCode() == 1062) { // MySQL duplicate entry
	            return false;
	        }
	        e.printStackTrace();
	        return false;
	    }
	}
    
    // 取消点赞
    public boolean unlikePost(int userId, int postId) {
        String sql = "DELETE FROM likes WHERE user_id = ? AND post_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, postId);
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    
    /**
     * 生成点赞消息
     */
    private void generateLikeMessage(int userId, int postId) {
        try {
            // 获取文章信息
            String postSql = "SELECT p.title, p.user_id as author_id FROM posts p WHERE p.id = ?";
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement postStmt = conn.prepareStatement(postSql)) {
                
                postStmt.setInt(1, postId);
                ResultSet rs = postStmt.executeQuery();
                
                if (rs.next()) {
                    int authorId = rs.getInt("author_id");
                    String postTitle = rs.getString("title");
                    
                    // 获取点赞用户信息
                    String userSql = "SELECT username, display_name FROM users WHERE id = ?";
                    try (PreparedStatement userStmt = conn.prepareStatement(userSql)) {
                        userStmt.setInt(1, userId);
                        ResultSet userRs = userStmt.executeQuery();
                        
                        if (userRs.next()) {
                            String displayName = userRs.getString("display_name");
                            if (displayName == null || displayName.isEmpty()) {
                                displayName = userRs.getString("username");
                            }
                            
                            // 创建消息
                            Message message = new Message();
                            message.setUserId(authorId);
                            message.setType("like");
                            message.setContent(displayName + " 点赞了你的文章《" + postTitle + "》");
                            message.setSourceUserId(userId);
                            message.setPostId(postId);
                            
                            MessageDAO messageDao = new MessageDAO();
                            messageDao.addMessage(message);
                        }
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("生成点赞消息失败: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    // 检查用户是否已点赞
    public boolean isLiked(int userId, int postId) {
        String sql = "SELECT id FROM likes WHERE user_id = ? AND post_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, postId);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // 获取文章点赞数
    public int getLikeCount(int postId) {
        String sql = "SELECT COUNT(*) as count FROM likes WHERE post_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, postId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // 获取用户总点赞数（作为作者获得的点赞）
    public int getUserTotalLikes(int userId) {
        String sql = "SELECT COUNT(*) as count FROM likes l " +
                    "JOIN posts p ON l.post_id = p.id " +
                    "WHERE p.user_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}