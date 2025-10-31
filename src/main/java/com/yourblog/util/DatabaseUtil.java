package com.yourblog.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseUtil {
    // 数据库连接信息 - 请根据你的实际情况修改！
    private static final String URL = "jdbc:mysql://localhost:3306/blog_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
    private static final String USER = "blog_admin";
    private static final String PASSWORD = "admin123"; // 替换为你的实际密码

    // 静态代码块：在类加载时执行，注册驱动程序
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("MySQL JDBC驱动加载成功！");
        } catch (ClassNotFoundException e) {
            System.err.println("找不到MySQL JDBC驱动qwq");
            e.printStackTrace();
        }
    }

    // 获取数据库连接
    public static Connection getConnection() throws SQLException {
        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("数据库连接成功！");
            return conn;
        } catch (SQLException e) {
            System.err.println("数据库连接失败！");
            throw e;
        }
    }

    // 关闭数据库连接
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
                System.out.println("数据库连接已关闭！");
            } catch (SQLException e) {
                System.err.println("关闭数据库连接时出错！");
                e.printStackTrace();
            }
        }
    }

    // 测试连接的方法（可选）
    public static void main(String[] args) {
        try {
            Connection conn = getConnection();
            if (conn != null && !conn.isClosed()) {
                System.out.println("✅ 数据库连接测试成功！");
            }
            closeConnection(conn);
        } catch (SQLException e) {
            System.err.println("❌ 数据库连接测试失败！");
            e.printStackTrace();
        }
    }
}