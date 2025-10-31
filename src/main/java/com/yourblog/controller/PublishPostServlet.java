package com.yourblog.controller;

import com.yourblog.dao.PostDAO;
import com.yourblog.model.Post;
import com.yourblog.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class PublishPostServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        try {
            int postId = Integer.parseInt(request.getParameter("id"));
            PostDAO postDao = new PostDAO();
            
            // 验证文章属于当前用户
            Post post = postDao.getPostById(postId);
            if (post != null && post.getUserId() == currentUser.getId()) {
                post.setStatus("published");
                if (postDao.updatePost(post)) {
                    request.setAttribute("success", "文章发布成功！");
                } else {
                    request.setAttribute("error", "文章发布失败，请重试");
                    response.sendRedirect("my-profile.jsp?error=文章发布失败，请重试");
                }
            } else {
                request.setAttribute("error", "无权操作此文章");
                response.sendRedirect("my-profile.jsp?error=无权操作此文章");
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "无效的文章ID");
            response.sendRedirect("my-profile.jsp?error=无效的文章ID");
        }
        
        request.getRequestDispatcher("my-posts.jsp").forward(request, response);
    }
}