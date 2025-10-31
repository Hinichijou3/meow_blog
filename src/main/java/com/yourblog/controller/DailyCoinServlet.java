package com.yourblog.controller;

import com.yourblog.dao.CoinDAO;
import com.yourblog.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

public class DailyCoinServlet extends HttpServlet {
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
        
        CoinDAO coinDao = new CoinDAO();
        
        // 检查今日是否已领取
        if (coinDao.hasLoggedInToday(user.getId())) {
            out.print("{\"success\": false, \"message\": \"今日已领取过硬币\"}");
            return;
        }
        
        // 赠送硬币
        if (coinDao.updateLoginAndGiveCoin(user.getId())) {
            // 更新session中的用户信息
            user.setCoins(user.getCoins() + 1);
            session.setAttribute("user", user);
            out.print("{\"success\": true, \"coins\": " + user.getCoins() + "}");
        } else {
            out.print("{\"success\": false, \"message\": \"领取失败\"}");
        }
    }
}