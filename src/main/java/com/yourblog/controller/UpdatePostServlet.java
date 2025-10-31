package com.yourblog.controller;

import com.yourblog.dao.PostDAO;
import com.yourblog.model.Post;
import com.yourblog.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class UpdatePostServlet extends HttpServlet {
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
        
        String postIdParam = request.getParameter("id");
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String excerpt = request.getParameter("excerpt");
        String status = request.getParameter("status");
        
        // 验证必填字段
        if (title == null || title.trim().isEmpty() || content == null || content.trim().isEmpty()) {
            request.setAttribute("error", "标题和内容不能为空");
            request.getRequestDispatcher("edit-post.jsp?id=" + postIdParam).forward(request, response);
            return;
        }
        
        try {
            int postId = Integer.parseInt(postIdParam);
            PostDAO postDao = new PostDAO();
            
            // 验证文章属于当前用户
            Post existingPost = postDao.getPostById(postId);
            if (existingPost == null) {
                request.setAttribute("error", "文章不存在");
                request.getRequestDispatcher("edit-post.jsp").forward(request, response);
                return;
            }
            
            if (existingPost.getUserId() != currentUser.getId()) {
                request.setAttribute("error", "无权编辑此文章");
                request.getRequestDispatcher("edit-post.jsp").forward(request, response);
                return;
            }
            
            // 更新文章信息
            existingPost.setTitle(title.trim());
            existingPost.setContent(content.trim());
            existingPost.setExcerpt(excerpt != null ? excerpt.trim() : "");
            existingPost.setStatus(status != null ? status : "draft");
            
            if (postDao.updatePost(existingPost)) {
                // 修改：重定向到个人中心
                response.sendRedirect("my-profile.jsp?success=文章更新成功");
            } else {
                // 修改：重定向到个人中心
                response.sendRedirect("my-profile.jsp?error=文章更新失败，请重试");
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "无效的文章ID");
            request.getRequestDispatcher("edit-post.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "服务器错误，请重试");
            request.getRequestDispatcher("edit-post.jsp?id=" + postIdParam).forward(request, response);
        }
    }
}