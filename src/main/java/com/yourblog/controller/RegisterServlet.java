package com.yourblog.controller;

import com.yourblog.dao.UserDAO;
import com.yourblog.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class RegisterServlet extends HttpServlet {
    
    // 确保有默认构造函数
    public RegisterServlet() {
        super();
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 设置字符编码，防止中文乱码
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String displayName = request.getParameter("displayName");
        String bio = request.getParameter("bio");
        
        System.out.println("注册请求: username=" + username + ", email=" + email);
        
        UserDAO userDao = new UserDAO();
        
        // 检查用户名是否已存在
        if (userDao.findByUsername(username) != null) {
            request.setAttribute("error", "用户名已存在");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
        // 创建新用户
        User newUser = new User();
        newUser.setUsername(username);
        newUser.setEmail(email);
        newUser.setPasswordHash(password); // 注意：实际中应该加密
        newUser.setDisplayName(displayName);
        newUser.setBio(bio);
        newUser.setAvatarUrl("images/avatars/default-avatar.jpg");
        newUser.setHeaderImageUrl("images/headers/default_header.jpg");
        
        if (userDao.createUser(newUser)) {
            // 注册成功，自动登录
            User registeredUser = userDao.findByUsername(username);
            if (registeredUser != null) {
                HttpSession session = request.getSession();
                session.setAttribute("user", registeredUser);
                session.setMaxInactiveInterval(30 * 60); // 30分钟
                System.out.println("用户注册成功: " + username);
            }
            response.sendRedirect("default.jsp");
        } else {
            request.setAttribute("error", "注册失败，请重试");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
    
    // 可选：添加doGet方法处理GET请求
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // 重定向到注册页面
        response.sendRedirect("register.jsp");
    }
}