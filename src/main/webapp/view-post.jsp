<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.yourblog.model.User, com.yourblog.model.Post, com.yourblog.dao.PostDAO, com.yourblog.dao.UserDAO, com.yourblog.dao.CommentDAO, com.yourblog.dao.MessageDAO, com.yourblog.model.Comment, java.util.List" %>
<%@ page import="com.yourblog.dao.FavoriteDAO, com.yourblog.dao.LikeDAO, com.yourblog.dao.CoinDAO" %>
<%@ page import="com.yourblog.util.UserSessionUtil" %>
<%
// 获取当前登录用户（带自动刷新）
User currentUser = (User) session.getAttribute("user");

// 获取文章ID
String postIdParam = request.getParameter("id");
Post post = null;
User author = null;
int commentCount = 0;
List<Comment> comments = null;

// 互动功能相关变量
boolean isFavorited = false;
boolean isLiked = false;
boolean isCoined = false;
int likeCount = 0;
int coinCount = 0;
int userCoins = 0;

if (postIdParam != null && !postIdParam.isEmpty()) {
    try {
        int postId = Integer.parseInt(postIdParam);
        PostDAO postDao = new PostDAO();
        post = postDao.getPostById(postId);
        
        if (post != null) {
            // 获取作者信息
            UserDAO userDao = new UserDAO();
            author = userDao.findById(post.getUserId());
            
            // 获取评论信息和数量
            CommentDAO commentDao = new CommentDAO();
            comments = commentDao.getCommentsByPostId(postId);
            commentCount = commentDao.getCommentCountByPostId(postId);
            
            // 获取互动状态和计数
            FavoriteDAO favoriteDao = new FavoriteDAO();
            LikeDAO likeDao = new LikeDAO();
            CoinDAO coinDao = new CoinDAO();
            
            if (currentUser != null) {
                isFavorited = favoriteDao.isFavorited(currentUser.getId(), postId);
                isLiked = likeDao.isLiked(currentUser.getId(), postId);
                isCoined = coinDao.hasCoined(currentUser.getId(), postId);
                userCoins = coinDao.getUserCoins(currentUser.getId());
            }
            
            likeCount = likeDao.getLikeCount(postId);
            coinCount = coinDao.getCoinCount(postId);
            
            // 增加阅读量（只有已发布文章才增加）
            if ("published".equals(post.getStatus())) {
                postDao.incrementViewCount(postId);
            }
        }
    } catch (NumberFormatException e) {
        // 处理ID格式错误
    }
}

// 如果文章不存在，跳转到首页
if (post == null) {
    response.sendRedirect("default.jsp?error=文章不存在");
    return;
}

// 检查权限：只有已发布文章或作者本人可以查看
boolean canView = "published".equals(post.getStatus()) || 
                 (currentUser != null && currentUser.getId() == post.getUserId());

if (!canView) {
    response.sendRedirect("default.jsp?error=无权查看此文章");
    return;
}

// 获取当前时间
java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
String currentTime = sdf.format(new java.util.Date());
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= post.getTitle() %> - 多用户博客系统</title>
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v6.6.0/css/all.css">
    <style>
        /* 重置和基础样式 - 与default.jsp保持一致 */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        /* 全局背景图样式 */
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            line-height: 1.6; 
            color: #333; 
            background-image: url('images/backgrounds/blog-bg.jpg');
            background-size: cover;
            background-position: center top;
            background-attachment: scroll;
            background-repeat: no-repeat;
            min-height: 100vh;
            background-color: #f5f5f5;
        }
        
        body::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 200%;
            background-image: inherit;
            background-size: cover;
            background-position: center top;
            background-attachment: scroll;
            z-index: -1;
            pointer-events: none;
        }
        
        .container { 
            max-width: 1200px; 
            margin: 0 auto; 
            padding: 20px; 
            position: relative;
            z-index: 1;
        }
        
        /* 头部样式 */
        .page-header {
            background-image: url('<%= currentUser != null && currentUser.getHeaderImageUrl() != null ? currentUser.getHeaderImageUrl() : "images/default_header.jpg" %>');
            background-size: cover;
            background-position: center;
            color: white;
            padding: 60px 0;
            text-align: center;
            border-radius: 10px;
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        
        .page-title {
            font-size: 2.5em;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
        }
        
        .page-subtitle {
            font-size: 1.2em;
            opacity: 0.9;
            text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.5);
        }
        
        /* 导航栏样式 */
        nav { 
            background: rgba(255, 255, 255, 0.95); 
            padding: 15px; 
            border-radius: 12px; 
            margin-bottom: 30px; 
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.3);
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
            transition: all 0.3s ease;
            padding: 8px 16px;
            border-radius: 6px;
        }
        
        nav a:hover { 
            color: #764ba2; 
            background: rgba(102, 126, 234, 0.1);
            transform: translateY(-2px);
        }
        
        /* 用户信息样式 */
        .user-info {
            margin-left: auto;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .user-avatar {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #667eea;
        }
        
        .user-menu {
            display: flex;
            gap: 15px;
            align-items: center;
        }
        
        .user-welcome {
            color: #555;
            font-weight: 500;
        }
        
        /* 硬币信息样式 */
        .coins-info {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 5px 12px;
            background: rgba(255, 215, 0, 0.1);
            border-radius: 20px;
            border: 1px solid rgba(255, 215, 0, 0.3);
        }
        
        .get-coin-btn-nav {
            background: #28a745;
            color: white;
            border: none;
            padding: 4px 8px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 11px;
            transition: all 0.3s ease;
        }
        
        .get-coin-btn-nav:hover {
            background: #218838;
            transform: translateY(-1px);
        }
        
        /* 文章容器样式 */
        .post-container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.3);
            overflow: hidden;
            margin-bottom: 30px;
        }
        
        .post-header {
            padding: 30px;
            border-bottom: 1px solid rgba(221, 221, 221, 0.5);
        }
        
        .post-title {
            color: #333;
            font-size: 2em;
            margin-bottom: 15px;
            font-weight: 600;
        }
        
        .post-status {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.7em;
            font-weight: 500;
            margin-left: 10px;
            vertical-align: middle;
        }
        
        .status-draft {
            background: #ffc107;
            color: #333;
        }
        
        .post-meta {
            color: #666;
            font-size: 0.9em;
            margin-bottom: 20px;
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
        }
        
        .author-info {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 15px;
            background: rgba(245, 245, 245, 0.8);
            border-radius: 8px;
        }
        
        .author-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #667eea;
        }
        
        .author-name {
            font-weight: 600;
            color: #333;
        }
        
        .post-content {
            padding: 30px;
            line-height: 1.8;
            font-size: 1.1em;
        }
        
        .post-content h1, .post-content h2, .post-content h3 {
            margin: 25px 0 15px 0;
            color: #333;
        }
        
        .post-content p {
            margin-bottom: 15px;
        }
        
        .post-content code {
            background: #f8f9fa;
            padding: 2px 6px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            color: #e83e8c;
        }
        
        .post-content pre {
            background: #2d2d2d;
            color: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            overflow-x: auto;
            margin: 20px 0;
        }
        
        .post-content blockquote {
            border-left: 4px solid #667eea;
            padding-left: 20px;
            margin: 20px 0;
            color: #666;
            font-style: italic;
        }
        
        /* 互动按钮区域 */
        .interaction-buttons {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin: 30px 0;
            padding: 20px;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
        
        .interaction-btn {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
            padding: 15px 25px;
            border: 2px solid #e9ecef;
            border-radius: 10px;
            background: white;
            cursor: pointer;
            transition: all 0.3s ease;
            min-width: 100px;
            text-decoration: none;
            color: inherit;
        }
        
        .interaction-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .interaction-btn.active {
            border-color: #667eea;
            background: #f8f9ff;
        }
        
        .interaction-icon {
            font-size: 1.5em;
            margin-bottom: 5px;
        }
        
        .interaction-count {
            font-weight: 600;
            color: #333;
            font-size: 1.1em;
        }
        
        .interaction-text {
            color: #666;
            font-size: 0.9em;
        }
        
        .btn-favorite.active .interaction-icon {
            color: #ff6b6b;
        }
        
        .btn-like.active .interaction-icon {
            color: #4ecdc4;
        }
        
        .btn-coin.active .interaction-icon {
            color: #ffd93d;
        }
        
        .coin-info {
            background: rgba(255, 243, 205, 0.9);
            border: 1px solid #ffeaa7;
            border-radius: 8px;
            padding: 15px;
            margin: 20px 0;
            text-align: center;
            font-size: 0.9em;
            color: #856404;
            backdrop-filter: blur(10px);
        }
        
        .btn-disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }
        
        .btn-disabled:hover {
            transform: none;
            box-shadow: none;
        }
        
        /* 操作按钮区域 */
        .post-actions-container {
            margin: 30px 0;
        }
        
        .post-actions {
            display: flex;
            gap: 15px;
            justify-content: center;
        }
        
        .btn {
            display: inline-block;
            padding: 12px 24px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
        }
        
        .btn-primary {
            background: #667eea;
            color: white;
        }
        
        .btn-primary:hover {
            background: #764ba2;
            transform: translateY(-2px);
        }
        
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #545b62;
            transform: translateY(-2px);
        }
        
        /* 评论区域 */
        .comments-section {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.3);
            margin-bottom: 30px;
        }
        
        .comment-form {
            margin-bottom: 30px;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 1em;
            transition: all 0.3s ease;
            resize: vertical;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .comments-list {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }
        
        .comment-item {
            display: flex;
            gap: 15px;
            padding: 20px;
            background: rgba(248, 249, 250, 0.8);
            border-radius: 8px;
            transition: all 0.3s ease;
        }
        
        .comment-item:hover {
            background: rgba(248, 249, 250, 1);
            transform: translateY(-2px);
        }
        
        .comment-avatar img {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #667eea;
        }
        
        .comment-content {
            flex: 1;
        }
        
        .comment-header {
            margin-bottom: 8px;
        }
        
        .comment-body {
            color: #333;
            line-height: 1.6;
        }
        
        .comment-actions {
            margin-top: 10px;
            display: flex;
            gap: 15px;
        }
        
        .btn-reply, .btn-delete {
            background: none;
            border: none;
            color: #667eea;
            cursor: pointer;
            font-size: 0.9em;
            padding: 4px 8px;
            border-radius: 4px;
            transition: all 0.3s ease;
        }
        
        .btn-reply:hover, .btn-delete:hover {
            background: rgba(102, 126, 234, 0.1);
        }
        
        .btn-delete {
            color: #dc3545;
        }
        
        .btn-delete:hover {
            background: rgba(220, 53, 69, 0.1);
        }
        
        /* 页脚样式 */
        footer { 
            text-align: center; 
            margin-top: 50px; 
            padding: 20px; 
            color: #666; 
            border-top: 1px solid rgba(221, 221, 221, 0.5);
            background: rgba(255, 255, 255, 0.9);
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        
        /* 背景渐变过渡效果 */
        .background-transition {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(
                to bottom,
                rgba(245, 245, 245, 0) 0%,
                rgba(245, 245, 245, 0.8) 50%,
                rgba(245, 245, 245, 1) 100%
            );
            pointer-events: none;
            z-index: 0;
        }
        
        /* 响应式设计 */
        @media (max-width: 768px) {
            .container {
                padding: 15px;
            }
            
            nav ul {
                flex-direction: column;
                gap: 15px;
            }
            
            .user-info {
                margin-left: 0;
                justify-content: center;
            }
            
            .user-menu {
                flex-direction: column;
                gap: 10px;
            }
            
            .page-title {
                font-size: 1.8em;
            }
            
            .post-header {
                padding: 20px;
            }
            
            .post-title {
                font-size: 1.5em;
            }
            
            .post-meta {
                flex-direction: column;
                gap: 5px;
            }
            
            .interaction-buttons {
                flex-direction: column;
                gap: 10px;
            }
            
            .interaction-btn {
                flex-direction: row;
                justify-content: space-between;
                min-width: auto;
            }
            
            .post-actions {
                flex-direction: column;
            }
            
            .comment-item {
                flex-direction: column;
                text-align: center;
            }
            
            /* 移动端取消背景滚动效果，改为固定背景 */
            body {
                background-attachment: fixed;
            }
            
            body::before {
                display: none;
            }
        }
    </style>
</head>
<body>
    <!-- 背景渐变过渡层 -->
    <div class="background-transition"></div>
    
    <div class="container">
        <!-- 个性化头部 -->
        <header class="page-header">
            <h1 class="page-title"><%= post.getTitle() %></h1>
            <p class="page-subtitle">作者: <%= author != null ? author.getDisplayName() : "未知作者" %></p>
        </header>

        <!-- 导航栏 -->
        <nav>
            <ul>
                <li><a href="default.jsp">首页</a></li>
                <li><a href="store.jsp">广告商店</a></li>
                <% if (currentUser != null) { %>
                    <li><a href="my-profile.jsp">个人中心</a></li>
                    <li><a href="my-posts.jsp">我的文章</a></li>
                <% } %>
                <li>
                    <a href="messages.jsp">消息
                        <% if (currentUser != null) { 
                            MessageDAO msgDao = new MessageDAO();
                            int unreadMsgCount = msgDao.getUnreadMessageCount(currentUser.getId());
                            if (unreadMsgCount > 0) { 
                        %>
                            <span style="background: #ff4757; color: white; border-radius: 50%; padding: 2px 6px; font-size: 0.8em; margin-left: 5px;">
                                <%= unreadMsgCount %>
                            </span>
                        <%   }
                          } %>
                    </a>
                </li>
                <li><a href="settings.jsp">设置</a></li>
                
                <!-- 用户信息区域 -->
                <div class="user-info">
                    <% if (currentUser != null) { %>
                        <div class="user-menu">
                            <!-- 硬币信息 -->
                            <div class="coins-info">
                                <span style="color: #ffd700; font-weight: bold;">🪙</span>
                                <span id="navUserCoins" style="color: #555; font-weight: 500;"><%= currentUser.getCoins() %></span>
                                <% if (!new CoinDAO().hasLoggedInToday(currentUser.getId())) { %>
                                    <button class="get-coin-btn-nav" onclick="getDailyCoinNav()">
                                        领取硬币
                                    </button>
                                <% } %>
                            </div>
                            
                            <img src="<%= currentUser.getAvatarUrl() != null ? currentUser.getAvatarUrl() : "images/avatars/default-avatar.jpg" %>" 
                                 alt="用户头像" class="user-avatar">
                            <span class="user-welcome">欢迎, <%= currentUser.getDisplayName() %></span>
                            <a href="logout">退出</a>
                        </div>
                    <% } else { %>
                        <div class="user-menu">
                            <a href="login.jsp">登录</a>
                            <a href="register.jsp">注册</a>
                        </div>
                    <% } %>
                </div>
            </ul>
        </nav>
        <!-- 显示操作消息 -->
		<%
		String success = request.getParameter("success");
		String error = request.getParameter("error");
		if (success != null) {
		%>
		<div class="alert alert-success" style="margin: 15px 0; padding: 12px 20px; background: #d4edda; color: #155724; border: 1px solid #c3e6cb; border-radius: 5px;">
		    <%= success %>
		</div>
		<%
		} else if (error != null) {
		%>
		<div class="alert alert-error" style="margin: 15px 0; padding: 12px 20px; background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; border-radius: 5px;">
		    <%= error %>
		</div>
		<%
		}
		%>

        <!-- 文章内容 -->
        <div class="post-container">
            <div class="post-header">
                <h1 class="post-title">
                    <%= post.getTitle() %>
                    <% if (!"published".equals(post.getStatus())) { %>
                        <span class="post-status status-draft">草稿</span>
                    <% } %>
                </h1>
                <div class="post-meta">
                    <span><i class="far fa-calendar"></i> 发布时间: <%= post.getCreatedAt() %></span>
                    <span><i class="far fa-eye"></i> 阅读量: <%= post.getViewCount() %></span>
                    <% if (post.getUpdatedAt() != null && !post.getUpdatedAt().equals(post.getCreatedAt())) { %>
                        <span><i class="far fa-edit"></i> 最后更新: <%= post.getUpdatedAt() %></span>
                    <% } %>
                </div>
                <div class="author-info">
                    <img src="<%= author != null && author.getAvatarUrl() != null ? author.getAvatarUrl() : "images/avatars/default-avatar.jpg" %>" 
                         alt="作者头像" class="author-avatar">
                    <div>
                        <div class="author-name"><%= author != null ? author.getDisplayName() : "未知作者" %></div>
                        <% if (author != null && author.getBio() != null && !author.getBio().isEmpty()) { %>
                            <div style="color: #666; font-size: 0.9em;"><%= author.getBio() %></div>
                        <% } %>
                    </div>
                </div>
            </div>
            
            <div class="post-content">
                <%= formatPostContent(post.getContent()) %>
            </div>
        </div>

        <!-- 互动按钮区域 -->
		<div class="interaction-buttons">
		    <!-- 收藏按钮 -->
		    <% if (currentUser != null) { %>
		        <form action="favorite" method="POST" style="display: inline;">
		            <input type="hidden" name="action" value="<%= isFavorited ? "unfavorite" : "favorite" %>">
		            <input type="hidden" name="post_id" value="<%= post.getId() %>">
		            <input type="hidden" name="user_id" value="<%= currentUser.getId() %>">
		            <input type="hidden" name="redirect_url" value="view-post.jsp?id=<%= post.getId() %>">
		            <button type="submit" class="interaction-btn btn-favorite <%= isFavorited ? "active" : "" %>">
		                <div class="interaction-icon">❤</div>
		                <div class="interaction-text"><%= isFavorited ? "已收藏" : "收藏" %></div>
		            </button>
		        </form>
		    <% } else { %>
		        <a href="login.jsp" class="interaction-btn btn-favorite">
		            <div class="interaction-icon">❤</div>
		            <div class="interaction-text">收藏</div>
		        </a>
		    <% } %>
		    
		    <!-- 点赞按钮 -->
		    <% if (currentUser != null) { %>
		        <form action="like" method="POST" style="display: inline;">
		            <input type="hidden" name="action" value="<%= isLiked ? "unlike" : "like" %>">
		            <input type="hidden" name="post_id" value="<%= post.getId() %>">
		            <input type="hidden" name="user_id" value="<%= currentUser.getId() %>">
		            <input type="hidden" name="redirect_url" value="view-post.jsp?id=<%= post.getId() %>">
		            <button type="submit" class="interaction-btn btn-like <%= isLiked ? "active" : "" %>">
		                <div class="interaction-icon">👍</div>
		                <div class="interaction-count"><%= likeCount %></div>
		                <div class="interaction-text"><%= isLiked ? "已点赞" : "点赞" %></div>
		            </button>
		        </form>
		    <% } else { %>
		        <a href="login.jsp" class="interaction-btn btn-like">
		            <div class="interaction-icon">👍</div>
		            <div class="interaction-count"><%= likeCount %></div>
		            <div class="interaction-text">点赞</div>
		        </a>
		    <% } %>
		    
		    <!-- 投币按钮 -->
		    <% if (currentUser != null) { %>
		        <% if (isCoined) { %>
		            <div class="interaction-btn btn-coin active btn-disabled">
		                <div class="interaction-icon">🪙</div>
		                <div class="interaction-count"><%= coinCount %></div>
		                <div class="interaction-text">已投币</div>
		            </div>
		        <% } else if (userCoins > 0) { %>
		            <form action="coin" method="POST" style="display: inline;" onsubmit="return confirm('确定要投币吗？这将消耗1个硬币。')">
		                <input type="hidden" name="post_id" value="<%= post.getId() %>">
		                <input type="hidden" name="to_user_id" value="<%= author != null ? author.getId() : 0 %>">
		                <input type="hidden" name="from_user_id" value="<%= currentUser.getId() %>">
		                <input type="hidden" name="redirect_url" value="view-post.jsp?id=<%= post.getId() %>">
		                <button type="submit" class="interaction-btn btn-coin">
		                    <div class="interaction-icon">🪙</div>
		                    <div class="interaction-count"><%= coinCount %></div>
		                    <div class="interaction-text">投币</div>
		                </button>
		            </form>
		        <% } else { %>
		            <div class="interaction-btn btn-coin btn-disabled">
		                <div class="interaction-icon">🪙</div>
		                <div class="interaction-count"><%= coinCount %></div>
		                <div class="interaction-text">硬币不足</div>
		            </div>
		        <% } %>
		    <% } else { %>
		        <a href="login.jsp" class="interaction-btn btn-coin">
		            <div class="interaction-icon">🪙</div>
		            <div class="interaction-count"><%= coinCount %></div>
		            <div class="interaction-text">投币</div>
		        </a>
		    <% } %>
		</div>

        <!-- 硬币信息显示 -->
        <% if (currentUser != null) { %>
            <div class="coin-info">
                <i class="fas fa-coins"></i> 您的硬币数量: <strong><%= userCoins %></strong>
                <% if (userCoins == 0) { %>
                    <span style="display: block; margin-top: 5px; font-size: 0.8em;">
                        每日登录可领取硬币，快去登录吧！
                    </span>
                <% } %>
            </div>
        <% } %>

        <!-- 操作按钮区域 -->
        <div class="post-actions-container">
            <div class="post-actions">
                <a href="default.jsp" class="btn btn-secondary"><i class="fas fa-arrow-left"></i> 返回首页</a>
                <% if (currentUser != null && currentUser.getId() == post.getUserId()) { %>
                    <a href="edit-post.jsp?id=<%= post.getId() %>" class="btn btn-primary"><i class="fas fa-edit"></i> 编辑文章</a>
                <% } %>
                <% if (currentUser != null) { %>
                    <a href="my-profile.jsp" class="btn btn-secondary"><i class="fas fa-user"></i> 个人中心</a>
                <% } %>
            </div>
        </div>

        <!-- 评论区域 -->
        <div class="comments-section">
            <h2 style="margin-bottom: 25px; color: #333; border-bottom: 2px solid #667eea; padding-bottom: 10px;">
                <i class="far fa-comments"></i> 评论 
                <span style="color: #667eea; font-size: 0.8em;">(<%= commentCount %>)</span>
            </h2>
            
            <!-- 评论表单 -->
            <div class="comment-form">
                <form id="commentForm" action="add-comment" method="post">
                    <input type="hidden" name="post_id" value="<%= post.getId() %>">
                    <div class="form-group">
                        <textarea id="commentContent" name="content" class="form-control" 
                                  placeholder="写下您的评论..." rows="4" required></textarea>
                    </div>
                    <div style="display: flex; justify-content: flex-end; gap: 10px;">
                        <button type="button" class="btn btn-secondary" onclick="clearComment()">取消</button>
                        <button type="submit" class="btn btn-primary">发表评论</button>
                    </div>
                </form>
            </div>
            
            <!-- 评论列表 -->
            <div class="comments-list">
                <% if (comments != null && !comments.isEmpty()) { %>
                    <% for (Comment comment : comments) { %>
                    <div class="comment-item">
                        <div class="comment-avatar">
                            <img src="<%= comment.getAvatarUrl() != null ? comment.getAvatarUrl() : "images/avatars/default-avatar.jpg" %>" 
                                 alt="用户头像">
                        </div>
                        <div class="comment-content">
                            <div class="comment-header">
                                <strong style="color: #333;"><%= comment.getDisplayName() != null ? comment.getDisplayName() : comment.getUsername() %></strong>
                                <span style="color: #666; font-size: 0.9em; margin-left: 10px;">
                                    <i class="far fa-clock"></i> <%= comment.getCreatedAt() %>
                                </span>
                            </div>
                            <div class="comment-body">
                                <%= comment.getContent() %>
                            </div>
                            <div class="comment-actions">
                                <button type="button" class="btn-reply"
                                        onclick="replyToComment(<%= comment.getId() %>, '<%= comment.getDisplayName() != null ? comment.getDisplayName() : comment.getUsername() %>')">
                                    <i class="fas fa-reply"></i> 回复
                                </button>
                                <% if (currentUser != null && currentUser.getId() == comment.getUserId()) { %>
                                    <button type="button" class="btn-delete"
                                            onclick="deleteComment(<%= comment.getId() %>, <%= post.getId() %>)">
                                        <i class="fas fa-trash"></i> 删除
                                    </button>
                                <% } %>
                            </div>
                        </div>
                    </div>
                    <% } %>
                <% } else { %>
                    <div style="text-align: center; padding: 40px; color: #666;">
                        <i class="far fa-comment-dots" style="font-size: 3em; margin-bottom: 15px; opacity: 0.5;"></i>
                        <p>暂无评论，快来发表第一条评论吧！</p>
                    </div>
                <% } %>
            </div>
        </div>

        <!-- 页脚 -->
        <footer>
            <p>
                © 2025 多用户博客系统 | 
                服务器时间：<%= currentTime %> | 
                <% if (currentUser != null) { %>
                    当前用户：<%= currentUser.getUsername() %>
                <% } else { %>
                    游客模式
                <% } %>
            </p>
        </footer>
    </div>

    <script>
        // 导航栏领取每日硬币
        function getDailyCoinNav() {
            fetch('daily-coin', {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // 更新导航栏硬币数量
                    document.getElementById('navUserCoins').textContent = data.coins;
                    // 隐藏领取按钮
                    document.querySelector('.get-coin-btn-nav').style.display = 'none';
                    alert('成功领取1个硬币！');
                } else {
                    alert(data.message);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('领取失败');
            });
        }
        
        // 页面加载完成后检查硬币状态
        document.addEventListener('DOMContentLoaded', function() {
            // 为pre标签内的code添加类名
            const codeBlocks = document.querySelectorAll('pre code');
            codeBlocks.forEach(block => {
                block.classList.add('language-text');
            });
            
            // 处理图片加载失败
            const images = document.querySelectorAll('.post-content img');
            images.forEach(img => {
                img.addEventListener('error', function() {
                    this.src = 'images/placeholder.jpg';
                    this.alt = '图片加载失败';
                });
            });
        });

        // 评论功能JavaScript
        function clearComment() {
            document.getElementById('commentContent').value = '';
        }

        function replyToComment(commentId, username) {
            const contentTextarea = document.getElementById('commentContent');
            contentTextarea.value = '@' + username + ' ';
            contentTextarea.focus();
            
            // 添加隐藏的parent_id字段
            let parentIdInput = document.querySelector('input[name="parent_id"]');
            if (!parentIdInput) {
                parentIdInput = document.createElement('input');
                parentIdInput.type = 'hidden';
                parentIdInput.name = 'parent_id';
                document.getElementById('commentForm').appendChild(parentIdInput);
            }
            parentIdInput.value = commentId;
            
            // 滚动到评论框
            contentTextarea.scrollIntoView({ behavior: 'smooth' });
        }

        function deleteComment(commentId, postId) {
            if (confirm('确定要删除这条评论吗？')) {
                fetch('delete-comment', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'id=' + commentId
                })
                .then(response => {
                    if (response.ok) {
                        window.location.href = 'view-post.jsp?id=' + postId + '&success=评论删除成功';
                    } else {
                        alert('删除失败，请重试');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('删除失败，请重试');
                });
            }
        }

        // 表单提交处理
        document.getElementById('commentForm').addEventListener('submit', function(e) {
            const content = document.getElementById('commentContent').value.trim();
            if (content === '') {
                e.preventDefault();
                alert('评论内容不能为空');
                return;
            }
        });
    </script>
</body>
</html>

<%!
// 格式化文章内容的JSP声明方法
private String formatPostContent(String content) {
    if (content == null) return "";
    
    // 处理换行
    content = content.replaceAll("\r\n", "\n").replaceAll("\r", "\n");
    
    // 处理Markdown格式（简化版）
    content = content.replaceAll("\\*\\*(.*?)\\*\\*", "<strong>$1</strong>");
    content = content.replaceAll("\\*(.*?)\\*", "<em>$1</em>");
    content = content.replaceAll("\\`(.*?)\\`", "<code>$1</code>");
    
    // 处理标题
    content = content.replaceAll("^# (.*?)$", "<h1>$1</h1>");
    content = content.replaceAll("^## (.*?)$", "<h2>$2</h2>");
    content = content.replaceAll("^### (.*?)$", "<h3>$3</h3>");
    
    // 处理列表
    content = content.replaceAll("^- (.*?)$", "<li>$1</li>");
    content = content.replaceAll("(?s)(<li>.*?</li>)", "<ul>$1</ul>");
    
    // 处理引用
    content = content.replaceAll("^> (.*?)$", "<blockquote>$1</blockquote>");
    
    // 处理代码块
    content = content.replaceAll("(?s)```(.*?)```", "<pre><code>$1</code></pre>");
    
    // 处理段落
    content = content.replaceAll("(?m)^([^<].*[^>])$", "<p>$1</p>");
    
    // 处理换行
    content = content.replaceAll("\n\n", "</p><p>");
    content = content.replaceAll("\n", "<br>");
    
    return content;
}
%>