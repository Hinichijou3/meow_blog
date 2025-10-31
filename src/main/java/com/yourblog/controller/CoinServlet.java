package com.yourblog.controller;

import com.yourblog.dao.CoinDAO;
import com.yourblog.dao.PostDAO;
import com.yourblog.model.Post;
import com.yourblog.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

public class CoinServlet extends HttpServlet {
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
        
        if (postIdParam == null) {
            out.print("{\"success\": false, \"message\": \"参数错误\"}");
            return;
        }
        
        try {
            int postId = Integer.parseInt(postIdParam);
            CoinDAO coinDao = new CoinDAO();
            PostDAO postDao = new PostDAO();
            
            // 检查用户是否还有硬币
            if (user.getCoins() <= 0) {
                out.print("{\"success\": false, \"message\": \"硬币不足\"}");
                return;
            }
            
            // 检查是否已投币
            if (coinDao.hasCoined(user.getId(), postId)) {
                out.print("{\"success\": false, \"message\": \"已投过币\"}");
                return;
            }
            
            // 获取文章作者信息
            Post post = postDao.getPostById(postId);
            if (post == null) {
                out.print("{\"success\": false, \"message\": \"文章不存在\"}");
                return;
            }
            
            // 执行投币操作
            if (coinDao.coinPost(user.getId(), postId, post.getUserId()) && 
                coinDao.spendCoin(user.getId())) {
                
                // 更新作者硬币（10:1比例）
                coinDao.earnCoin(post.getUserId());
                
                // 更新session中的用户硬币数
                user.setCoins(user.getCoins() - 1);
                session.setAttribute("user", user);
                
                int newCount = coinDao.getCoinCount(postId);
                out.print("{\"success\": true, \"coined\": true, \"count\": " + newCount + ", \"remainingCoins\": " + user.getCoins() + "}");
            } else {
                out.print("{\"success\": false, \"message\": \"投币失败\"}");
            }
        } catch (NumberFormatException e) {
            out.print("{\"success\": false, \"message\": \"参数错误\"}");
        }
    }
}