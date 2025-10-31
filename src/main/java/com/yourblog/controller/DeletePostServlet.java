package com.yourblog.controller;

import com.yourblog.dao.PostDAO;
import com.yourblog.model.Post;
import com.yourblog.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class DeletePostServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("=== 开始处理删除文章请求 ===");
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            System.out.println("❌ 用户未登录，重定向到登录页面");
            response.sendRedirect("login.jsp");
            return;
        }
        
        System.out.println("✅ 当前用户: " + currentUser.getUsername() + " (ID: " + currentUser.getId() + ")");
        
        String postIdParam = request.getParameter("id");
        System.out.println("📝 接收到的文章ID参数: " + postIdParam);
        
        if (postIdParam == null || postIdParam.isEmpty()) {
            System.out.println("❌ 文章ID参数为空");
            response.sendRedirect("my-profile.jsp?error=无效的文章ID");
            return;
        }
        
        try {
            int postId = Integer.parseInt(postIdParam);
            PostDAO postDao = new PostDAO();
            
            // 验证文章属于当前用户
            Post post = postDao.getPostById(postId);
            if (post == null) {
                System.out.println("❌ 文章不存在，ID: " + postId);
                response.sendRedirect("my-profile.jsp?error=文章不存在");
                return;
            }
            
            System.out.println("📖 找到文章: " + post.getTitle() + " (用户ID: " + post.getUserId() + ")");
            
            if (post.getUserId() != currentUser.getId()) {
                System.out.println("❌ 权限验证失败: 文章属于用户 " + post.getUserId() + "，当前用户 " + currentUser.getId());
                response.sendRedirect("my-profile.jsp?error=无权删除此文章");
                return;
            }
            
            System.out.println("✅ 权限验证通过，开始删除文章...");
            
            // 执行删除
            if (postDao.deletePost(postId)) {
                System.out.println("✅ 文章删除成功，ID: " + postId);
                response.sendRedirect("my-profile.jsp?success=文章删除成功");
            } else {
                System.out.println("❌ 数据库删除操作失败");
                response.sendRedirect("my-profile.jsp?error=文章删除失败，请重试");
            }
            
        } catch (NumberFormatException e) {
            System.out.println("❌ 文章ID格式错误: " + postIdParam);
            response.sendRedirect("my-profile.jsp?error=无效的文章ID");
        } catch (Exception e) {
            System.out.println("❌ 服务器错误: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("my-profile.jsp?error=服务器错误，请重试");
        }
        
        System.out.println("=== 删除文章请求处理完成 ===");
    }
    
    // 支持GET请求（用于直接链接访问）
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        System.out.println("⚠️ 收到GET请求，转为POST处理");
        doPost(request, response);
    }
}