<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.yourblog.model.User, com.yourblog.model.Message, java.util.List, com.yourblog.dao.MessageDAO" %>
<%
// 检查用户是否登录
User currentUser = (User) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

// 获取消息
MessageDAO messageDao = new MessageDAO();
List<Message> messages = messageDao.getMessagesByUserId(currentUser.getId());
int unreadCount = messageDao.getUnreadMessageCount(currentUser.getId());

// 获取当前时间
java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
sdf.setTimeZone(java.util.TimeZone.getTimeZone("Asia/Shanghai"));
String currentTime = sdf.format(new java.util.Date());
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>消息中心 - 多用户博客系统</title>
    <style>
        /* 使用与my-profile.jsp相似的样式 */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            line-height: 1.6; 
            color: #333; 
            background-color: #f5f5f5; 
        }
        .container { 
            max-width: 1200px; 
            margin: 0 auto; 
            padding: 20px; 
        }
        
        /* 头部样式 */
        .profile-header {
            background-image: url('<%= currentUser.getHeaderImageUrl() != null ? currentUser.getHeaderImageUrl() : "images/headers/default-header.jpg" %>');
            background-size: cover;
            background-position: center;
            color: white;
            padding: 80px 0;
            text-align: center;
            border-radius: 10px;
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
        }
        .profile-header::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background-color: rgba(0, 0, 0, 0.4);
            z-index: 1;
        }
        .profile-header > * { 
            position: relative; 
            z-index: 2; 
        }
        
        .profile-avatar { 
            width: 150px; 
            height: 150px; 
            border-radius: 50%; 
            border: 5px solid white; 
            margin-bottom: 20px; 
            object-fit: cover;
        }
        .profile-name { 
            font-size: 2.5em; 
            margin-bottom: 10px; 
        }
        .profile-bio { 
            font-size: 1.2em; 
            opacity: 0.9; 
            max-width: 600px;
            margin: 0 auto;
        }
        
        /* 导航栏样式 */
        nav { 
            background: white; 
            padding: 15px; 
            border-radius: 8px; 
            margin-bottom: 30px; 
            box-shadow: 0 2px 10px rgba(0,0,0,0.1); 
        }
        nav ul { 
            list-style: none; 
            display: flex; 
            justify-content: flex-start; 
            align-items: center;
            gap: 30px; 
        }
        nav a { 
            text-decoration: none; 
            color: #667eea; 
            font-weight: 500; 
            transition: color 0.3s; 
        }
        nav a:hover { 
            color: #764ba2; 
        }
        
        /* 内容区域样式 */
        .messages-content {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .messages-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 2px solid #667eea;
        }
        
        .section-title {
            font-size: 1.8em;
            color: #333;
            margin: 0;
        }
        
        .unread-badge {
            background: #ff4757;
            color: white;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: 500;
        }
        
        .btn {
            display: inline-block;
            background: #667eea;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            text-decoration: none;
            cursor: pointer;
            transition: background 0.3s;
            text-align: center;
            font-size: 0.9em;
        }
        
        .btn:hover {
            background: #764ba2;
        }
        
        .btn-secondary {
            background: #6c757d;
        }
        
        .btn-secondary:hover {
            background: #545b62;
        }
        
        /* 消息列表样式 */
        .messages-list {
            display: grid;
            gap: 15px;
        }
        
        .message-item {
            padding: 20px;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            transition: all 0.3s;
            display: flex;
            gap: 15px;
            align-items: flex-start;
        }
        
        .message-item.unread {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
        }
        
        .message-item:hover {
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transform: translateY(-2px);
        }
        
        .message-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            object-fit: cover;
            flex-shrink: 0;
        }
        
        .message-content {
            flex: 1;
        }
        
        .message-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 8px;
        }
        
        .message-text {
            color: #444;
            line-height: 1.5;
            margin-bottom: 10px;
        }
        
        .message-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: #666;
            font-size: 0.9em;
        }
        
        .message-type {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 0.8em;
            font-weight: 500;
            margin-right: 10px;
        }
        
        .type-like {
            background: #ffebee;
            color: #d32f2f;
        }
        
        .type-coin {
            background: #fff3e0;
            color: #f57c00;
        }
        
        .type-comment {
            background: #e8f5e8;
            color: #388e3c;
        }
        
        .message-actions {
            display: flex;
            gap: 10px;
        }
        
        .action-btn {
            padding: 5px 10px;
            border: none;
            border-radius: 3px;
            cursor: pointer;
            font-size: 0.8em;
            text-decoration: none;
            display: inline-block;
        }
        
        .view-btn {
            background: #667eea;
            color: white;
        }
        
        .delete-btn {
            background: #dc3545;
            color: white;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }
        
        .empty-state h3 {
            margin-bottom: 10px;
            color: #333;
        }
        
        /* 响应式设计 */
        @media (max-width: 768px) {
            .message-header {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .message-meta {
                flex-direction: column;
                align-items: flex-start;
                gap: 5px;
            }
            
            .message-actions {
                margin-top: 10px;
                width: 100%;
                justify-content: flex-end;
            }
            
            nav ul {
                flex-direction: column;
                gap: 15px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- 个性化头部 -->
        <header class="profile-header">
            <img src="<%= currentUser.getAvatarUrl() != null ? currentUser.getAvatarUrl() : "images/avatars/default-avatar.jpg" %>" 
                 alt="用户头像" class="profile-avatar">
            <h1 class="profile-name"><%= currentUser.getDisplayName() %></h1>
            <p class="profile-bio"><%= currentUser.getBio() != null ? currentUser.getBio() : "这个人很懒，什么都没有写～" %></p>
        </header>

        <!-- 导航栏 -->
        <nav>
            <ul>
                <li><a href="default.jsp">首页</a></li>
                <li><a href="my-profile.jsp">个人中心</a></li>
                <li><a href="my-posts.jsp">我的文章</a></li>
                <li><a href="messages.jsp" style="color: #764ba2;">消息 
                    <% if (unreadCount > 0) { %>
                        <span class="unread-badge" style="margin-left: 5px;"><%= unreadCount %></span>
                    <% } %>
                </a></li>
                <li><a href="settings.jsp">设置</a></li>
                
                <div style="margin-left: auto;">
                    <a href="logout">退出登录</a>
                </div>
            </ul>
        </nav>

        <!-- 消息内容区域 -->
        <div class="messages-content">
            <div class="messages-header">
                <h2 class="section-title">消息中心</h2>
                <div style="display: flex; gap: 15px; align-items: center;">
                    <% if (unreadCount > 0) { %>
                        <span class="unread-badge"><%= unreadCount %> 条未读</span>
                        <a href="messages?action=markAllRead" class="btn">标记全部已读</a>
                    <% } %>
                </div>
            </div>
            
            <div class="messages-list">
                <% if (messages != null && !messages.isEmpty()) { %>
                    <% for (Message message : messages) { %>
                    <div class="message-item <%= !message.getIsRead() ? "unread" : "" %>" id="message-<%= message.getId() %>">
                        <!-- 用户头像 -->
                        <img src="<%= message.getSourceAvatarUrl() != null ? message.getSourceAvatarUrl() : "images/avatars/default-avatar.jpg" %>" 
                             alt="用户头像" class="message-avatar">
                        
                        <!-- 消息内容 -->
                        <div class="message-content">
                            <div class="message-header">
                                <div>
                                    <span class="message-type 
                                        <%= "like".equals(message.getType()) ? "type-like" : "" %>
                                        <%= "coin".equals(message.getType()) ? "type-coin" : "" %>
                                        <%= "comment".equals(message.getType()) ? "type-comment" : "" %>">
                                        <%= "like".equals(message.getType()) ? "点赞" : 
                                            "coin".equals(message.getType()) ? "投币" : "评论" %>
                                    </span>
                                    <strong><%= message.getSourceDisplayName() != null ? message.getSourceDisplayName() : message.getSourceUsername() %></strong>
                                </div>
                                <span style="color: #666; font-size: 0.9em;"><%= message.getCreatedAt() %></span>
                            </div>
                            
                            <div class="message-text">
                                <%= message.getContent() %>
                            </div>
                            
                            <div class="message-meta">
                                <div>
                                    <% if (message.getPostId() > 0) { %>
                                        <a href="view-post.jsp?id=<%= message.getPostId() %>" class="action-btn view-btn">查看文章</a>
                                    <% } %>
                                </div>
                                <div class="message-actions">
                                    <% if (!message.getIsRead()) { %>
                                        <form action="messages" method="post" style="display: inline;">
                                            <input type="hidden" name="action" value="markRead">
                                            <input type="hidden" name="messageId" value="<%= message.getId() %>">
                                            <button type="submit" class="action-btn" style="background: #28a745; color: white;">标记已读</button>
                                        </form>
                                    <% } %>
                                    <form action="messages" method="post" style="display: inline;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="messageId" value="<%= message.getId() %>">
                                        <button type="submit" class="action-btn delete-btn" 
                                                onclick="return confirm('确定要删除这条消息吗？')">删除</button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                <% } else { %>
                    <div class="empty-state">
                        <h3>还没有收到消息</h3>
                        <p>当有人点赞、投币或评论你的文章时，消息会显示在这里</p>
                        <a href="default.jsp" class="btn" style="margin-top: 15px; width: auto;">去首页看看</a>
                    </div>
                <% } %>
            </div>
        </div>

        <!-- 页脚 -->
        <footer style="text-align: center; margin-top: 50px; padding: 20px; color: #666; border-top: 1px solid #ddd;">
            <p>
                © 2025 多用户博客系统 | 
                服务器时间：<%= currentTime %> | 
                当前用户：<%= currentUser.getUsername() %>
            </p>
        </footer>
    </div>

    <script>
        // 处理消息操作后的提示
        document.addEventListener('DOMContentLoaded', function() {
            const urlParams = new URLSearchParams(window.location.search);
            const success = urlParams.get('success');
            const error = urlParams.get('error');
            
            if (success === 'deleted') {
                alert('消息删除成功！');
                // 移除URL参数
                window.history.replaceState({}, document.title, window.location.pathname);
            } else if (error === 'invalid_id') {
                alert('操作失败：无效的消息ID');
                window.history.replaceState({}, document.title, window.location.pathname);
            }
        });
    </script>
</body>
</html>