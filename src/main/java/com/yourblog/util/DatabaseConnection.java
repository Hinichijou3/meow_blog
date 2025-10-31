// DatabaseConnection.java
package com.yourblog.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    private static final String URL = "jdbc:mysql://localhost:3306/your_blog_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai&useSSL=false";
    private static final String USERNAME = "your_username";
    private static final String PASSWORD = "your_password";
    
    static {
        try {
            // 加载MySQL驱动
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            throw new RuntimeException("MySQL JDBC Driver not found", e);
        }
    }
    
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }
    
    // 测试连接
    public static void main(String[] args) {
        try (Connection conn = getConnection()) {
            System.out.println("数据库连接成功！");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}