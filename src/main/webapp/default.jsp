<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.yourblog.dao.PostDAO, com.yourblog.model.Post, java.util.List" %>
<%@ page import="com.yourblog.model.User" %>
<%@ page import="com.yourblog.dao.CoinDAO" %>
<%@ page import="com.yourblog.dao.CommentDAO" %>
<%@ page import="com.yourblog.dao.MessageDAO" %>
<%@ page import="com.yourblog.dao.AdDAO" %>
<%@ page import="com.yourblog.model.Ad" %>
<%@ page import="com.yourblog.util.UserSessionUtil" %>
<%
System.out.println("=== 开始加载首页 ===");

// 获取当前登录用户（带自动刷新）
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

// 获取广告数据
AdDAO adDao = new AdDAO();
List<Ad> carouselAds = adDao.getActiveCarouselAds();
List<Ad> singleAds = adDao.getActiveSingleAds();
System.out.println("轮播广告数量: " + carouselAds.size());
System.out.println("单图广告数量: " + singleAds.size());
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
	<link rel="stylesheet" href="https://use.fontawesome.com/releases/v6.6.0/css/all.css">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>多用户博客系统</title>
    <style>
        /* 重置和基础样式 */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        /* 全局背景图样式 - 跟随滚动 */
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            line-height: 1.6; 
            color: #333; 
            /* 背景图设置 - 跟随页面滚动 */
            background-image: url('images/backgrounds/blog-bg.jpg');
            background-size: cover;
            background-position: center top; /* 从顶部开始 */
            background-attachment: scroll; /* 改为scroll让背景跟随滚动 */
            background-repeat: no-repeat;
            min-height: 100vh;
            /* 确保背景覆盖整个内容区域 */
            background-color: #f5f5f5; /* 备用背景色 */
        }
        
        /* 为长内容页面创建更长的背景 */
        body::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 200%; /* 创建更长的背景区域 */
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
            display: grid;
            grid-template-columns: 1fr 300px;
            gap: 30px;
            align-items: start;
        }
        
        /* 主要内容区域 */
        .main-content {
            grid-column: 1;
        }
        
        /* 侧边栏区域 */
        .sidebar {
            grid-column: 2;
            position: sticky;
            top: 20px;
        }
        
        /* 头部样式 - 移除紫色蒙版 */
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
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            grid-column: 1 / -1; /* 头部横跨所有列 */
        }
        
        .profile-img { 
            width: 120px; 
            height: 120px; 
            border-radius: 50%; 
            border: 4px solid rgba(255, 255, 255, 0.8); 
            margin-bottom: 20px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
            transition: transform 0.3s ease;
        }
        .profile-img:hover {
            transform: scale(1.05);
        }
        h1 { 
            font-size: 2.5em; 
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
        }
        .tagline { 
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
            grid-column: 1 / -1; /* 导航栏横跨所有列 */
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
        
        /* 搜索框样式 */
        .search-box {
            margin-left: auto;
            margin-right: 20px;
        }
        .search-box .input-group {
            max-width: 300px;
        }
        .search-box .form-control {
            border-radius: 20px 0 0 20px;
            border: 1px solid #ddd;
            padding: 8px 15px;
        }
        .search-box .btn {
            border-radius: 0 20px 20px 0;
            background: #667eea;
            color: white;
            border: 1px solid #667eea;
            padding: 8px 15px;
        }
        .search-box .btn:hover {
            background: #764ba2;
            border-color: #764ba2;
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
        
        /* 文章列表样式 */
        .blog-posts { 
            display: grid; 
            gap: 20px; 
        }
        .post-card { 
            background: rgba(255, 255, 255, 0.95); 
            padding: 25px; 
            border-radius: 12px; 
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
        .post-card:hover { 
            transform: translateY(-5px); 
            box-shadow: 0 8px 30px rgba(0,0,0,0.15);
        }
        .post-title { 
            color: #333; 
            margin-bottom: 10px; 
            font-size: 1.4em;
            font-weight: 600;
        }
        .post-meta { 
            color: #666; 
            font-size: 0.9em; 
            margin-bottom: 15px; 
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
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
            padding: 8px 16px;
            border: 1px solid #667eea;
            border-radius: 6px;
            transition: all 0.3s ease;
        }
        .read-more:hover {
            background: #667eea;
            color: white;
            transform: translateX(5px);
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
            grid-column: 1 / -1; /* 页脚横跨所有列 */
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
        
        /* 广告样式 */
        .carousel-ad-container {
            margin-bottom: 30px;
        }
        
        .carousel-ad {
            background: white;
            border-radius: 12px;
            padding: 15px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }
        
        .carousel-wrapper {
            position: relative;
            height: 200px;
            overflow: hidden;
            border-radius: 8px;
        }
        
        .carousel-item {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            opacity: 0;
            transition: opacity 0.5s ease;
        }
        
        /* 侧边栏单图广告样式 */
        .sidebar-ad {
		    background: white;
		    border-radius: 12px;
		    padding: 20px;
		    box-shadow: 0 4px 20px rgba(0,0,0,0.1);
		    text-align: center;
		    margin-bottom: 20px; /* 添加底部间距，使广告之间有空隙 */
		    transition: transform 0.3s ease, box-shadow 0.3s ease;
		}
		
		.sidebar-ad:hover {
		    transform: translateY(-3px);
		    box-shadow: 0 6px 25px rgba(0,0,0,0.15);
		}
        
        .sidebar-ad img {
		    max-width: 100%;
		    height: auto;
		    border-radius: 8px;
		    margin-bottom: 10px;
		    transition: transform 0.3s ease;
		}
		
		.sidebar-ad:hover img {
		    transform: scale(1.02);
		}
        
        .sidebar-ad-title {
		    font-weight: 600;
		    color: #333;
		    margin-bottom: 5px;
		    font-size: 1em;
		}
		
		.sidebar-ad-label {
		    color: #666;
		    font-size: 0.9em;
		    margin-bottom: 15px;
		    display: flex;
		    align-items: center;
		    justify-content: center;
		    gap: 5px;
		}
        
        /* 响应式设计 */
		@media (max-width: 1024px) {
		    .sidebar {
		        grid-column: 1;
		        position: static;
		        display: grid;
		        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
		        gap: 20px;
		    }
		    
		    .sidebar-ad {
		        margin-bottom: 0;
		    }
		}
            
            .sidebar-ad {
                margin-bottom: 0;
            }
        }
        
        @media (max-width: 768px) {
		    .sidebar {
		        grid-template-columns: 1fr;
		    }
		    
		    .sidebar-ad {
		        margin-bottom: 20px;
		    }
		}
        
        @media (max-width: 768px) {
            /* 移动端取消背景滚动效果，改为固定背景 */
            body {
                background-attachment: fixed;
            }
            
            body::before {
                display: none; /* 移动端隐藏伪元素背景 */
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
            
            .search-box {
                margin: 10px 0;
                width: 100%;
            }
            
            .search-box .input-group {
                max-width: 100%;
            }
            
            .coins-info {
                order: -1;
                margin-bottom: 10px;
                justify-content: center;
            }
            
            .post-meta {
                flex-direction: column;
                gap: 5px;
            }
            
            .carousel-wrapper {
                height: 150px;
            }
            
            .sidebar {
                grid-template-columns: 1fr;
            }
        }
        
        /* 标签样式 */
        .tag {
            display: inline-block;
            padding: 0.25em 0.6em;
            margin: 0.2em;
            font-size: 0.875em;
            background-color: #6c757d;
            color: white;
            border-radius: 0.25rem;
            text-decoration: none;
            transition: all 0.3s ease;
        }
        .tag:hover {
            background-color: #545b62;
            color: white;
            text-decoration: none;
            transform: translateY(-1px);
        }
        
        /* 热门标签样式 */
        .popular-tags {
            background: rgba(255, 255, 255, 0.9);
            padding: 1.5rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .tags-cloud {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
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
        
        /* 侧边栏其他组件样式 */
        .sidebar-widget {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            margin-bottom: 25px;
        }
        
        .sidebar-widget h3 {
            margin-bottom: 15px;
            color: #333;
            font-size: 1.2em;
            border-bottom: 2px solid #667eea;
            padding-bottom: 8px;
        }
    </style>
</head>
<body>
    <!-- 背景渐变过渡层 -->
    <div class="background-transition"></div>
    
    <div class="container">
        <!-- 个性化头部 - 已移除蒙版 -->
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

        <!-- 导航栏 -->
        <nav>
            <ul>
                <li><a href="default.jsp">首页</a></li>
                <li><a href="store.jsp">广告商店</a></li>
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
				            <div class="coins-info">
				                <span style="color: #ffd700; font-weight: bold;">🪙</span>
				                <span id="navUserCoins" style="color: #555; font-weight: 500;"><%= currentUser.getCoins() %></span>
				                <% if (!coinDao.hasLoggedInToday(currentUser.getId())) { %>
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
        
        <!-- 主要内容区域 -->
        <div class="main-content">
            <!-- 轮播广告位 -->
            <%
            if (carouselAds != null && !carouselAds.isEmpty()) {
                // 更新浏览量
                for (Ad ad : carouselAds) {
                    adDao.incrementViews(ad.getId());
                }
            %>
            <div class="carousel-ad-container">
                <div class="carousel-ad">
                    <h4 style="margin-bottom: 15px; color: #333; text-align: center;">📢 推荐内容</h4>
                    <div class="carousel-wrapper">
                        <% for (Ad ad : carouselAds) { %>
                        <div class="carousel-item">
                            <a href="ad-track?adId=<%= ad.getId() %>&targetUrl=<%= java.net.URLEncoder.encode(ad.getTargetUrl(), "UTF-8") %>" 
                               target="_blank" style="display: block; width: 100%; height: 100%;">
                                <img src="<%= ad.getImageUrl() %>" 
                                     alt="<%= ad.getTitle() %>" 
                                     style="width: 100%; height: 100%; object-fit: cover;"
                                     onerror="this.src='images/default-ad.jpg'">
                                <div style="position: absolute; bottom: 0; left: 0; right: 0; background: linear-gradient(transparent, rgba(0,0,0,0.7)); color: white; padding: 10px;">
                                    <h5 style="margin: 0; font-size: 1.1em;"><%= ad.getTitle() %></h5>
                                </div>
                            </a>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
            <%
            } else {
                System.out.println("没有可显示的轮播广告");
            }
            %>
           

            <!-- 文章列表 -->
            <div class="blog-posts">
                <%-- 动态生成文章列表 --%>
                <%
                    if (posts != null && !posts.isEmpty()) {
                        for (Post post : posts) {
                            // 获取文章的标签
                            List<String> tags = postDao.getTagsByPostId(post.getId());
                %>
                <article class="post-card">
                    <h2 class="post-title">
                        <a href="view-post.jsp?id=<%= post.getId() %>" style="color: inherit; text-decoration: none;">
                            <%= post.getTitle() %>
                        </a>
                    </h2>
                    <div class="post-meta">
                        <span class="post-date"><i class="far fa-calendar"></i> <%= post.getCreatedAt() %></span>
                        <span class="post-views"><i class="far fa-eye"></i> <%= post.getViewCount() %></span>
                        <span class="post-author"><i class="far fa-user"></i> <%= post.getAuthor() != null ? post.getAuthor() : "匿名" %></span>
                    	<span class="post-comments"><i class="far fa-comments"></i> <%= post.getCommentCount() %></span>
                    </div>
                    <p class="post-excerpt">
                        <%= post.getExcerpt() != null ? post.getExcerpt() : "" %>
                    </p>
                    
                    <!-- 文章标签 -->
                    <% if (tags != null && !tags.isEmpty()) { %>
                    <div class="post-tags" style="margin-top: 10px;">
                        <% for (String tag : tags) { %>
                            <a href="search?tag=<%= java.net.URLEncoder.encode(tag, "UTF-8") %>" class="tag">
                                <i class="fas fa-tag"></i> <%= tag %>
                            </a>
                        <% } %>
                    </div>
                    <% } %>
                    
                    <a href="view-post.jsp?id=<%= post.getId() %>" class="read-more">
                        阅读全文 <i class="fas fa-arrow-right"></i>
                    </a>
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
        </div> <!-- 主要内容区域结束 -->
        
        <!-- 侧边栏区域 -->
		<div class="sidebar">
		    <!-- 单图广告位 - 多个广告垂直排列 -->
		    <%
		    if (singleAds != null && !singleAds.isEmpty()) {
		        for (Ad singleAd : singleAds) {
		            adDao.incrementViews(singleAd.getId());
		    %>
		    <div class="sidebar-ad">
		        <div class="sidebar-ad-label">📣 赞助商广告</div>
		        <a href="ad-track?adId=<%= singleAd.getId() %>&targetUrl=<%= java.net.URLEncoder.encode(singleAd.getTargetUrl(), "UTF-8") %>" 
		           target="_blank">
		            <img src="<%= singleAd.getImageUrl() %>" 
		                 alt="<%= singleAd.getTitle() %>"
		                 onerror="this.src='images/default-ad.jpg'">
		        </a>
		        <div class="sidebar-ad-title"><%= singleAd.getTitle() %></div>
		        <div class="sidebar-ad-stats" style="font-size: 0.8em; color: #666; margin-top: 5px;">
		            浏览: <%= singleAd.getViews() %> | 点击: <%= singleAd.getClicks() %>
		        </div>
		    </div>
		    <%
		        }
		    } else {
		        System.out.println("没有可显示的单图广告");
		    %>
		    <!-- 如果没有单图广告，显示默认内容 -->
		    <div class="sidebar-widget">
		        <h3><i class="fas fa-bullhorn"></i> 广告位招租</h3>
		        <p>这个位置可以展示您的广告</p>
		        <p style="color: #667eea; font-weight: 500; margin-top: 10px;">
		            <i class="fas fa-coins"></i> 仅需 10 硬币/月
		        </p>
		        <a href="store.jsp" class="read-more" style="display: inline-block; margin-top: 10px;">
		            立即购买 <i class="fas fa-arrow-right"></i>
		        </a>
		    </div>
		    <%
		    }
		    %>
		    
		    <!-- 其他侧边栏组件 -->

		    <div class="sidebar-widget">
		        <h3><i class="fas fa-info-circle"></i> 关于我们</h3>
		        <p>欢迎来到多用户博客系统！这里是一个分享知识和经验的平台。</p>
		        <p style="margin-top: 10px;">
		            <a href="register.jsp" class="read-more" style="display: inline-block;">
		                加入我们 <i class="fas fa-user-plus"></i>
		            </a>
		        </p>
		    </div>
		</div> 
		<!-- 侧边栏区域结束 -->

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
		
		// 动态调整背景高度以适应长内容
		window.addEventListener('load', function() {
		    const body = document.body;
		    const html = document.documentElement;
		    const contentHeight = Math.max(
		        body.scrollHeight, body.offsetHeight,
		        html.clientHeight, html.scrollHeight, html.offsetHeight
		    );
		    
		    // 如果内容高度超过视口高度，延长背景
		    if (contentHeight > window.innerHeight) {
		        const backgroundHeight = contentHeight * 1.2; // 背景比内容稍长
		        document.querySelector('body::before').style.height = backgroundHeight + 'px';
		    }
		});
		
		// 轮播广告自动切换
		document.addEventListener('DOMContentLoaded', function() {
		    const items = document.querySelectorAll('.carousel-item');
		    console.log('找到轮播广告项目:', items.length);
		    
		    if (items.length > 0) {
		        let currentIndex = 0;
		        
		        // 显示第一个项目
		        items[0].style.opacity = '1';
		        console.log('显示第一个轮播广告');
		        
		        setInterval(() => {
		            // 隐藏当前项目
		            items[currentIndex].style.opacity = '0';
		            
		            // 移动到下一个项目
		            currentIndex = (currentIndex + 1) % items.length;
		            
		            // 显示下一个项目
		            setTimeout(() => {
		                items[currentIndex].style.opacity = '1';
		            }, 500);
		            
		        }, 5000); // 每5秒切换一次
		    }
		});
	</script>
</body>
</html>