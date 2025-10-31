<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.yourblog.model.User, com.yourblog.model.Post, com.yourblog.dao.PostDAO, com.yourblog.dao.MessageDAO" %>
<%
// 检查用户是否登录
User currentUser = (User) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

// 获取文章ID
String postIdParam = request.getParameter("id");
Post post = null;
boolean isEdit = false;

if (postIdParam != null && !postIdParam.isEmpty()) {
    try {
        int postId = Integer.parseInt(postIdParam);
        PostDAO postDao = new PostDAO();
        post = postDao.getPostById(postId);
        
        // 验证文章属于当前用户
        if (post != null && post.getUserId() == currentUser.getId()) {
            isEdit = true;
        } else {
            response.sendRedirect("my-posts.jsp?error=无权编辑此文章");
            return;
        }
    } catch (NumberFormatException e) {
        response.sendRedirect("my-posts.jsp?error=无效的文章ID");
        return;
    }
}

// 如果是新建文章，创建空文章对象
if (!isEdit) {
    post = new Post();
    post.setTitle("");
    post.setContent("");
    post.setExcerpt("");
    post.setStatus("draft");
}

// 获取操作结果消息
String successMsg = (String) request.getAttribute("success");
String errorMsg = (String) request.getAttribute("error");

// 获取当前时间
java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
String currentTime = sdf.format(new java.util.Date());
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "编辑文章" : "写新文章" %> - 多用户博客系统</title>
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
            max-width: 1000px; 
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
        
        /* 编辑表单样式 */
        .edit-container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .form-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid #e9ecef;
        }
        
        .form-title {
            font-size: 1.8em;
            color: #333;
        }
        
        .form-group {
            margin-bottom: 25px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #333;
        }
        
        .form-control {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 1em;
            font-family: inherit;
            transition: border-color 0.3s;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        textarea.form-control {
            min-height: 150px;
            resize: vertical;
        }
        
        #contentEditor {
            min-height: 400px;
            font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
            line-height: 1.5;
        }
        
        .form-actions {
            display: flex;
            gap: 15px;
            justify-content: flex-end;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e9ecef;
        }
        
        .btn {
            display: inline-block;
            padding: 12px 24px;
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
        
        .btn-success {
            background: #28a745;
            color: white;
        }
        
        .btn-success:hover {
            background: #218838;
        }
        
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #545b62;
        }
        
        .btn-danger {
            background: #dc3545;
            color: white;
        }
        
        .btn-danger:hover {
            background: #c82333;
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
        
        /* 编辑器工具栏 */
        .editor-toolbar {
            display: flex;
            gap: 10px;
            margin-bottom: 10px;
            padding: 10px;
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 5px;
        }
        
        .toolbar-btn {
            padding: 8px 12px;
            border: 1px solid #ddd;
            background: white;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .toolbar-btn:hover {
            background: #e9ecef;
        }
        
        /* 字符计数 */
        .char-count {
            text-align: right;
            color: #666;
            font-size: 0.9em;
            margin-top: 5px;
        }
        
        /* 预览区域 */
        .preview-area {
            border: 1px solid #ddd;
            border-radius: 5px;
            padding: 15px;
            background: #f8f9fa;
            min-height: 200px;
            margin-top: 10px;
            display: none;
        }
        
        /* 响应式设计 */
        @media (max-width: 768px) {
            .form-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
            
            .form-actions {
                flex-direction: column;
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
            <h1 class="page-title"><%= isEdit ? "编辑文章" : "写新文章" %></h1>
            <p class="page-subtitle"><%= isEdit ? "修改您的文章内容" : "开始您的创作之旅" %></p>
        </header>

        <!-- 导航栏 -->
        <nav>
            <ul>
                <li><a href="default.jsp">首页</a></li>
                <li><a href="my-profile.jsp">个人中心</a></li>
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

        <!-- 编辑表单 -->
        <div class="edit-container">
            <div class="form-header">
                <h2 class="form-title"><%= isEdit ? "编辑文章" : "创建新文章" %></h2>
                <div>
                    <% if (isEdit) { %>
                        <span style="color: #666;">文章ID: <%= post.getId() %></span>
                    <% } %>
                </div>
            </div>

            <form id="postForm" action="<%= isEdit ? "update-post" : "create-post" %>" method="post">
                <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= post.getId() %>">
                <% } %>
                
                <div class="form-group">
                    <label for="title">文章标题 *</label>
                    <input type="text" id="title" name="title" class="form-control" 
                           value="<%= post.getTitle() %>" placeholder="请输入文章标题" required>
                    <div class="char-count">
                        <span id="titleCount">0</span>/100 字符
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="excerpt">文章摘要</label>
                    <textarea id="excerpt" name="excerpt" class="form-control" 
                              placeholder="请输入文章摘要（可选）"><%= post.getExcerpt() != null ? post.getExcerpt() : "" %></textarea>
                    <div class="char-count">
                        <span id="excerptCount">0</span>/300 字符
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="contentEditor">文章内容 *</label>
                    <div class="editor-toolbar">
                        <button type="button" class="toolbar-btn" onclick="formatText('bold')"><strong>B</strong></button>
                        <button type="button" class="toolbar-btn" onclick="formatText('italic')"><em>I</em></button>
                        <button type="button" class="toolbar-btn" onclick="formatText('underline')"><u>U</u></button>
                        <button type="button" class="toolbar-btn" onclick="insertText('# ')" title="一级标题">H1</button>
                        <button type="button" class="toolbar-btn" onclick="insertText('## ')" title="二级标题">H2</button>
                        <button type="button" class="toolbar-btn" onclick="insertText('- ')" title="列表">列表</button>
                        <button type="button" class="toolbar-btn" onclick="insertText('> ')" title="引用">引用</button>
                        <button type="button" class="toolbar-btn" onclick="togglePreview()">预览</button>
                    </div>
                    <textarea id="contentEditor" name="content" class="form-control" 
                              placeholder="请输入文章内容（支持Markdown语法）" required><%= post.getContent() != null ? post.getContent() : "" %></textarea>
                    <div class="char-count">
                        <span id="contentCount">0</span> 字符
                    </div>
                    <div id="previewArea" class="preview-area"></div>
                </div>
                
                <div class="form-group">
                    <label for="status">文章状态</label>
                    <select id="status" name="status" class="form-control">
                        <option value="draft" <%= "draft".equals(post.getStatus()) ? "selected" : "" %>>草稿</option>
                        <option value="published" <%= "published".equals(post.getStatus()) ? "selected" : "" %>>立即发布</option>
                    </select>
                </div>
                
                <div class="form-actions">
                    <button type="button" class="btn btn-secondary" onclick="window.history.back()">取消</button>
                    <button type="submit" name="action" value="save" class="btn btn-primary" id="saveBtn">
                        保存<%= "draft".equals(post.getStatus()) ? "草稿" : "" %>
                    </button>
                    <% if ("draft".equals(post.getStatus())) { %>
                        <button type="submit" name="action" value="publish" class="btn btn-success">保存并发布</button>
                    <% } %>
                    <% if (isEdit) { %>
                        <button type="button" class="btn btn-danger" onclick="deletePost(<%= post.getId() %>, '<%= post.getTitle() %>')">删除文章</button>
                    <% } %>
                </div>
            </form>
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
        // 字符计数
        function updateCharCount() {
            const titleCount = document.getElementById('title').value.length;
            const excerptCount = document.getElementById('excerpt').value.length;
            const contentCount = document.getElementById('contentEditor').value.length;
            
            document.getElementById('titleCount').textContent = titleCount;
            document.getElementById('excerptCount').textContent = excerptCount;
            document.getElementById('contentCount').textContent = contentCount;
        }
        
        // 初始化字符计数
        document.addEventListener('DOMContentLoaded', function() {
            updateCharCount();
            
            // 添加输入事件监听
            document.getElementById('title').addEventListener('input', updateCharCount);
            document.getElementById('excerpt').addEventListener('input', updateCharCount);
            document.getElementById('contentEditor').addEventListener('input', updateCharCount);
            
            // 状态选择变化时更新按钮文字
            document.getElementById('status').addEventListener('change', function() {
                const saveBtn = document.getElementById('saveBtn');
                if (this.value === 'draft') {
                    saveBtn.textContent = '保存草稿';
                } else {
                    saveBtn.textContent = '保存并发布';
                }
            });
        });
        
        // 文本格式化
        function formatText(type) {
            const textarea = document.getElementById('contentEditor');
            const start = textarea.selectionStart;
            const end = textarea.selectionEnd;
            const selectedText = textarea.value.substring(start, end);
            
            let formattedText = '';
            switch(type) {
                case 'bold':
                    formattedText = '**' + selectedText + '**';
                    break;
                case 'italic':
                    formattedText = '*' + selectedText + '*';
                    break;
                case 'underline':
                    formattedText = '<u>' + selectedText + '</u>';
                    break;
            }
            
            textarea.value = textarea.value.substring(0, start) + formattedText + textarea.value.substring(end);
            textarea.focus();
            textarea.setSelectionRange(start + formattedText.length, start + formattedText.length);
            updateCharCount();
        }
        
        // 插入文本
        function insertText(text) {
            const textarea = document.getElementById('contentEditor');
            const start = textarea.selectionStart;
            const end = textarea.selectionEnd;
            
            textarea.value = textarea.value.substring(0, start) + text + textarea.value.substring(end);
            textarea.focus();
            textarea.setSelectionRange(start + text.length, start + text.length);
            updateCharCount();
        }
        
        // 切换预览
        function togglePreview() {
            const previewArea = document.getElementById('previewArea');
            const content = document.getElementById('contentEditor').value;
            
            if (previewArea.style.display === 'block') {
                previewArea.style.display = 'none';
            } else {
                // 简单的Markdown预览（实际项目中可以使用marked.js等库）
                let html = content
                    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
                    .replace(/\*(.*?)\*/g, '<em>$1</em>')
                    .replace(/^# (.*$)/gm, '<h1>$1</h1>')
                    .replace(/^## (.*$)/gm, '<h2>$1</h2>')
                    .replace(/^- (.*$)/gm, '<li>$1</li>')
                    .replace(/(<li>.*<\/li>)/s, '<ul>$1</ul>')
                    .replace(/^> (.*$)/gm, '<blockquote>$1</blockquote>')
                    .replace(/\n/g, '<br>');
                
                previewArea.innerHTML = html;
                previewArea.style.display = 'block';
            }
        }
        
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
        
        // 表单提交处理
        document.getElementById('postForm').addEventListener('submit', function(e) {
            const submitBtn = e.submitter;
            const action = submitBtn.value;
            
            // 根据按钮设置状态
            if (action === 'publish') {
                document.getElementById('status').value = 'published';
            }
            
            // 显示加载状态
            submitBtn.innerHTML = '<span class="loading"></span> 保存中...';
            submitBtn.disabled = true;
            
            // 允许表单正常提交
        });
        
        // 离开页面确认
        let formChanged = false;
        document.getElementById('postForm').addEventListener('input', function() {
            formChanged = true;
        });
        
        window.addEventListener('beforeunload', function(e) {
            if (formChanged) {
                e.preventDefault();
                e.returnValue = '您有未保存的更改，确定要离开吗？';
            }
        });
    </script>
</body>
</html>