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
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String postIdParam = request.getParameter("post_id");
        String redirectUrl = request.getParameter("redirect_url");
        
        System.out.println("CoinServlet - post_id: " + postIdParam + ", user_id: " + (user != null ? user.getId() : "null"));
        
        if (postIdParam == null) {
            if (redirectUrl != null) {
                response.sendRedirect(redirectUrl + "&error=参数错误");
            } else {
                response.sendRedirect("default.jsp?error=参数错误");
            }
            return;
        }
        
        try {
            int postId = Integer.parseInt(postIdParam);
            CoinDAO coinDao = new CoinDAO();
            PostDAO postDao = new PostDAO();
            
            // 检查用户是否还有硬币
            if (user.getCoins() <= 0) {
                if (redirectUrl != null) {
                    response.sendRedirect(redirectUrl + "&error=硬币不足");
                } else {
                    response.sendRedirect("view-post.jsp?id=" + postId + "&error=硬币不足");
                }
                return;
            }
            
            // 检查是否已投币
            if (coinDao.hasCoined(user.getId(), postId)) {
                if (redirectUrl != null) {
                    response.sendRedirect(redirectUrl + "&error=已投过币");
                } else {
                    response.sendRedirect("view-post.jsp?id=" + postId + "&error=已投过币");
                }
                return;
            }
            
            // 获取文章作者信息
            Post post = postDao.getPostById(postId);
            if (post == null) {
                if (redirectUrl != null) {
                    response.sendRedirect(redirectUrl + "&error=文章不存在");
                } else {
                    response.sendRedirect("default.jsp?error=文章不存在");
                }
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
                
                if (redirectUrl != null) {
                    response.sendRedirect(redirectUrl + "&success=投币成功");
                } else {
                    response.sendRedirect("view-post.jsp?id=" + postId + "&success=投币成功");
                }
            } else {
                if (redirectUrl != null) {
                    response.sendRedirect(redirectUrl + "&error=投币失败");
                } else {
                    response.sendRedirect("view-post.jsp?id=" + postId + "&error=投币失败");
                }
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