package com.yourblog.dao;

import com.yourblog.model.Message;
import com.yourblog.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MessageDAO {
    
    /**
     * 添加消息
     */
    public boolean addMessage(Message message) {
        String sql = "INSERT INTO messages (user_id, type, content, source_user_id, post_id, comment_id, is_read, created_at) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, message.getUserId());
            stmt.setString(2, message.getType());
            stmt.setString(3, message.getContent());
            stmt.setInt(4, message.getSourceUserId());
            stmt.setInt(5, message.getPostId());
            
            if (message.getCommentId() > 0) {
                stmt.setInt(6, message.getCommentId());
            } else {
                stmt.setNull(6, Types.INTEGER);
            }
            
            stmt.setBoolean(7, message.getIsRead());
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            System.err.println("添加消息失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 获取用户的消息列表（包含用户和文章信息）
     */
    public List<Message> getMessagesByUserId(int userId) {
        List<Message> messages = new ArrayList<>();
        String sql = "SELECT m.*, " +
                    "su.username as source_username, su.display_name as source_display_name, su.avatar_url as source_avatar_url, " +
                    "p.title as post_title " +
                    "FROM messages m " +
                    "LEFT JOIN users su ON m.source_user_id = su.id " +
                    "LEFT JOIN posts p ON m.post_id = p.id " +
                    "WHERE m.user_id = ? " +
                    "ORDER BY m.created_at DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Message message = extractMessageFromResultSet(rs);
                messages.add(message);
            }
        } catch (SQLException e) {
            System.err.println("获取消息列表失败: " + e.getMessage());
            e.printStackTrace();
        }
        return messages;
    }
    
    /**
     * 获取用户未读消息数量
     */
    public int getUnreadMessageCount(int userId) {
        String sql = "SELECT COUNT(*) as count FROM messages WHERE user_id = ? AND is_read = false";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException e) {
            System.err.println("获取未读消息数量失败: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
    
    /**
     * 标记消息为已读
     */
    public boolean markAsRead(int messageId, int userId) {
        String sql = "UPDATE messages SET is_read = true WHERE id = ? AND user_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, messageId);
            stmt.setInt(2, userId);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            System.err.println("标记消息已读失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 标记所有消息为已读
     */
    public boolean markAllAsRead(int userId) {
        String sql = "UPDATE messages SET is_read = true WHERE user_id = ? AND is_read = false";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            System.err.println("标记所有消息已读失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 删除消息
     */
    public boolean deleteMessage(int messageId, int userId) {
        String sql = "DELETE FROM messages WHERE id = ? AND user_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, messageId);
            stmt.setInt(2, userId);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            System.err.println("删除消息失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 从ResultSet中提取消息信息
     */
    private Message extractMessageFromResultSet(ResultSet rs) throws SQLException {
        Message message = new Message();
        message.setId(rs.getInt("id"));
        message.setUserId(rs.getInt("user_id"));
        message.setType(rs.getString("type"));
        message.setContent(rs.getString("content"));
        message.setSourceUserId(rs.getInt("source_user_id"));
        message.setPostId(rs.getInt("post_id"));
        message.setCommentId(rs.getInt("comment_id"));
        message.setIsRead(rs.getBoolean("is_read"));
        message.setCreatedAt(rs.getTimestamp("created_at"));
        
        // 关联信息
        message.setSourceUsername(rs.getString("source_username"));
        message.setSourceDisplayName(rs.getString("source_display_name"));
        message.setSourceAvatarUrl(rs.getString("source_avatar_url"));
        message.setPostTitle(rs.getString("post_title"));
        
        return message;
    }
}