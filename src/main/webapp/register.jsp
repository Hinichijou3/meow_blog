<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>注册 - 我的博客</title>
    <style>
        .register-container {
            max-width: 400px;
            margin: 50px auto;
            padding: 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        input[type="text"], input[type="password"], input[type="email"], textarea {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        textarea {
            height: 80px;
            resize: vertical;
        }
        .btn {
            background: #667eea;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .error {
            color: red;
            margin-bottom: 15px;
        }
    </style>
</head>
<body>
    <div class="register-container">
        <h2>用户注册</h2>
        
        <% if (request.getAttribute("error") != null) { %>
            <div class="error"><%= request.getAttribute("error") %></div>
        <% } %>
        
        <form action="register" method="post">
            <div class="form-group">
                <label for="username">用户名:</label>
                <input type="text" id="username" name="username" required>
            </div>
            
            <div class="form-group">
                <label for="email">邮箱:</label>
                <input type="email" id="email" name="email" required>
            </div>
            
            <div class="form-group">
                <label for="password">密码:</label>
                <input type="password" id="password" name="password" required>
            </div>
            
            <div class="form-group">
                <label for="displayName">显示名称:</label>
                <input type="text" id="displayName" name="displayName" required>
            </div>
            
            <div class="form-group">
                <label for="bio">个人简介:</label>
                <textarea id="bio" name="bio"></textarea>
            </div>
            
            <button type="submit" class="btn">注册</button>
        </form>
        
        <p style="margin-top: 15px;">
            已有账号? <a href="login.jsp">立即登录</a>
        </p>
    </div>
</body>
</html>