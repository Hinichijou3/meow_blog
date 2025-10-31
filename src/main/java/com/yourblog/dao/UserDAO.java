package com.yourblog.dao;

import com.yourblog.model.User;
import com.yourblog.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
    
    // 根据用户名查找用户
    public User findByUsername(String username) {
        User user = null;
        String sql = "SELECT * FROM users WHERE username = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                user = extractUserFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return user;
    }
    
    // 根据ID查找用户
    public User findById(int id) {
        User user = null;
        String sql = "SELECT * FROM users WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                user = extractUserFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return user;
    }
    
    // 创建新用户
    public boolean createUser(User user) {
        String sql = "INSERT INTO users (username, email, password_hash, display_name, bio) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPasswordHash()); // 注意：实际中应该加密
            stmt.setString(4, user.getDisplayName());
            stmt.setString(5, user.getBio());
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // 验证用户登录
    public User validateUser(String username, String password) {
        User user = findByUsername(username);
        if (user != null) {
            // 注意：实际中应该使用密码加密验证
            // 这里简化处理，实际应该使用BCrypt等加密算法
            if (user.getPasswordHash().equals(password)) {
                return user;
            }
        }
        return null;
    }
    
    // 从ResultSet提取用户信息
    private User extractUserFromResultSet(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setEmail(rs.getString("email"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setDisplayName(rs.getString("display_name"));
        user.setAvatarUrl(rs.getString("avatar_url"));
        user.setHeaderImageUrl(rs.getString("header_image_url"));  // 新增
        user.setBio(rs.getString("bio"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setUpdatedAt(rs.getTimestamp("updated_at"));
        return user;
    }
    
    //更新用户基本信息
    public boolean updateUserProfile(User user) {
        String sql = "UPDATE users SET email = ?, display_name = ?, bio = ? WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, user.getEmail());
            stmt.setString(2, user.getDisplayName());
            stmt.setString(3, user.getBio());
            stmt.setInt(4, user.getId());
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("更新用户资料失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    //更新用户头像
    public boolean updateUserAvatar(int userId, String avatarUrl) {
        String sql = "UPDATE users SET avatar_url = ? WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, avatarUrl);
            stmt.setInt(2, userId);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("更新用户头像失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    //更新用户头图
    public boolean updateUserHeaderImage(int userId, String headerImageUrl) {
        String sql = "UPDATE users SET header_image_url = ? WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, headerImageUrl);
            stmt.setInt(2, userId);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("更新用户头图失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 验证用户密码
     */
    public boolean verifyPassword(int userId, String password) {
        String sql = "SELECT password_hash FROM users WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                String storedPassword = rs.getString("password_hash");
                // 这里假设密码是明文存储的，实际项目中应该使用加密验证
                return storedPassword.equals(password);
            }
        } catch (SQLException e) {
            System.err.println("验证密码失败: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * 更新用户密码
     */
    public boolean updatePassword(int userId, String newPassword) {
        String sql = "UPDATE users SET password_hash = ?, updated_at = NOW() WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, newPassword); // 实际项目中应该加密存储
            stmt.setInt(2, userId);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            System.err.println("更新密码失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 检查邮箱是否已被其他用户使用
     */
    public boolean isEmailUsedByOther(int userId, String email) {
        String sql = "SELECT id FROM users WHERE email = ? AND id != ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            stmt.setInt(2, userId);
            ResultSet rs = stmt.executeQuery();
            
            return rs.next(); // 如果找到其他用户使用这个邮箱，返回true
            
        } catch (SQLException e) {
            System.err.println("检查邮箱使用情况失败: " + e.getMessage());
            e.printStackTrace();
            return true; // 出错时保守处理，认为邮箱已被使用
        }
    }

}