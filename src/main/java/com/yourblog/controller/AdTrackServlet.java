package com.yourblog.controller;

import com.yourblog.dao.AdDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class AdTrackServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String adIdParam = request.getParameter("adId");
        String targetUrl = request.getParameter("targetUrl");
        
        if (adIdParam != null && targetUrl != null) {
            try {
                int adId = Integer.parseInt(adIdParam);
                AdDAO adDao = new AdDAO();
                adDao.incrementClicks(adId);
                
                // 重定向到目标URL
                response.sendRedirect(targetUrl);
                return;
            } catch (NumberFormatException e) {
                // 参数错误，直接重定向
            }
        }
        
        // 如果参数错误，重定向到首页
        response.sendRedirect("default.jsp");
    }
}