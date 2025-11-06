package com.yourblog.controller;

import com.yourblog.dao.LikeDAO;
import com.yourblog.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

public class LikeServlet extends HttpServlet {
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
        
        System.out.println("LikeServlet - post_id: " + postIdParam + ", action: " + action + ", user_id: " + (user != null ? user.getId() : "null"));
        
        if (postIdParam == null || action == null) {
            // 如果有重定向URL，跳转回去
            if (redirectUrl != null) {
                response.sendRedirect(redirectUrl + "&error=参数错误");
            } else {
                response.sendRedirect("default.jsp?error=参数错误");
            }
            return;
        }
        
        try {
            int postId = Integer.parseInt(postIdParam);
            LikeDAO likeDao = new LikeDAO();
            boolean success = false;
            String message = "";
            
            if ("like".equals(action)) {
                if (likeDao.likePost(user.getId(), postId)) {
                    success = true;
                    message = "点赞成功";
                } else {
                    message = "点赞失败，可能已经点过赞了";
                }
            } else if ("unlike".equals(action)) {
                if (likeDao.unlikePost(user.getId(), postId)) {
                    success = true;
                    message = "取消点赞成功";
                } else {
                    message = "取消点赞失败";
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
                // 如果没有重定向URL，默认跳转到文章页面
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