<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.yourblog.model.User, com.yourblog.model.Post, java.util.List, com.yourblog.dao.PostDAO" %>
<%@ page import="com.yourblog.dao.LikeDAO, com.yourblog.dao.FavoriteDAO, com.yourblog.dao.CoinDAO, com.yourblog.dao.MessageDAO" %>
<%
// 检查用户是否登录
User currentUser = (User) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

// 获取用户的文章列表
PostDAO postDao = new PostDAO();
List<Post> userPosts = postDao.getPostsByUserId(currentUser.getId());

// 获取当前时间
java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
String currentTime = sdf.format(new java.util.Date());
%>

<%
// 初始化交互功能DAO
LikeDAO likeDao = new LikeDAO();
FavoriteDAO favoriteDao = new FavoriteDAO();
CoinDAO coinDao = new CoinDAO();
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>个人中心 - 多用户博客系统</title>
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
        
        /* 头部样式 - 使用用户个性化头图 */
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
        .profile-content {
            display: grid;
            grid-template-columns: 300px 1fr;
            gap: 30px;
        }
        
        /* 侧边栏样式 */
        .sidebar {
            background: white;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            height: fit-content;
        }
        
        .sidebar-section {
            margin-bottom: 25px;
        }
        
        .sidebar-section h3 {
            color: #333;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #667eea;
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
            width: 100%;
            margin-bottom: 10px;
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
        
        .btn-danger {
            background: #dc3545;
        }
        
        .btn-danger:hover {
            background: #c82333;
        }
        
        /* 主内容区样式 */
        .main-content {
            background: white;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .section-title {
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #667eea;
        }
        
        /* 文章列表样式 */
        .post-list {
            display: grid;
            gap: 15px;
        }
        
        .post-item {
            padding: 20px;
            border: 1px solid #e9ecef;
            border-radius: 5px;
            transition: all 0.3s;
        }
        
        .post-item:hover {
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transform: translateY(-2px);
        }
        
        .post-header {
            display: flex;
            justify-content: between;
            align-items: center;
            margin-bottom: 10px;
        }
        
        .post-title {
            font-size: 1.2em;
            color: #333;
            margin: 0;
            flex-grow: 1;
        }
        
        .post-meta {
            color: #666;
            font-size: 0.9em;
            margin-bottom: 10px;
        }
        
        .post-actions {
            display: flex;
            gap: 10px;
        }
        
        .action-btn {
            padding: 5px 10px;
            border: none;
            border-radius: 3px;
            cursor: pointer;
            font-size: 0.85em;
            text-decoration: none;
            display: inline-block;
        }
        
        .edit-btn {
            background: #28a745;
            color: white;
        }
        
        .delete-btn {
            background: #dc3545;
            color: white;
        }
        
        /* 表单样式 */
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
            color: #333;
        }
        
        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 1em;
        }
        
        textarea.form-control {
            min-height: 100px;
            resize: vertical;
        }
        
        /* 模态框样式 */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 1000;
            justify-content: center;
            align-items: center;
        }
        
        .modal-content {
            background: white;
            padding: 30px;
            border-radius: 8px;
            width: 90%;
            max-width: 500px;
            max-height: 90vh;
            overflow-y: auto;
        }
        
        .modal-header {
            display: flex;
            justify-content: between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .modal-title {
            font-size: 1.5em;
            color: #333;
            margin: 0;
        }
        
        .close-btn {
            background: none;
            border: none;
            font-size: 1.5em;
            cursor: pointer;
            color: #666;
        }
        
        /* 响应式设计 */
        @media (max-width: 768px) {
            .profile-content {
                grid-template-columns: 1fr;
            }
            
            nav ul {
                flex-direction: column;
                gap: 15px;
            }
            
            .post-header {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .post-actions {
                margin-top: 10px;
                width: 100%;
                justify-content: flex-end;
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
                <li><a href="my-profile.jsp" style="color: #764ba2;">个人中心</a></li>
                <li><a href="my-posts.jsp">我的文章</a></li>
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
                <li><a href="#">设置</a></li>
                
                <div style="margin-left: auto;">
                    <a href="logout">退出登录</a>
                </div>
            </ul>
        </nav>

        <!-- 主要内容区域 -->
        <div class="profile-content">
            <!-- 侧边栏 -->
            <div class="sidebar">
                <div class="sidebar-section">
                    <h3>个人操作</h3>
                    <button class="btn" onclick="openModal('editProfileModal')">编辑资料</button>
                    <button class="btn" onclick="openModal('changeAvatarModal')">更换头像</button>
                    <button class="btn" onclick="openModal('changeHeaderModal')">更换头图</button>
                    <a href="create-post.jsp" class="btn">写新文章</a>
                </div>
                
                <div class="sidebar-section">
				    <h3>个人统计</h3>
				    <p>硬币数量: <strong><%= currentUser.getCoins() %></strong></p>
				    <p>总获赞数: <strong><%= likeDao.getUserTotalLikes(currentUser.getId()) %></strong></p>
				    <p>获得投币: <strong><%= coinDao.getUserCoinsEarned(currentUser.getId()) %></strong></p>
				    <p>累计收益: <strong><%= currentUser.getTotalCoinsEarned() %></strong> 硬币</p>
				</div>
                
                <div class="sidebar-section">
                    <h3>统计信息</h3>
                    <p>文章数量: <strong><%= userPosts.size() %></strong></p>
                    <p>注册时间: <strong><%= currentUser.getCreatedAt() %></strong></p>
                    <p>最后更新: <strong><%= currentUser.getUpdatedAt() %></strong></p>
                </div>
                
            </div>

            <!-- 主内容区 -->
            <div class="main-content">
                <h2 class="section-title">我的文章</h2>
                
                <div class="post-list">
                    <% if (userPosts != null && !userPosts.isEmpty()) { %>
                        <% for (Post post : userPosts) { %>
                        <div class="post-item">
                            <div class="post-header">
                                <h3 class="post-title">
    								<a href="view-post.jsp?id=<%= post.getId() %>" style="color: inherit; text-decoration: none;">
        								<%= post.getTitle() %>
    								</a>
								</h3>
                                <div class="post-actions">
                                    <a href="edit-post.jsp?id=<%= post.getId() %>" class="action-btn edit-btn">编辑</a>
                                    <button class="action-btn delete-btn" 
                                            onclick="deletePost(<%= post.getId() %>, '<%= post.getTitle() %>')">删除</button>
                                </div>
                            </div>
                            <div class="post-meta">
                                发布于 <%= post.getCreatedAt() %> • 
                                阅读量 <%= post.getViewCount() %> • 
                                状态: <span style="color: <%= "published".equals(post.getStatus()) ? "#28a745" : "#ffc107" %>">
                                    <%= "published".equals(post.getStatus()) ? "已发布" : "草稿" %>
                                </span>
                            </div>
                            <p class="post-excerpt">
                                <%= post.getExcerpt() != null && !post.getExcerpt().isEmpty() ? 
                                    post.getExcerpt() : "暂无摘要" %>
                            </p>
                        </div>
                        <% } %>
                    <% } else { %>
                        <div class="post-item" style="text-align: center; padding: 40px;">
                            <h3>还没有发布任何文章</h3>
                            <p>开始你的创作之旅吧！</p>
                            <a href="create-post.jsp" class="btn" style="width: auto; margin-top: 15px;">写第一篇文章</a>
                        </div>
                    <% } %>
                </div>
                
                <!-- 收藏夹部分 -->
				<div class="main-content" style="margin-top: 30px;">
				    <h2 class="section-title">我的收藏</h2>
				    <div class="post-list">
				        <% 
				        List<Post> favoritePosts = favoriteDao.getUserFavorites(currentUser.getId());
				        if (favoritePosts != null && !favoritePosts.isEmpty()) { 
				        %>
				            <% for (Post post : favoritePosts) { %>
				            <div class="post-item">
				                <div class="post-header">
				                    <h3 class="post-title">
				                        <a href="view-post.jsp?id=<%= post.getId() %>" style="color: inherit; text-decoration: none;">
				                            <%= post.getTitle() %>
				                        </a>
				                    </h3>
				                    <div class="post-actions">
				                        <a href="view-post.jsp?id=<%= post.getId() %>" class="action-btn edit-btn">查看</a>
				                        <button class="action-btn delete-btn" 
				                                onclick="removeFavorite(<%= post.getId() %>, '<%= post.getTitle() %>')">取消收藏</button>
				                    </div>
				                </div>
				                <div class="post-meta">
				                    作者: <%= post.getAuthor() %> • 
				                    收藏时间: <%= post.getCreatedAt() %>
				                </div>
				                <p class="post-excerpt">
				                    <%= post.getExcerpt() != null && !post.getExcerpt().isEmpty() ? 
				                        post.getExcerpt() : "暂无摘要" %>
				                </p>
				            </div>
				            <% } %>
				        <% } else { %>
				            <div class="post-item" style="text-align: center; padding: 40px;">
				                <h3>还没有收藏任何文章</h3>
				                <p>发现好文章时可以点击⭐收藏哦！</p>
				            </div>
				        <% } %>
				    </div>
				</div>
            </div>
        </div>

        <!-- 页脚 -->
        <footer>
            <p>
                © 2025 多用户博客系统 | 
                服务器时间：<%= currentTime %> | 
                当前用户：<%= currentUser.getUsername() %>
            </p>
        </footer>
    </div>

    <!-- 编辑资料模态框 -->
    <div id="editProfileModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">编辑个人资料</h3>
                <button class="close-btn" onclick="closeModal('editProfileModal')">&times;</button>
            </div>
            <form action="update-profile" method="post">
                <div class="form-group">
                    <label for="displayName">显示名称</label>
                    <input type="text" id="displayName" name="displayName" class="form-control" 
                           value="<%= currentUser.getDisplayName() %>" required>
                </div>
                <div class="form-group">
                    <label for="email">邮箱地址</label>
                    <input type="email" id="email" name="email" class="form-control" 
                           value="<%= currentUser.getEmail() %>" required>
                </div>
                <div class="form-group">
                    <label for="bio">个人简介</label>
                    <textarea id="bio" name="bio" class="form-control"><%= currentUser.getBio() != null ? currentUser.getBio() : "" %></textarea>
                </div>
                <div class="form-group">
                    <button type="submit" class="btn">保存更改</button>
                    <button type="button" class="btn btn-secondary" onclick="closeModal('editProfileModal')">取消</button>
                </div>
            </form>
        </div>
    </div>

    <!-- 更换头像模态框 -->
    <div id="changeAvatarModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">更换头像</h3>
                <button class="close-btn" onclick="closeModal('changeAvatarModal')">&times;</button>
            </div>
            <form action="upload-avatar" method="post" enctype="multipart/form-data">
                <div class="form-group">
                    <label for="avatarFile">选择头像图片</label>
                    <input type="file" id="avatarFile" name="avatarFile" class="form-control" accept="image/*" required>
                    <small>支持 JPG, PNG 格式，建议尺寸 200x200 像素</small>
                </div>
                <div class="form-group">
                    <button type="submit" class="btn">上传头像</button>
                    <button type="button" class="btn btn-secondary" onclick="closeModal('changeAvatarModal')">取消</button>
                </div>
            </form>
        </div>
    </div>

    <!-- 更换头图模态框 -->
    <div id="changeHeaderModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">更换头图</h3>
                <button class="close-btn" onclick="closeModal('changeHeaderModal')">&times;</button>
            </div>
            <form action="upload-header" method="post" enctype="multipart/form-data">
                <div class="form-group">
                    <label for="headerFile">选择头图图片</label>
                    <input type="file" id="headerFile" name="headerFile" class="form-control" accept="image/*" required>
                    <small>支持 JPG, PNG 格式，建议尺寸 1200x400 像素</small>
                </div>
                <div class="form-group">
                    <button type="submit" class="btn">上传头图</button>
                    <button type="button" class="btn btn-secondary" onclick="closeModal('changeHeaderModal')">取消</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // 模态框控制函数
        function openModal(modalId) {
            document.getElementById(modalId).style.display = 'flex';
        }
        
        function closeModal(modalId) {
            document.getElementById(modalId).style.display = 'none';
        }
        
        // 点击模态框外部关闭
        window.onclick = function(event) {
            if (event.target.className === 'modal') {
                event.target.style.display = 'none';
            }
        }
        
        // 删除文章确认
        function deletePost(postId, postTitle) {
            if (confirm('确定要删除文章 "' + postTitle + '" 吗？此操作不可恢复！')) {
                // 这里可以发送AJAX请求或跳转到删除页面
                window.location.href = 'delete-post?id=' + postId;
            }
        }
        
        // 页面加载后检查URL参数，显示相应的模态框
        window.onload = function() {
            const urlParams = new URLSearchParams(window.location.search);
            const action = urlParams.get('action');
            
            if (action === 'edit') {
                openModal('editProfileModal');
            } else if (action === 'avatar') {
                openModal('changeAvatarModal');
            } else if (action === 'header') {
                openModal('changeHeaderModal');
            }
        };
        
     	// 取消收藏功能
        function removeFavorite(postId, postTitle) {
            if (confirm('确定要取消收藏 "' + postTitle + '" 吗？')) {
                fetch('favorite', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'postId=' + postId + '&action=unfavorite'
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        window.location.reload();
                    } else {
                        alert(data.message);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('取消收藏失败');
                });
            }
        }
    </script>
</body>
</html>