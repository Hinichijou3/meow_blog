<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.yourblog.model.User, com.yourblog.model.Post, com.yourblog.dao.PostDAO, com.yourblog.dao.UserDAO, com.yourblog.dao.CommentDAO, com.yourblog.dao.MessageDAO, com.yourblog.model.Comment, java.util.List" %>
<%
// 获取文章ID
String postIdParam = request.getParameter("id");
Post post = null;
User author = null;
int commentCount = 0;
List<Comment> comments = null;

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
            
            // 增加阅读量（只有已发布文章才增加）
            if ("published".equals(post.getStatus())) {
                postDao.incrementViewCount(postId);
            }
        }
    } catch (NumberFormatException e) {
        // 处理ID格式错误
    }
}

// 检查用户是否登录
User currentUser = (User) session.getAttribute("user");

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
    <style>
        /* 基础样式 */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            line-height: 1.6; 
            color: #333; 
            background-color: #f5f5f5; 
        }
        .container { 
            max-width: 800px; 
            margin: 0 auto; 
            padding: 20px; 
        }
        
        /* 头部样式 */
        .page-header {
            background-image: url('<%= author != null && author.getHeaderImageUrl() != null ? author.getHeaderImageUrl() : "images/headers/default-header.jpg" %>');
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
        .page-header::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background-color: rgba(0, 0, 0, 0.4);
            z-index: 1;
        }
        .page-header > * { 
            position: relative; 
            z-index: 2; 
        }
        
        .page-title { 
            font-size: 2.5em; 
            margin-bottom: 15px; 
            text-shadow: 0 2px 4px rgba(0,0,0,0.5);
        }
        .page-subtitle { 
            font-size: 1.2em; 
            opacity: 0.9; 
            text-shadow: 0 1px 2px rgba(0,0,0,0.5);
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
        
        /* 文章内容样式 */
        .post-container {
            background: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        .post-header {
            text-align: center;
            margin-bottom: 40px;
            padding-bottom: 30px;
            border-bottom: 2px solid #e9ecef;
        }
        
        .post-title {
            font-size: 2.2em;
            color: #333;
            margin-bottom: 15px;
            line-height: 1.3;
        }
        
        .post-meta {
            color: #666;
            font-size: 1em;
            display: flex;
            justify-content: center;
            gap: 20px;
            flex-wrap: wrap;
        }
        
        .author-info {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-top: 20px;
        }
        
        .author-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            object-fit: cover;
        }
        
        .author-name {
            font-weight: 500;
            color: #333;
        }
        
        .post-content {
            font-size: 1.1em;
            line-height: 1.8;
            color: #444;
        }
        
        .post-content h1, .post-content h2, .post-content h3 {
            margin-top: 30px;
            margin-bottom: 15px;
            color: #333;
        }
        
        .post-content h1 { font-size: 1.8em; }
        .post-content h2 { font-size: 1.5em; }
        .post-content h3 { font-size: 1.3em; }
        
        .post-content p {
            margin-bottom: 20px;
        }
        
        .post-content ul, .post-content ol {
            margin-bottom: 20px;
            padding-left: 30px;
        }
        
        .post-content li {
            margin-bottom: 8px;
        }
        
        .post-content blockquote {
            border-left: 4px solid #667eea;
            padding-left: 20px;
            margin: 20px 0;
            color: #666;
            font-style: italic;
        }
        
        .post-content code {
            background: #f8f9fa;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
            font-size: 0.9em;
        }
        
        .post-content pre {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 5px;
            overflow-x: auto;
            margin: 20px 0;
        }
        
        .post-content pre code {
            background: none;
            padding: 0;
        }
        
        .post-content img {
            max-width: 100%;
            height: auto;
            border-radius: 5px;
            margin: 20px 0;
        }
        
        .post-status {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 4px;
            font-size: 0.8em;
            font-weight: 500;
            margin-left: 10px;
        }
        
        .status-published {
            background: #d4edda;
            color: #155724;
        }
        
        .status-draft {
            background: #fff3cd;
            color: #856404;
        }
        
        /* 操作按钮容器 */
        .post-actions-container {
            margin-bottom: 30px;
        }
        
        /* 操作按钮 */
        .post-actions {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
            padding: 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .btn {
            display: inline-block;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.3s;
            font-size: 1em;
            font-weight: 500;
        }
        
        .btn-primary {
            background: #667eea;
            color: white;
        }
        
        .btn-primary:hover {
            background: #764ba2;
        }
        
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #545b62;
        }
        
        /* 评论区域 */
        .comments-section {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        .comment-form {
            margin-bottom: 30px;
        }
        
        .form-control {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-family: inherit;
            resize: vertical;
        }
        
        .comment-item {
            border-bottom: 1px solid #e9ecef;
            padding: 20px 0;
            display: flex;
            gap: 15px;
        }
        
        .comment-avatar {
            flex-shrink: 0;
        }
        
        .comment-content {
            flex-grow: 1;
        }
        
        .comment-header {
            margin-bottom: 8px;
        }
        
        .comment-body {
            color: #444;
            line-height: 1.6;
        }
        
        .comment-actions {
            margin-top: 10px;
        }
        
        .btn-reply, .btn-delete {
            background: none;
            border: none;
            cursor: pointer;
            font-size: 0.9em;
            margin-left: 15px;
        }
        
        .btn-reply {
            color: #667eea;
        }
        
        .btn-delete {
            color: #dc3545;
        }
        
        /* 响应式设计 */
        @media (max-width: 768px) {
            .post-container {
                padding: 20px;
            }
            
            .post-title {
                font-size: 1.8em;
            }
            
            .post-meta {
                flex-direction: column;
                gap: 10px;
            }
            
            nav ul {
                flex-direction: column;
                gap: 15px;
            }
            
            .post-actions {
                flex-direction: column;
            }
            
            .comment-item {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- 页面头部 -->
        <header class="page-header">
            <h1 class="page-title"><%= post.getTitle() %></h1>
            <p class="page-subtitle">作者: <%= author != null ? author.getDisplayName() : "未知作者" %></p>
        </header>

        <!-- 导航栏 -->
        <nav>
            <ul>
                <li><a href="default.jsp">首页</a></li>
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
                
                <% if (currentUser != null) { %>
                    <div style="margin-left: auto;">
                        <a href="logout">退出登录</a>
                    </div>
                <% } else { %>
                    <div style="margin-left: auto;">
                        <a href="login.jsp">登录</a> | 
                        <a href="register.jsp">注册</a>
                    </div>
                <% } %>
            </ul>
        </nav>

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
                    <span>发布时间: <%= post.getCreatedAt() %></span>
                    <span>阅读量: <%= post.getViewCount() %></span>
                    <% if (post.getUpdatedAt() != null && !post.getUpdatedAt().equals(post.getCreatedAt())) { %>
                        <span>最后更新: <%= post.getUpdatedAt() %></span>
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

        <!-- 操作按钮区域 -->
        <div class="post-actions-container">
            <div class="post-actions">
                <a href="default.jsp" class="btn btn-secondary">返回首页</a>
                <% if (currentUser != null && currentUser.getId() == post.getUserId()) { %>
                    <a href="edit-post.jsp?id=<%= post.getId() %>" class="btn btn-primary">编辑文章</a>
                <% } %>
                <% if (currentUser != null) { %>
                    <a href="my-profile.jsp" class="btn btn-secondary">个人中心</a>
                <% } %>
            </div>
        </div>

        <!-- 评论区域 -->
        <div class="comments-section">
            <h2 style="margin-bottom: 25px; color: #333; border-bottom: 2px solid #667eea; padding-bottom: 10px;">
                评论 
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
                                 alt="用户头像" style="width: 45px; height: 45px; border-radius: 50%; object-fit: cover;">
                        </div>
                        <div class="comment-content">
                            <div class="comment-header">
                                <strong style="color: #333;"><%= comment.getDisplayName() != null ? comment.getDisplayName() : comment.getUsername() %></strong>
                                <span style="color: #666; font-size: 0.9em; margin-left: 10px;">
                                    <%= comment.getCreatedAt() %>
                                </span>
                            </div>
                            <div class="comment-body">
                                <%= comment.getContent() %>
                            </div>
                            <div class="comment-actions">
                                <button type="button" class="btn-reply"
                                        onclick="replyToComment(<%= comment.getId() %>, '<%= comment.getDisplayName() != null ? comment.getDisplayName() : comment.getUsername() %>')">
                                    回复
                                </button>
                                <% if (currentUser != null && currentUser.getId() == comment.getUserId()) { %>
                                    <button type="button" class="btn-delete"
                                            onclick="deleteComment(<%= comment.getId() %>, <%= post.getId() %>)">
                                        删除
                                    </button>
                                <% } %>
                            </div>
                        </div>
                    </div>
                    <% } %>
                <% } else { %>
                    <div style="text-align: center; padding: 40px; color: #666;">
                        <p>暂无评论，快来发表第一条评论吧！</p>
                    </div>
                <% } %>
            </div>
        </div>

        <!-- 页脚 -->
        <footer style="text-align: center; margin-top: 50px; padding: 20px; color: #666; border-top: 1px solid #ddd;">
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
        // 简单的代码高亮
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
    content = content.replaceAll("^## (.*?)$", "<h2>$1</h2>");
    content = content.replaceAll("^### (.*?)$", "<h3>$1</h3>");
    
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