package com.yourblog.dao;

import com.yourblog.model.Post;
import com.yourblog.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FavoriteDAO {
    
    // 收藏文章
    public boolean favoritePost(int userId, int postId) {
        String sql = "INSERT INTO favorites (user_id, post_id) VALUES (?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, postId);
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            if (e.getErrorCode() == 1062) {
                return false; // 重复收藏
            }
            e.printStackTrace();
            return false;
        }
    }
    
    // 取消收藏
    public boolean unfavoritePost(int userId, int postId) {
        String sql = "DELETE FROM favorites WHERE user_id = ? AND post_id = ?";
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
    
    // 检查是否已收藏
    public boolean isFavorited(int userId, int postId) {
        String sql = "SELECT id FROM favorites WHERE user_id = ? AND post_id = ?";
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
    
    // 获取用户收藏的文章列表
    public List<Post> getUserFavorites(int userId) {
        List<Post> posts = new ArrayList<>();
        String sql = "SELECT p.*, u.username, u.display_name " +
                    "FROM favorites f " +
                    "JOIN posts p ON f.post_id = p.id " +
                    "JOIN users u ON p.user_id = u.id " +
                    "WHERE f.user_id = ? " +
                    "ORDER BY f.created_at DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Post post = new Post();
                post.setId(rs.getInt("id"));
                post.setTitle(rs.getString("title"));
                post.setContent(rs.getString("content"));
                post.setExcerpt(rs.getString("excerpt"));
                post.setAuthor(rs.getString("display_name"));
                post.setUserId(rs.getInt("user_id"));
                post.setCreatedAt(rs.getTimestamp("created_at"));
                post.setUpdatedAt(rs.getTimestamp("updated_at"));
                post.setViewCount(rs.getInt("view_count"));
                post.setStatus(rs.getString("status"));
                posts.add(post);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return posts;
    }
}