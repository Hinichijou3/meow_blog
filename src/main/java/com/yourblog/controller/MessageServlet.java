package com.yourblog.controller;

import com.yourblog.dao.MessageDAO;
import com.yourblog.model.Message;
import com.yourblog.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;


public class MessageServlet extends HttpServlet {
    private MessageDAO messageDao;
    
    @Override
    public void init() {
        messageDao = new MessageDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        // 检查用户是否登录
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("markAllRead".equals(action)) {
            // 标记所有消息为已读
            messageDao.markAllAsRead(currentUser.getId());
            response.sendRedirect("messages.jsp");
            return;
        }
        
        // 获取用户消息
        List<Message> messages = messageDao.getMessagesByUserId(currentUser.getId());
        int unreadCount = messageDao.getUnreadMessageCount(currentUser.getId());
        
        request.setAttribute("messages", messages);
        request.setAttribute("unreadCount", unreadCount);
        request.getRequestDispatcher("messages.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        String messageIdStr = request.getParameter("messageId");
        
        if ("markRead".equals(action) && messageIdStr != null) {
            try {
                int messageId = Integer.parseInt(messageIdStr);
                messageDao.markAsRead(messageId, currentUser.getId());
                response.sendRedirect("messages.jsp");
            } catch (NumberFormatException e) {
                response.sendRedirect("messages.jsp?error=invalid_id");
            }
        } else if ("delete".equals(action) && messageIdStr != null) {
            try {
                int messageId = Integer.parseInt(messageIdStr);
                messageDao.deleteMessage(messageId, currentUser.getId());
                response.sendRedirect("messages.jsp?success=deleted");
            } catch (NumberFormatException e) {
                response.sendRedirect("messages.jsp?error=invalid_id");
            }
        } else {
            response.sendRedirect("messages.jsp");
        }
    }
}