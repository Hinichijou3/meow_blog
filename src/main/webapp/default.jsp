<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.yourblog.dao.PostDAO, com.yourblog.model.Post, java.util.List" %>
<%@ page import="com.yourblog.model.User" %>
<%@ page import="com.yourblog.dao.CoinDAO" %>
<%@ page import="com.yourblog.dao.CommentDAO" %>
<%@ page import="com.yourblog.dao.MessageDAO" %>
<%
System.out.println("=== 开始加载首页 ===");

// 获取当前登录用户
User currentUser = (User) session.getAttribute("user");

PostDAO postDao = new PostDAO();
List<Post> posts = null;

try {
    // 使用新的方法获取包含用户信息的文章列表
    posts = postDao.getAllPublishedPostsWithUsers();
    System.out.println("获取到文章数量: " + (posts != null ? posts.size() : "null"));
    
    if (posts != null && !posts.isEmpty()) {
        for (Post post : posts) {
            System.out.println("文章标题: " + post.getTitle() + ", 作者: " + post.getAuthor());
        }
    } else {
        System.out.println("文章列表为空或为null");
    }
} catch (Exception e) {
    System.err.println("获取文章时发生错误: " + e.getMessage());
    e.printStackTrace();
}

// 获取当前时间（用于页脚显示）
java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
String currentTime = sdf.format(new java.util.Date());
%>

<%
// 初始化硬币DAO
CoinDAO coinDao = new CoinDAO();
%>

<%
// 初始化评论DAO
CommentDAO commentDao = new CommentDAO();
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>多用户博客系统</title>
    <style>
        /* 重置和基础样式 */
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
        header {
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
        }
        header::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background-color: rgba(0, 0, 0, 0.4);
            z-index: 1;
        }
        header > * { 
            position: relative; 
            z-index: 2; 
        }
        
        .profile-img { 
            width: 120px; 
            height: 120px; 
            border-radius: 50%; 
            border: 4px solid white; 
            margin-bottom: 20px; 
        }
        h1 { 
            font-size: 2.5em; 
            margin-bottom: 10px; 
        }
        .tagline { 
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
        
        /* 文章列表样式 */
        .blog-posts { 
            display: grid; 
            gap: 20px; 
        }
        .post-card { 
            background: white; 
            padding: 25px; 
            border-radius: 8px; 
            box-shadow: 0 2px 10px rgba(0,0,0,0.1); 
            transition: transform 0.3s, box-shadow 0.3s; 
        }
        .post-card:hover { 
            transform: translateY(-5px); 
            box-shadow: 0 5px 20px rgba(0,0,0,0.15); 
        }
        .post-title { 
            color: #333; 
            margin-bottom: 10px; 
            font-size: 1.4em; 
        }
        .post-meta { 
            color: #666; 
            font-size: 0.9em; 
            margin-bottom: 15px; 
            display: flex;
            gap: 15px;
        }
        .post-author {
            color: #667eea;
            font-weight: 500;
        }
        .post-excerpt { 
            color: #555; 
            line-height: 1.6; 
        }
        .read-more { 
            display: inline-block; 
            margin-top: 15px; 
            color: #667eea; 
            text-decoration: none; 
            font-weight: 500; 
        }
        
        /* 页脚样式 */
        footer { 
            text-align: center; 
            margin-top: 50px; 
            padding: 20px; 
            color: #666; 
            border-top: 1px solid #ddd; 
        }
        
        /* 响应式设计 */
        @media (max-width: 768px) {
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

            /* 导航栏硬币信息样式 */
			.coins-info {
			    display: flex;
			    align-items: center;
			    gap: 8px;
			    padding: 5px 10px;
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
			    transition: background 0.3s;
			}
			
			.get-coin-btn-nav:hover {
			    background: #218838;
			    transform: translateY(-1px);
			}
			
			/* 响应式调整 */
			@media (max-width: 768px) {
			    .coins-info {
			        order: -1;
			        margin-bottom: 10px;
			        justify-content: center;
			    }
			    
			    .user-menu {
			        flex-direction: column;
			        gap: 10px;
			    }
			}
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- 个性化头部 -->
        <header>
    		<img src="<%= currentUser != null && currentUser.getAvatarUrl() != null ? currentUser.getAvatarUrl() : "images/avatars/default-avatar.jpg" %>" 
         		alt="用户头像" class="profile-img">
    		<h1>
        		<%
            		// 获取当前时间的小时数
            		java.util.Calendar calendar = java.util.Calendar.getInstance();
            		int hour = calendar.get(java.util.Calendar.HOUR_OF_DAY);
            		String greeting;
            
            		if (hour >= 5 && hour < 12) {
                		greeting = "🔆早上好";
            		} else if (hour >= 12 && hour < 14) {
                		greeting = "☀️中午好";
            		} else if (hour >= 14 && hour < 18) {
                		greeting = "🌄下午好";
            		} else if (hour >= 18 && hour < 22) {
                		greeting = "🌃晚上好";
            		} else {
                		greeting = "🌙夜深了";
            		}
            
            		// 根据登录状态显示不同的问候语
            		if (currentUser != null) {
                		out.print(greeting + "，" + currentUser.getDisplayName());
            		} else {
                		out.print(greeting + "，欢迎来到博客系统");
            		}
        		%>
    		</h1>
    		<p class="tagline">一个小小的博客~🎶</p>
		</header>

        <!-- 导航栏 - 已更新链接 -->
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
                <li><a href="settings.jsp">设置</a></li>
                
                <!-- 用户信息区域 -->
				<div class="user-info">
				    <% if (currentUser != null) { %>
				        <div class="user-menu">
				            <!-- 硬币信息 -->
				            <div class="coins-info" style="display: flex; align-items: center; gap: 10px; margin-right: 15px;">
				                <span style="color: #ffd700; font-weight: bold;">🪙</span>
				                <span id="navUserCoins" style="color: #555; font-weight: 500;"><%= currentUser.getCoins() %></span>
				                <% if (!coinDao.hasLoggedInToday(currentUser.getId())) { %>
				                    <button class="get-coin-btn-nav" onclick="getDailyCoinNav()" 
				                            style="background: #28a745; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; font-size: 12px;">
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

        <div class="blog-posts">
            <%-- 动态生成文章列表 --%>
            <%
                if (posts != null && !posts.isEmpty()) {
                    for (Post post : posts) {
            %>
            <article class="post-card">
                <h2 class="post-title"><%= post.getTitle() %></h2>
                <div class="post-meta">
                    <span class="post-date">发布于 <%= post.getCreatedAt() %></span>
                    <span class="post-views">阅读量 <%= post.getViewCount() %></span>
                    <span class="post-author">作者：<%= post.getAuthor() != null ? post.getAuthor() : "匿名" %></span>
                	<span class="post-comments">评论 <%= post.getCommentCount() %></span>
                </div>
                <p class="post-excerpt">
                    <%= post.getExcerpt() != null ? post.getExcerpt() : "" %>
                </p>
                <a href="view-post.jsp?id=<%= post.getId() %>" class="read-more">阅读全文 →</a>
            </article>
            <%
                    }
                } else {
            %>
            <article class="post-card">
                <h2 class="post-title">暂无文章</h2>
                <p class="post-excerpt">还没有发布任何文章，敬请期待！</p>
                <% if (currentUser != null) { %>
                    <a href="create-post.jsp" class="read-more">发布第一篇文章 →</a>
                <% } else { %>
                    <a href="register.jsp" class="read-more">注册成为作者 →</a>
                <% } %>
            </article>
            <%
                }
            %>
        </div>

        <footer>
            <p>
                © 2025 多用户博客系统 | 
                服务器时间：<%= currentTime %> | 
                文章总数：<%= posts != null ? posts.size() : 0 %> 篇 | 
                <% if (currentUser != null) { %>
                    欢迎, <%= currentUser.getUsername() %> |
                <% } %>
                Powered by JSP & MySQL
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
		    // 其他初始化代码
		});
		</script>
</body>
</html>