package com.yourblog.controller;

import com.yourblog.dao.PostDAO;
import com.yourblog.model.Post;
import com.yourblog.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class CreatePostServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String excerpt = request.getParameter("excerpt");
        String status = request.getParameter("status");
        
        // 验证必填字段
        if (title == null || title.trim().isEmpty() || content == null || content.trim().isEmpty()) {
            request.setAttribute("error", "标题和内容不能为空");
            request.getRequestDispatcher("edit-post.jsp").forward(request, response);
            return;
        }
        
        try {
            PostDAO postDao = new PostDAO();
            
            // 创建新文章
            Post newPost = new Post();
            newPost.setTitle(title.trim());
            newPost.setContent(content.trim());
            newPost.setExcerpt(excerpt != null ? excerpt.trim() : "");
            newPost.setUserId(currentUser.getId());
            newPost.setStatus(status != null ? status : "draft");
            newPost.setViewCount(0);
            
            if (postDao.createPost(newPost)) {
                String successMessage = "published".equals(status) ? "文章发布成功！" : "文章保存为草稿成功！";
                System.out.println("文章创建成功，ID: " + newPost.getId());
                
                // 修改：重定向到个人中心
                response.sendRedirect("my-profile.jsp?success=" + 
                    java.net.URLEncoder.encode(successMessage, "UTF-8"));
            } else {
                request.setAttribute("error", "文章创建失败，请重试");
                request.getRequestDispatcher("create-post.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "服务器错误，请重试");
            request.getRequestDispatcher("edit-post.jsp").forward(request, response);
        }
    }
}