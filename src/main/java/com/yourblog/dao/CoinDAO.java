package com.yourblog.dao;

import com.yourblog.util.DatabaseUtil;
import com.yourblog.model.*;
import java.sql.*;

public class CoinDAO {
    
    // 投币给文章
	public boolean coinPost(int fromUserId, int postId, int toUserId) {
	    String sql = "INSERT INTO coin_actions (from_user_id, to_user_id, post_id, coins) VALUES (?, ?, ?, 1)";
	    try (Connection conn = DatabaseUtil.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(sql)) {
	        stmt.setInt(1, fromUserId);
	        stmt.setInt(2, toUserId);
	        stmt.setInt(3, postId);
	        int affectedRows = stmt.executeUpdate();
	        
	        if (affectedRows > 0) {
	            // 生成投币消息
	            generateCoinMessage(fromUserId, postId, toUserId);
	            return true;
	        }
	        return false;
	    } catch (SQLException e) {
	        e.printStackTrace();
	        return false;
	    }
	}

    
    // 检查用户是否已给文章投币
    public boolean hasCoined(int userId, int postId) {
        String sql = "SELECT id FROM coin_actions WHERE from_user_id = ? AND post_id = ?";
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
    
    // 获取文章获得的投币数
    public int getCoinCount(int postId) {
        String sql = "SELECT COUNT(*) as count FROM coin_actions WHERE post_id = ?";
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
    
    // 获取用户获得的投币总数（作为作者）
    public int getUserCoinsEarned(int userId) {
        String sql = "SELECT COUNT(*) as count FROM coin_actions WHERE to_user_id = ?";
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
    
    /**
     * 生成投币消息
     */
    private void generateCoinMessage(int fromUserId, int postId, int toUserId) {
        try {
            // 获取文章信息
            String postSql = "SELECT p.title FROM posts p WHERE p.id = ?";
            try (Connection conn = DatabaseUtil.getConnection();
                 PreparedStatement postStmt = conn.prepareStatement(postSql)) {
                
                postStmt.setInt(1, postId);
                ResultSet rs = postStmt.executeQuery();
                
                if (rs.next()) {
                    String postTitle = rs.getString("title");
                    
                    // 获取投币用户信息
                    String userSql = "SELECT username, display_name FROM users WHERE id = ?";
                    try (PreparedStatement userStmt = conn.prepareStatement(userSql)) {
                        userStmt.setInt(1, fromUserId);
                        ResultSet userRs = userStmt.executeQuery();
                        
                        if (userRs.next()) {
                            String displayName = userRs.getString("display_name");
                            if (displayName == null || displayName.isEmpty()) {
                                displayName = userRs.getString("username");
                            }
                            
                            // 创建消息
                            Message message = new Message();
                            message.setUserId(toUserId);
                            message.setType("coin");
                            message.setContent(displayName + " 投币了你的文章《" + postTitle + "》");
                            message.setSourceUserId(fromUserId);
                            message.setPostId(postId);
                            
                            MessageDAO messageDao = new MessageDAO();
                            messageDao.addMessage(message);
                        }
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("生成投币消息失败: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    // 获取用户今日是否已登录领取硬币
    public boolean hasLoggedInToday(int userId) {
        String sql = "SELECT last_login_date FROM users WHERE id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Date lastLogin = rs.getDate("last_login_date");
                if (lastLogin != null) {
                    java.util.Date today = new java.util.Date();
                    return lastLogin.toString().equals(new java.sql.Date(today.getTime()).toString());
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // 更新用户最后登录日期并赠送硬币
    public boolean updateLoginAndGiveCoin(int userId) {
        String sql = "UPDATE users SET coins = coins + 1, last_login_date = CURDATE() WHERE id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // 消费硬币（投币时）
    public boolean spendCoin(int userId) {
        String sql = "UPDATE users SET coins = coins - 1 WHERE id = ? AND coins > 0";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // 作者获得硬币（10:1比例）
    public boolean earnCoin(int userId) {
        // 计算应该获得的硬币数（每10个投币获得1个硬币）
        String checkSql = "SELECT COUNT(*) as coin_count FROM coin_actions WHERE to_user_id = ?";
        String updateSql = "UPDATE users SET coins = coins + 1, total_coins_earned = total_coins_earned + 1 WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement checkStmt = conn.prepareStatement(checkSql);
             PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
            
            checkStmt.setInt(1, userId);
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                int coinCount = rs.getInt("coin_count");
                // 每10个投币获得1个硬币
                if (coinCount % 10 == 0 && coinCount > 0) {
                    updateStmt.setInt(1, userId);
                    int affectedRows = updateStmt.executeUpdate();
                    return affectedRows > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}