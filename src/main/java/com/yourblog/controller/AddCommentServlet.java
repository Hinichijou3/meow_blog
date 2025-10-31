package com.yourblog.controller;

import com.yourblog.dao.CommentDAO;
import com.yourblog.model.Comment;
import com.yourblog.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;

public class AddCommentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        System.out.println("=== 开始处理评论提交 ===");
        
        // 检查用户是否登录
        if (currentUser == null) {
            System.out.println("❌ 用户未登录，重定向到登录页面");
            String postId = request.getParameter("post_id");
            response.sendRedirect("login.jsp?redirect=view-post.jsp?id=" + (postId != null ? postId : ""));
            return;
        }
        
        String postIdParam = request.getParameter("post_id");
        String content = request.getParameter("content");
        String parentIdParam = request.getParameter("parent_id");
        
        System.out.println("📝 评论参数 - 文章ID: " + postIdParam + ", 内容长度: " + (content != null ? content.length() : 0));
        
        // 验证必填字段
        if (postIdParam == null || postIdParam.isEmpty()) {
            System.out.println("❌ 文章ID为空");
            response.sendRedirect("default.jsp?error=" + URLEncoder.encode("无效的文章", "UTF-8"));
            return;
        }
        
        if (content == null || content.trim().isEmpty()) {
            System.out.println("❌ 评论内容为空");
            response.sendRedirect("view-post.jsp?id=" + postIdParam + "&error=" + URLEncoder.encode("评论内容不能为空", "UTF-8"));
            return;
        }
        
        try {
            int postId = Integer.parseInt(postIdParam);
            int parentId = 0;
            if (parentIdParam != null && !parentIdParam.isEmpty()) {
                parentId = Integer.parseInt(parentIdParam);
            }
            
            CommentDAO commentDao = new CommentDAO();
            
            // 创建新评论
            Comment comment = new Comment();
            comment.setPostId(postId);
            comment.setUserId(currentUser.getId());
            comment.setContent(content.trim());
            comment.setParentId(parentId);
            
            System.out.println("💬 准备保存评论...");
            
            if (commentDao.addComment(comment)) {
                System.out.println("✅ 评论保存成功，重定向到文章页面");
                // 重定向回文章页面，显示成功消息
                response.sendRedirect("view-post.jsp?id=" + postId + "&success=" + URLEncoder.encode("评论发布成功", "UTF-8"));
            } else {
                System.out.println("❌ 评论保存失败");
                response.sendRedirect("view-post.jsp?id=" + postId + "&error=" + URLEncoder.encode("评论发布失败，请重试", "UTF-8"));
            }
        } catch (NumberFormatException e) {
            System.out.println("❌ 文章ID格式错误: " + postIdParam);
            response.sendRedirect("default.jsp?error=" + URLEncoder.encode("无效的文章ID", "UTF-8"));
        } catch (Exception e) {
            System.err.println("❌ 服务器错误: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("view-post.jsp?id=" + postIdParam + "&error=" + URLEncoder.encode("服务器错误，请重试", "UTF-8"));
        }
    }
}