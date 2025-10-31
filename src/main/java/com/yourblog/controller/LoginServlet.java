package com.yourblog.controller;

import com.yourblog.dao.UserDAO;
import com.yourblog.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        UserDAO userDao = new UserDAO();
        User user = userDao.validateUser(username, password);
        
        if (user != null) {
            // 登录成功，创建session
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setMaxInactiveInterval(30 * 60); // 30分钟
            
            response.sendRedirect("default.jsp");
        } else {
            // 登录失败
            request.setAttribute("error", "用户名或密码错误");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}