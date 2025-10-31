package com.yourblog.controller;

import com.yourblog.dao.UserDAO;
import com.yourblog.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;


public class UpdatePasswordServlet extends HttpServlet {
    private UserDAO userDao;
    
    @Override
    public void init() {
        userDao = new UserDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        // 检查用户是否登录
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // 获取表单参数
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        System.out.println("=== 密码修改请求 ===");
        System.out.println("用户: " + currentUser.getUsername());
        
        // 验证输入
        if (currentPassword == null || currentPassword.trim().isEmpty()) {
            response.sendRedirect("settings.jsp?error=current_password_required");
            return;
        }
        
        if (newPassword == null || newPassword.trim().isEmpty()) {
            response.sendRedirect("settings.jsp?error=new_password_required");
            return;
        }
        
        if (confirmPassword == null || confirmPassword.trim().isEmpty()) {
            response.sendRedirect("settings.jsp?error=confirm_password_required");
            return;
        }
        
        if (!newPassword.equals(confirmPassword)) {
            response.sendRedirect("settings.jsp?error=passwords_not_match");
            return;
        }
        
        if (newPassword.length() < 6) {
            response.sendRedirect("settings.jsp?error=password_too_short");
            return;
        }
        
        try {
            // 验证当前密码
            boolean isCurrentPasswordValid = userDao.verifyPassword(currentUser.getId(), currentPassword);
            if (!isCurrentPasswordValid) {
                response.sendRedirect("settings.jsp?error=invalid_current_password");
                return;
            }
            
            // 更新密码
            boolean success = userDao.updatePassword(currentUser.getId(), newPassword);
            if (success) {
                System.out.println("✅ 密码修改成功");
                response.sendRedirect("settings.jsp?success=password_updated");
            } else {
                response.sendRedirect("settings.jsp?error=update_failed");
            }
            
        } catch (Exception e) {
            System.err.println("密码修改过程出错: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("settings.jsp?error=server_error");
        }
    }
}