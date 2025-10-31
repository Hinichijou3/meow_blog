package com.yourblog.controller;

import com.yourblog.dao.UserDAO;
import com.yourblog.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class UpdateProfileServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String displayName = request.getParameter("displayName");
        String email = request.getParameter("email");
        String bio = request.getParameter("bio");
        
        UserDAO userDao = new UserDAO();
        
        // 更新用户信息
        currentUser.setDisplayName(displayName);
        currentUser.setEmail(email);
        currentUser.setBio(bio);
        
        if (userDao.updateUserProfile(currentUser)) {
            // 更新session中的用户信息
            session.setAttribute("user", currentUser);
            request.setAttribute("success", "资料更新成功！");
        } else {
            request.setAttribute("error", "资料更新失败，请重试");
        }
        
        request.getRequestDispatcher("my-profile.jsp").forward(request, response);
    }
}