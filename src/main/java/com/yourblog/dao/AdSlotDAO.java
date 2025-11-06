package com.yourblog.dao;

import com.yourblog.model.AdSlot;
import com.yourblog.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdSlotDAO {
    
    // 获取所有广告位
    public List<AdSlot> getAllAdSlots() {
        List<AdSlot> adSlots = new ArrayList<>();
        String sql = "SELECT * FROM ad_slots WHERE status = 'active' ORDER BY created_at DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                adSlots.add(extractAdSlotFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.err.println("获取广告位失败: " + e.getMessage());
            e.printStackTrace();
        }
        return adSlots;
    }
    
    // 根据ID获取广告位
    public AdSlot getAdSlotById(int id) {
        AdSlot adSlot = null;
        String sql = "SELECT * FROM ad_slots WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                adSlot = extractAdSlotFromResultSet(rs);
            }
        } catch (SQLException e) {
            System.err.println("获取广告位失败: " + e.getMessage());
            e.printStackTrace();
        }
        return adSlot;
    }
    
    // 创建广告位
    public boolean createAdSlot(AdSlot adSlot) {
        String sql = "INSERT INTO ad_slots (name, description, width, height, max_duration, status) VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, adSlot.getName());
            stmt.setString(2, adSlot.getDescription());
            stmt.setInt(3, adSlot.getWidth());
            stmt.setInt(4, adSlot.getHeight());
            stmt.setInt(5, adSlot.getMaxDuration());
            stmt.setString(6, adSlot.getStatus());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("创建广告位失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // 从ResultSet提取广告位信息
    private AdSlot extractAdSlotFromResultSet(ResultSet rs) throws SQLException {
        AdSlot adSlot = new AdSlot();
        adSlot.setId(rs.getInt("id"));
        adSlot.setName(rs.getString("name"));
        adSlot.setDescription(rs.getString("description"));
        adSlot.setWidth(rs.getInt("width"));           // 这里应该是正确的
        adSlot.setHeight(rs.getInt("height"));         // 这里应该是正确的
        adSlot.setMaxDuration(rs.getInt("max_duration")); // 这里应该是正确的
        adSlot.setStatus(rs.getString("status"));
        adSlot.setCreatedAt(rs.getTimestamp("created_at"));
        adSlot.setUpdatedAt(rs.getTimestamp("updated_at"));
        return adSlot;
    }
}