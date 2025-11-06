package com.yourblog.util;

import com.yourblog.dao.UserDAO;
import com.yourblog.model.User;
import jakarta.servlet.http.HttpSession;

public class UserSessionUtil {
    
    /**
     * 刷新session中的用户信息
     */
    public static void refreshUserInSession(HttpSession session) {
        User currentUser = (User) session.getAttribute("user");
        if (currentUser != null) {
            UserDAO userDao = new UserDAO();
            User freshUser = userDao.findById(currentUser.getId());
            if (freshUser != null) {
                session.setAttribute("user", freshUser);
            }
        }
    }
    
    /**
     * 获取当前用户（带刷新）
     */
    public static User getCurrentUser(HttpSession session) {
        refreshUserInSession(session);
        return (User) session.getAttribute("user");
    }
}