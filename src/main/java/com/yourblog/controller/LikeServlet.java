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
            LikeDAO likeDao = new LikeDAO();
            
            if ("like".equals(action)) {
                if (likeDao.likePost(user.getId(), postId)) {
                    int newCount = likeDao.getLikeCount(postId);
                    out.print("{\"success\": true, \"liked\": true, \"count\": " + newCount + "}");
                } else {
                    out.print("{\"success\": false, \"message\": \"点赞失败\"}");
                }
            } else if ("unlike".equals(action)) {
                if (likeDao.unlikePost(user.getId(), postId)) {
                    int newCount = likeDao.getLikeCount(postId);
                    out.print("{\"success\": true, \"liked\": false, \"count\": " + newCount + "}");
                } else {
                    out.print("{\"success\": false, \"message\": \"取消点赞失败\"}");
                }
            } else {
                out.print("{\"success\": false, \"message\": \"无效操作\"}");
            }
        } catch (NumberFormatException e) {
            out.print("{\"success\": false, \"message\": \"参数错误\"}");
        }
    }
}