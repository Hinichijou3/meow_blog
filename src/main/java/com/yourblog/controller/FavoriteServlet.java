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
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String postIdParam = request.getParameter("post_id");
        String action = request.getParameter("action");
        String redirectUrl = request.getParameter("redirect_url");
        
        System.out.println("FavoriteServlet - post_id: " + postIdParam + ", action: " + action + ", user_id: " + (user != null ? user.getId() : "null"));
        
        if (postIdParam == null || action == null) {
            if (redirectUrl != null) {
                response.sendRedirect(redirectUrl + "&error=参数错误");
            } else {
                response.sendRedirect("default.jsp?error=参数错误");
            }
            return;
        }
        
        try {
            int postId = Integer.parseInt(postIdParam);
            FavoriteDAO favoriteDao = new FavoriteDAO();
            boolean success = false;
            String message = "";
            
            if ("favorite".equals(action)) {
                if (favoriteDao.favoritePost(user.getId(), postId)) {
                    success = true;
                    message = "收藏成功";
                } else {
                    message = "收藏失败，可能已经收藏过了";
                }
            } else if ("unfavorite".equals(action)) {
                if (favoriteDao.unfavoritePost(user.getId(), postId)) {
                    success = true;
                    message = "取消收藏成功";
                } else {
                    message = "取消收藏失败";
                }
            } else {
                message = "无效操作: " + action;
            }
            
            // 重定向回原页面
            if (redirectUrl != null) {
                if (success) {
                    response.sendRedirect(redirectUrl + "&success=" + java.net.URLEncoder.encode(message, "UTF-8"));
                } else {
                    response.sendRedirect(redirectUrl + "&error=" + java.net.URLEncoder.encode(message, "UTF-8"));
                }
            } else {
                response.sendRedirect("view-post.jsp?id=" + postId + "&" + (success ? "success" : "error") + "=" + java.net.URLEncoder.encode(message, "UTF-8"));
            }
            
        } catch (NumberFormatException e) {
            if (redirectUrl != null) {
                response.sendRedirect(redirectUrl + "&error=参数格式错误");
            } else {
                response.sendRedirect("default.jsp?error=参数格式错误");
            }
        } catch (Exception e) {
            if (redirectUrl != null) {
                response.sendRedirect(redirectUrl + "&error=服务器错误");
            } else {
                response.sendRedirect("default.jsp?error=服务器错误");
            }
            e.printStackTrace();
        }
    }
}