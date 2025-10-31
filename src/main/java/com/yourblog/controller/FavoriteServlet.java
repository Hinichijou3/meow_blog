package com.yourblog.controller;

import com.yourblog.dao.FavoriteDAO;
import com.yourblog.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

public class FavoriteServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        PrintWriter out = response.getWriter();
        
        if (user == null) {
            out.print("{\"success\": false, \"message\": \"请先登录\"}");
            return;
        }
        
        String postIdParam = request.getParameter("postId");
        String action = request.getParameter("action");
        
        if (postIdParam == null) {
            out.print("{\"success\": false, \"message\": \"参数错误\"}");
            return;
        }
        
        try {
            int postId = Integer.parseInt(postIdParam);
            FavoriteDAO favoriteDao = new FavoriteDAO();
            
            if ("favorite".equals(action)) {
                if (favoriteDao.favoritePost(user.getId(), postId)) {
                    out.print("{\"success\": true, \"favorited\": true}");
                } else {
                    out.print("{\"success\": false, \"message\": \"收藏失败\"}");
                }
            } else if ("unfavorite".equals(action)) {
                if (favoriteDao.unfavoritePost(user.getId(), postId)) {
                    out.print("{\"success\": true, \"favorited\": false}");
                } else {
                    out.print("{\"success\": false, \"message\": \"取消收藏失败\"}");
                }
            } else {
                out.print("{\"success\": false, \"message\": \"无效操作\"}");
            }
        } catch (NumberFormatException e) {
            out.print("{\"success\": false, \"message\": \"参数错误\"}");
        }
    }
}