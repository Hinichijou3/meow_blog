<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.yourblog.model.User, com.yourblog.dao.MessageDAO" %>
<%
// 检查用户是否登录
User currentUser = (User) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

// 获取未读消息数（用于导航栏）
MessageDAO messageDao = new MessageDAO();
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
    <title>设置 - 多用户博客系统</title>
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
        .settings-content {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
        }
        
        @media (max-width: 768px) {
            .settings-content {
                grid-template-columns: 1fr;
            }
        }
        
        /* 设置卡片样式 */
        .settings-card {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .section-title {
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #667eea;
            font-size: 1.5em;
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
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 1em;
            transition: border-color 0.3s;
        }
        
        .form-control:focus {
            border-color: #667eea;
            outline: none;
            box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.1);
        }
        
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
            text-align: center;
            font-size: 1em;
            font-weight: 500;
        }
        
        .btn:hover {
            background: #764ba2;
        }
        
        .btn-block {
            display: block;
            width: 100%;
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
        
        /* 关于板块样式 */
        .about-section {
            line-height: 1.8;
        }
        
        .about-section h3 {
            color: #333;
            margin: 20px 0 10px 0;
            font-size: 1.2em;
        }
        
        .about-section p {
            margin-bottom: 15px;
            color: #555;
        }
        
        .about-section ul {
            margin-left: 20px;
            margin-bottom: 15px;
        }
        
        .about-section li {
            margin-bottom: 8px;
            color: #555;
        }
        
        .contact-info {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 5px;
            margin-top: 20px;
        }
        
        .contact-info h4 {
            color: #333;
            margin-bottom: 10px;
        }
        
        /* 消息提示样式 */
        .alert {
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .alert-info {
            background: #d1ecf1;
            color: #0c5460;
            border: 1px solid #bee5eb;
        }
        
        /* 密码强度指示器 */
        .password-strength {
            margin-top: 5px;
            height: 5px;
            border-radius: 3px;
            background: #e9ecef;
            overflow: hidden;
        }
        
        .password-strength-bar {
            height: 100%;
            width: 0%;
            transition: width 0.3s, background-color 0.3s;
        }
        
        .strength-weak { background: #dc3545; width: 33%; }
        .strength-medium { background: #ffc107; width: 66%; }
        .strength-strong { background: #28a745; width: 100%; }
        
        .password-requirements {
            font-size: 0.85em;
            color: #666;
            margin-top: 5px;
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
                <li>
                    <a href="messages.jsp">消息
                        <% if (unreadCount > 0) { %>
                            <span style="background: #ff4757; color: white; border-radius: 50%; padding: 2px 6px; font-size: 0.8em; margin-left: 5px;">
                                <%= unreadCount %>
                            </span>
                        <% } %>
                    </a>
                </li>
                <li><a href="settings.jsp" style="color: #764ba2;">设置</a></li>
                
                <div style="margin-left: auto;">
                    <a href="logout">退出登录</a>
                </div>
            </ul>
        </nav>

        <!-- 消息提示 -->
        <%
        String success = request.getParameter("success");
        String error = request.getParameter("error");
        
        if (success != null) {
            if ("password_updated".equals(success)) {
        %>
            <div class="alert alert-success">
                ✅ 密码修改成功！
            </div>
        <%
            }
        }
        
        if (error != null) {
            String errorMessage = "";
            switch (error) {
                case "current_password_required":
                    errorMessage = "请输入当前密码";
                    break;
                case "new_password_required":
                    errorMessage = "请输入新密码";
                    break;
                case "confirm_password_required":
                    errorMessage = "请确认新密码";
                    break;
                case "passwords_not_match":
                    errorMessage = "新密码和确认密码不一致";
                    break;
                case "password_too_short":
                    errorMessage = "密码长度至少6位";
                    break;
                case "invalid_current_password":
                    errorMessage = "当前密码错误";
                    break;
                case "update_failed":
                    errorMessage = "密码更新失败，请重试";
                    break;
                case "server_error":
                    errorMessage = "服务器错误，请稍后重试";
                    break;
                default:
                    errorMessage = "操作失败，请重试";
            }
        %>
            <div class="alert alert-error">
                ❌ <%= errorMessage %>
            </div>
        <%
        }
        %>

        <!-- 设置内容区域 -->
        <div class="settings-content">
            <!-- 左侧：账户设置 -->
            <div class="settings-card">
                <h2 class="section-title">账户设置</h2>
                
                <!-- 修改密码表单 -->
                <form action="update-password" method="post" id="passwordForm">
                    <div class="form-group">
                        <label for="currentPassword">当前密码</label>
                        <input type="password" id="currentPassword" name="currentPassword" class="form-control" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="newPassword">新密码</label>
                        <input type="password" id="newPassword" name="newPassword" class="form-control" required 
                               minlength="6" oninput="updatePasswordStrength()">
                        <div class="password-strength">
                            <div class="password-strength-bar" id="passwordStrengthBar"></div>
                        </div>
                        <div class="password-requirements">
                            密码长度至少6位，建议包含字母、数字和特殊字符
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="confirmPassword">确认新密码</label>
                        <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" required
                               oninput="checkPasswordMatch()">
                        <div id="passwordMatchMessage" style="font-size: 0.85em; margin-top: 5px;"></div>
                    </div>
                    
                    <button type="submit" class="btn btn-block">修改密码</button>
                </form>
                
                <hr style="margin: 30px 0;">
                
                <!-- 账户信息 -->
                <h3 style="margin-bottom: 15px;">账户信息</h3>
                <div style="background: #f8f9fa; padding: 15px; border-radius: 5px;">
                    <p><strong>用户名:</strong> <%= currentUser.getUsername() %></p>
                    <p><strong>显示名称:</strong> <%= currentUser.getDisplayName() %></p>
                    <p><strong>邮箱:</strong> <%= currentUser.getEmail() != null ? currentUser.getEmail() : "未设置" %></p>
                    <p><strong>注册时间:</strong> <%= currentUser.getCreatedAt() %></p>
                    <p><strong>最后更新:</strong> <%= currentUser.getUpdatedAt() != null ? currentUser.getUpdatedAt() : "从未更新" %></p>
                </div>
            </div>
            
            <!-- 右侧：关于我们 -->
            <div class="settings-card">
                <h2 class="section-title">关于我们</h2>
                <div class="about-section">
                    <h3>📝 博客简介</h3>
                    <p>欢迎来到多用户博客系统！这是一个基于 JSP + Servlet + MySQL 开发的现代化博客平台，致力于为用户提供优质的写作和阅读体验。</p>
                    
                    <h3>🌟 平台特色</h3>
                    <ul>
                        <li>🆓 完全免费使用！</li>
                        <li>📱 各种设备访问的响应式设计！</li>
                        <li>🎨 自定义头像和头图！</li>
                        <li>💬 完整的评论互动系统！</li>
                        <li>👍 点赞、收藏、投币等丰富的互动功能！</li>
                        <li>🔔 实时消息通知系统！</li>
                        <li>📊 数据统计和分析！</li>
                    </ul>
                    
                    <h3>🛠️ 技术栈</h3>
                    <p><strong>前端:</strong> HTML5, CSS3, JavaScript, 响应式设计</p>
                    <p><strong>后端:</strong> Java, JSP, Servlet</p>
                    <p><strong>数据库:</strong> MySQL</p>
                    <p><strong>服务器:</strong> Apache Tomcat</p>
                    
                    <div class="contact-info">
                        <h4>📞 联系我们</h4>
                        <p><strong>管理邮箱:</strong> admin@yourblog.com</p>
                        <p><strong>官方QQ群:</strong> 准备中...</p>
                        <p><strong>GitHub:</strong> <a href="https://github.com/yourblog" target="_blank">github.com/yourblog</a></p>
                    </div>
                    
                    <h3>🤝 加入我们</h3>
                    <p>我们一直在寻找热爱技术、热爱分享的伙伴！如果你对以下方向感兴趣，欢迎联系我们：</p>
                    <ul>
                        <li>前端/后端开发</li>
                    </ul>
                    
                    <div style="background: #e8f5e8; padding: 15px; border-radius: 5px; margin-top: 20px;">
                        <p><strong>💡 反馈与建议</strong></p>
                        <p>如果您在使用过程中遇到任何问题，或者有好的建议，欢迎通过上述联系方式与我们沟通。您的反馈对我们非常重要！</p>
                    </div>
                </div>
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
        // 密码强度检测
        function updatePasswordStrength() {
            const password = document.getElementById('newPassword').value;
            const strengthBar = document.getElementById('passwordStrengthBar');
            
            let strength = 0;
            
            // 长度检查
            if (password.length >= 6) strength += 1;
            if (password.length >= 8) strength += 1;
            
            // 复杂度检查
            if (/[a-z]/.test(password)) strength += 1;
            if (/[A-Z]/.test(password)) strength += 1;
            if (/[0-9]/.test(password)) strength += 1;
            if (/[^a-zA-Z0-9]/.test(password)) strength += 1;
            
            // 更新强度条
            strengthBar.className = 'password-strength-bar';
            if (password.length === 0) {
                strengthBar.style.width = '0%';
            } else if (strength <= 2) {
                strengthBar.classList.add('strength-weak');
            } else if (strength <= 4) {
                strengthBar.classList.add('strength-medium');
            } else {
                strengthBar.classList.add('strength-strong');
            }
        }
        
        // 密码匹配检查
        function checkPasswordMatch() {
            const password = document.getElementById('newPassword').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const messageElement = document.getElementById('passwordMatchMessage');
            
            if (confirmPassword.length === 0) {
                messageElement.textContent = '';
                messageElement.style.color = '';
            } else if (password === confirmPassword) {
                messageElement.textContent = '✅ 密码匹配';
                messageElement.style.color = '#28a745';
            } else {
                messageElement.textContent = '❌ 密码不匹配';
                messageElement.style.color = '#dc3545';
            }
        }
        
        // 表单提交验证
        document.getElementById('passwordForm').addEventListener('submit', function(e) {
            const password = document.getElementById('newPassword').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            if (password.length < 6) {
                alert('密码长度至少6位');
                e.preventDefault();
                return;
            }
            
            if (password !== confirmPassword) {
                alert('新密码和确认密码不一致');
                e.preventDefault();
                return;
            }
        });
        
        // 页面加载完成后初始化
        document.addEventListener('DOMContentLoaded', function() {
            updatePasswordStrength();
            checkPasswordMatch();
        });
    </script>
</body>
</html>