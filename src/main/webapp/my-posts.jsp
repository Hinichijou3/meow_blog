<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.yourblog.model.User, com.yourblog.model.Post, java.util.List, com.yourblog.dao.PostDAO, com.yourblog.dao.MessageDAO" %>
<%
// 检查用户是否登录
User currentUser = (User) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

// 获取用户的文章列表（包括草稿）
PostDAO postDao = new PostDAO();
List<Post> userPosts = postDao.getPostsByUserId(currentUser.getId());

// 统计文章数量
int publishedCount = 0;
int draftCount = 0;
for (Post post : userPosts) {
    if ("published".equals(post.getStatus())) {
        publishedCount++;
    } else {
        draftCount++;
    }
}

// 获取当前时间
java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
String currentTime = sdf.format(new java.util.Date());

// 获取可能的操作结果消息
String successMsg = (String) request.getAttribute("success");
String errorMsg = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的文章 - 多用户博客系统</title>
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
            max-width: 1200px; 
            margin: 0 auto; 
            padding: 20px; 
        }
        
        /* 头部样式 */
        .page-header {
            background-image: url('<%= currentUser.getHeaderImageUrl() != null ? currentUser.getHeaderImageUrl() : "images/headers/default-header.jpg" %>');
            background-size: cover;
            background-position: center;
            color: white;
            padding: 60px 0;
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
            margin-bottom: 10px; 
        }
        .page-subtitle { 
            font-size: 1.2em; 
            opacity: 0.9; 
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
        .content-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            flex-wrap: wrap;
            gap: 15px;
        }
        
        .stats-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
        }
        
        .stat-number {
            font-size: 2.5em;
            font-weight: bold;
            margin-bottom: 10px;
        }
        
        .stat-published { color: #28a745; }
        .stat-draft { color: #ffc107; }
        .stat-total { color: #667eea; }
        
        .btn {
            display: inline-block;
            background: #667eea;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 5px;
            text-decoration: none;
            cursor: pointer;
            transition: background 0.3s;
            font-size: 1em;
            font-weight: 500;
        }
        
        .btn:hover {
            background: #764ba2;
        }
        
        .btn-success {
            background: #28a745;
        }
        
        .btn-success:hover {
            background: #218838;
        }
        
        /* 文章列表样式 */
        .posts-container {
            background: white;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .posts-filters {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid #e9ecef;
        }
        
        .filter-btn {
            padding: 8px 16px;
            border: 1px solid #ddd;
            background: white;
            border-radius: 5px;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .filter-btn.active {
            background: #667eea;
            color: white;
            border-color: #667eea;
        }
        
        .filter-btn:hover:not(.active) {
            background: #f8f9fa;
        }
        
        .post-list {
            display: grid;
            gap: 20px;
        }
        
        .post-item {
            padding: 20px;
            border: 1px solid #e9ecef;
            border-radius: 5px;
            transition: all 0.3s;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
        }
        
        .post-item:hover {
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transform: translateY(-2px);
        }
        
        .post-content {
            flex-grow: 1;
            margin-right: 20px;
        }
        
        .post-header {
            display: flex;
            align-items: center;
            margin-bottom: 10px;
            flex-wrap: wrap;
            gap: 10px;
        }
        
        .post-title {
            font-size: 1.3em;
            color: #333;
            margin: 0;
            font-weight: 600;
        }
        
        .post-status {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.8em;
            font-weight: 500;
        }
        
        .status-published {
            background: #d4edda;
            color: #155724;
        }
        
        .status-draft {
            background: #fff3cd;
            color: #856404;
        }
        
        .post-meta {
            color: #666;
            font-size: 0.9em;
            margin-bottom: 10px;
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
        }
        
        .post-excerpt {
            color: #555;
            line-height: 1.6;
            margin-bottom: 10px;
        }
        
        .post-actions {
            display: flex;
            gap: 10px;
            flex-shrink: 0;
        }
        
        .action-btn {
            padding: 8px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.85em;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s;
        }
        
        .view-btn {
            background: #17a2b8;
            color: white;
        }
        
        .view-btn:hover {
            background: #138496;
        }
        
        .edit-btn {
            background: #28a745;
            color: white;
        }
        
        .edit-btn:hover {
            background: #218838;
        }
        
        .delete-btn {
            background: #dc3545;
            color: white;
        }
        
        .delete-btn:hover {
            background: #c82333;
        }
        
        .publish-btn {
            background: #007bff;
            color: white;
        }
        
        .publish-btn:hover {
            background: #0069d9;
        }
        
        /* 空状态样式 */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }
        
        .empty-state-icon {
            font-size: 4em;
            margin-bottom: 20px;
            color: #ddd;
        }
        
        .empty-state h3 {
            font-size: 1.5em;
            margin-bottom: 10px;
            color: #333;
        }
        
        .empty-state p {
            margin-bottom: 25px;
            max-width: 500px;
            margin-left: auto;
            margin-right: auto;
        }
        
        /* 消息提示样式 */
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border: 1px solid transparent;
            border-radius: 5px;
        }
        
        .alert-success {
            color: #155724;
            background-color: #d4edda;
            border-color: #c3e6cb;
        }
        
        .alert-danger {
            color: #721c24;
            background-color: #f8d7da;
            border-color: #f5c6cb;
        }
        
        /* 响应式设计 */
        @media (max-width: 768px) {
            .content-header {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .post-item {
                flex-direction: column;
            }
            
            .post-content {
                margin-right: 0;
                margin-bottom: 15px;
            }
            
            .post-actions {
                width: 100%;
                justify-content: flex-end;
            }
            
            nav ul {
                flex-direction: column;
                gap: 15px;
            }
        }
        
        /* 加载动画 */
        .loading {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid rgba(255,255,255,.3);
            border-radius: 50%;
            border-top-color: #fff;
            animation: spin 1s ease-in-out infinite;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- 页面头部 -->
        <header class="page-header">
            <h1 class="page-title">我的文章</h1>
            <p class="page-subtitle">管理您的所有文章内容</p>
        </header>

        <!-- 导航栏 -->
        <nav>
            <ul>
                <li><a href="default.jsp">首页</a></li>
                <li><a href="my-profile.jsp">个人中心</a></li>
                <li><a href="my-posts.jsp" style="color: #764ba2;">我的文章</a></li>
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
                
                <div style="margin-left: auto;">
                    <a href="logout">退出登录</a>
                </div>
            </ul>
        </nav>

        <!-- 操作结果提示 -->
        <% if (successMsg != null) { %>
            <div class="alert alert-success">
                <%= successMsg %>
            </div>
        <% } %>
        
        <% if (errorMsg != null) { %>
            <div class="alert alert-danger">
                <%= errorMsg %>
            </div>
        <% } %>

        <!-- 统计卡片 -->
        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-number stat-total"><%= userPosts.size() %></div>
                <div>总文章数</div>
            </div>
            <div class="stat-card">
                <div class="stat-number stat-published"><%= publishedCount %></div>
                <div>已发布</div>
            </div>
            <div class="stat-card">
                <div class="stat-number stat-draft"><%= draftCount %></div>
                <div>草稿</div>
            </div>
        </div>

        <!-- 内容区域 -->
        <div class="content-header">
            <h2 style="color: #333;">文章列表</h2>
            <a href="create-post.jsp" class="btn btn-success">写新文章</a>
        </div>

        <div class="posts-container">
            <!-- 文章筛选 -->
            <div class="posts-filters">
                <button class="filter-btn active" data-filter="all">全部 (<%= userPosts.size() %>)</button>
                <button class="filter-btn" data-filter="published">已发布 (<%= publishedCount %>)</button>
                <button class="filter-btn" data-filter="draft">草稿 (<%= draftCount %>)</button>
            </div>

            <!-- 文章列表 -->
            <div class="post-list" id="postList">
                <% if (userPosts != null && !userPosts.isEmpty()) { %>
                    <% for (Post post : userPosts) { %>
                    <div class="post-item" data-status="<%= post.getStatus() %>">
                        <div class="post-content">
                            <div class="post-header">
                                <h3 class="post-title"><%= post.getTitle() %></h3>
                                <span class="post-status <%= "published".equals(post.getStatus()) ? "status-published" : "status-draft" %>">
                                    <%= "published".equals(post.getStatus()) ? "已发布" : "草稿" %>
                                </span>
                            </div>
                            <div class="post-meta">
                                <span>创建时间: <%= post.getCreatedAt() %></span>
                                <span>阅读量: <%= post.getViewCount() %></span>
                                <% if (post.getUpdatedAt() != null && !post.getUpdatedAt().equals(post.getCreatedAt())) { %>
                                    <span>最后更新: <%= post.getUpdatedAt() %></span>
                                <% } %>
                            </div>
                            <p class="post-excerpt">
                                <%= post.getExcerpt() != null && !post.getExcerpt().isEmpty() ? 
                                    post.getExcerpt() : "暂无摘要" %>
                            </p>
                        </div>
                        <div class="post-actions">
                            <a href="view-post.jsp?id=<%= post.getId() %>" class="action-btn view-btn">查看</a>
                            <a href="edit-post.jsp?id=<%= post.getId() %>" class="action-btn edit-btn">编辑</a>
                            <% if ("draft".equals(post.getStatus())) { %>
                                <button class="action-btn publish-btn" onclick="publishPost(<%= post.getId() %>, '<%= post.getTitle() %>')">发布</button>
                            <% } %>
                            <button class="action-btn delete-btn" 
                                    onclick="deletePost(<%= post.getId() %>, '<%= post.getTitle() %>')">删除</button>
                        </div>
                    </div>
                    <% } %>
                <% } else { %>
                    <div class="empty-state">
                        <div class="empty-state-icon">📝</div>
                        <h3>还没有任何文章</h3>
                        <p>开始您的创作之旅，写下第一篇文章吧！</p>
                        <a href="create-post.jsp" class="btn btn-success">写第一篇文章</a>
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
        // 文章筛选功能
        document.addEventListener('DOMContentLoaded', function() {
            const filterButtons = document.querySelectorAll('.filter-btn');
            const postItems = document.querySelectorAll('.post-item');
            
            filterButtons.forEach(button => {
                button.addEventListener('click', function() {
                    const filter = this.getAttribute('data-filter');
                    
                    // 更新按钮状态
                    filterButtons.forEach(btn => btn.classList.remove('active'));
                    this.classList.add('active');
                    
                    // 筛选文章
                    postItems.forEach(item => {
                        if (filter === 'all' || item.getAttribute('data-status') === filter) {
                            item.style.display = 'flex';
                        } else {
                            item.style.display = 'none';
                        }
                    });
                });
            });
        });
        
     // 删除文章确认
function deletePost(postId, postTitle) {
    if (confirm('确定要删除文章 "' + postTitle + '" 吗？此操作不可恢复！')) {
        const deleteBtn = event.target;
        const originalText = deleteBtn.innerHTML;
        deleteBtn.innerHTML = '<span class="loading"></span> 删除中...';
        deleteBtn.disabled = true;
        
        fetch('delete-post', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'id=' + postId
        })
        .then(response => {
            if (response.ok) {
                // 修改：跳转到个人中心
                window.location.href = 'my-profile.jsp?success=文章删除成功';
            } else {
                alert('删除失败，请重试');
                deleteBtn.innerHTML = originalText;
                deleteBtn.disabled = false;
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('删除失败，请重试');
            deleteBtn.innerHTML = originalText;
            deleteBtn.disabled = false;
        });
    }
}
        
        // 发布文章
function publishPost(postId, postTitle) {
    if (confirm('确定要发布文章 "' + postTitle + '" 吗？')) {
        const publishBtn = event.target;
        const originalText = publishBtn.innerHTML;
        publishBtn.innerHTML = '<span class="loading"></span> 发布中...';
        publishBtn.disabled = true;
        
        fetch('publish-post', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'id=' + postId
        })
        .then(response => {
            if (response.ok) {
                // 修改：跳转到个人中心
                window.location.href = 'my-profile.jsp?success=文章发布成功';
            } else {
                alert('发布失败，请重试');
                publishBtn.innerHTML = originalText;
                publishBtn.disabled = false;
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('发布失败，请重试');
            publishBtn.innerHTML = originalText;
            publishBtn.disabled = false;
        });
    }
}
        
        // 批量操作功能（未来扩展）
        function selectAllPosts() {
            const checkboxes = document.querySelectorAll('.post-checkbox');
            const selectAll = document.getElementById('selectAll');
            checkboxes.forEach(checkbox => {
                checkbox.checked = selectAll.checked;
            });
            updateBulkActions();
        }
        
        function updateBulkActions() {
            const selectedCount = document.querySelectorAll('.post-checkbox:checked').length;
            const bulkActions = document.getElementById('bulkActions');
            const selectedCountElem = document.getElementById('selectedCount');
            
            if (selectedCount > 0) {
                bulkActions.style.display = 'block';
                selectedCountElem.textContent = selectedCount;
            } else {
                bulkActions.style.display = 'none';
            }
        }
        
        function bulkDelete() {
            const selectedPosts = Array.from(document.querySelectorAll('.post-checkbox:checked'))
                .map(checkbox => parseInt(checkbox.value));
                
            if (selectedPosts.length === 0) {
                alert('请选择要删除的文章');
                return;
            }
            
            if (confirm(`确定要删除选中的 ${selectedPosts.length} 篇文章吗？此操作不可恢复！`)) {
                // 发送批量删除请求
                fetch('bulk-delete-posts', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({ postIds: selectedPosts })
                })
                .then(response => {
                    if (response.ok) {
                        window.location.reload();
                    } else {
                        alert('批量删除失败，请重试');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('批量删除失败，请重试');
                });
            }
        }
        
        function bulkPublish() {
            const selectedPosts = Array.from(document.querySelectorAll('.post-checkbox:checked'))
                .map(checkbox => parseInt(checkbox.value));
                
            if (selectedPosts.length === 0) {
                alert('请选择要发布的文章');
                return;
            }
            
            if (confirm(`确定要发布选中的 ${selectedPosts.length} 篇文章吗？`)) {
                // 发送批量发布请求
                fetch('bulk-publish-posts', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({ postIds: selectedPosts })
                })
                .then(response => {
                    if (response.ok) {
                        window.location.reload();
                    } else {
                        alert('批量发布失败，请重试');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('批量发布失败，请重试');
                });
            }
        }
    </script>
</body>
</html>