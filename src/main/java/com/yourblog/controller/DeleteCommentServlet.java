package com.yourblog.controller;

import com.yourblog.dao.CommentDAO;
import com.yourblog.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class DeleteCommentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("=== 开始处理删除评论请求 ===");
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            System.out.println("❌ 用户未登录");
            response.sendRedirect("login.jsp");
            return;
        }
        
        String commentIdParam = request.getParameter("id");
        String postIdParam = request.getParameter("post_id");
        
        System.out.println("🗑️ 删除评论参数 - 评论ID: " + commentIdParam + ", 文章ID: " + postIdParam);
        
        if (commentIdParam == null || commentIdParam.isEmpty()) {
            System.out.println("❌ 评论ID为空");
            response.sendRedirect("default.jsp?error=无效的评论ID");
            return;
        }
        
        try {
            int commentId = Integer.parseInt(commentIdParam);
            CommentDAO commentDao = new CommentDAO();
            
            // 删除评论（会验证用户权限）
            if (commentDao.deleteComment(commentId, currentUser.getId())) {
                System.out.println("✅ 评论删除成功");
                
                // 重定向回文章页面
                if (postIdParam != null && !postIdParam.isEmpty()) {
                    response.sendRedirect("view-post.jsp?id=" + postIdParam + "&success=评论删除成功");
                } else {
                    response.sendRedirect("default.jsp?success=评论删除成功");
                }
            } else {
                System.out.println("❌ 评论删除失败");
                response.sendRedirect("view-post.jsp?id=" + postIdParam + "&error=评论删除失败，请重试");
            }
        } catch (NumberFormatException e) {
            System.out.println("❌ 评论ID格式错误");
            response.sendRedirect("view-post.jsp?id=" + postIdParam + "&error=无效的评论ID");
        } catch (Exception e) {
            System.out.println("❌ 服务器错误: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("view-post.jsp?id=" + postIdParam + "&error=服务器错误，请重试");
        }
        
        System.out.println("=== 删除评论请求处理完成 ===");
    }
}