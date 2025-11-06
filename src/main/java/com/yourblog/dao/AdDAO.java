package com.yourblog.dao;

import com.yourblog.model.Ad;
import com.yourblog.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdDAO {
    
    // 创建广告
    public boolean createAd(Ad ad) {
        String sql = "INSERT INTO ads (user_id, title, image_url, target_url, ad_type, price, status, start_date, end_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, ad.getUserId());
            stmt.setString(2, ad.getTitle());
            stmt.setString(3, ad.getImageUrl());
            stmt.setString(4, ad.getTargetUrl());
            stmt.setString(5, ad.getAdType());
            stmt.setInt(6, ad.getPrice());
            stmt.setString(7, ad.getStatus());
            stmt.setTimestamp(8, ad.getStartDate());
            stmt.setTimestamp(9, ad.getEndDate());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("创建广告失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // 获取有效的轮播广告
    public List<Ad> getActiveCarouselAds() {
        List<Ad> ads = new ArrayList<>();
        String sql = "SELECT * FROM ads WHERE ad_type = 'carousel' AND status = 'active' AND start_date <= NOW() AND (end_date IS NULL OR end_date >= NOW()) ORDER BY created_at DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                ads.add(extractAdFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.err.println("获取轮播广告失败: " + e.getMessage());
            e.printStackTrace();
        }
        return ads;
    }
    
    // 获取有效的单图广告
    public List<Ad> getActiveSingleAds() {
        List<Ad> ads = new ArrayList<>();
        String sql = "SELECT * FROM ads WHERE ad_type = 'single' AND status = 'active' AND start_date <= NOW() AND (end_date IS NULL OR end_date >= NOW()) ORDER BY created_at DESC LIMIT 1";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                ads.add(extractAdFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.err.println("获取单图广告失败: " + e.getMessage());
            e.printStackTrace();
        }
        return ads;
    }
    
    // 更新广告点击量
    public boolean incrementClicks(int adId) {
        String sql = "UPDATE ads SET clicks = clicks + 1 WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, adId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("更新广告点击量失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // 更新广告浏览量
    public boolean incrementViews(int adId) {
        String sql = "UPDATE ads SET views = views + 1 WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, adId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("更新广告浏览量失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // 获取用户的所有广告
    public List<Ad> getAdsByUserId(int userId) {
        List<Ad> ads = new ArrayList<>();
        String sql = "SELECT * FROM ads WHERE user_id = ? ORDER BY created_at DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                ads.add(extractAdFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.err.println("获取用户广告失败: " + e.getMessage());
            e.printStackTrace();
        }
        return ads;
    }
    
    // 根据广告ID删除广告
    public boolean deleteAd(int adId) {
        String sql = "DELETE FROM ads WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, adId);
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("删除广告失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // 根据广告ID和用户ID删除广告（确保用户只能删除自己的广告）
    public boolean deleteAdByUser(int adId, int userId) {
        String sql = "DELETE FROM ads WHERE id = ? AND user_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, adId);
            stmt.setInt(2, userId);
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("删除用户广告失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // 根据广告ID获取广告信息
    public Ad getAdById(int adId) {
        Ad ad = null;
        String sql = "SELECT * FROM ads WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, adId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                ad = extractAdFromResultSet(rs);
            }
        } catch (SQLException e) {
            System.err.println("获取广告失败: " + e.getMessage());
            e.printStackTrace();
        }
        return ad;
    }
    
    // 从ResultSet提取广告信息
    private Ad extractAdFromResultSet(ResultSet rs) throws SQLException {
        Ad ad = new Ad();
        ad.setId(rs.getInt("id"));
        ad.setUserId(rs.getInt("user_id"));
        ad.setTitle(rs.getString("title"));
        ad.setImageUrl(rs.getString("image_url"));
        ad.setTargetUrl(rs.getString("target_url"));
        ad.setAdType(rs.getString("ad_type"));
        ad.setPrice(rs.getInt("price"));
        ad.setStatus(rs.getString("status"));
        ad.setViews(rs.getInt("views"));
        ad.setClicks(rs.getInt("clicks"));
        ad.setStartDate(rs.getTimestamp("start_date"));
        ad.setEndDate(rs.getTimestamp("end_date"));
        ad.setCreatedAt(rs.getTimestamp("created_at"));
        return ad;
    }
}