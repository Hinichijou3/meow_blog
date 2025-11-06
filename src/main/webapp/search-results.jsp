<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>搜索结果 - 我的博客</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .search-header {
            background-color: #f8f9fa;
            padding: 2rem 0;
            margin-bottom: 2rem;
            border-bottom: 1px solid #dee2e6;
        }
        .tag {
            display: inline-block;
            padding: 0.25em 0.6em;
            margin: 0.2em;
            font-size: 0.875em;
            background-color: #6c757d;
            color: white;
            border-radius: 0.25rem;
            text-decoration: none;
            transition: background-color 0.3s;
        }
        .tag:hover {
            background-color: #545b62;
            color: white;
            text-decoration: none;
        }
        .post-card {
            border: 1px solid #e9ecef;
            border-radius: 0.5rem;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            transition: box-shadow 0.3s;
        }
        .post-card:hover {
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
        }
        .post-meta {
            font-size: 0.875rem;
            color: #6c757d;
        }
        .search-box-sidebar {
            background: #f8f9fa;
            padding: 1.5rem;
            border-radius: 0.5rem;
            margin-bottom: 2rem;
        }
    </style>
</head>
<body>
    <!-- 搜索头部 -->
    <div class="search-header">
        <div class="container">
            <div class="row">
                <div class="col-lg-8">
                    <h1 class="h3">
                        <c:choose>
                            <c:when test="${searchType == 'keyword'}">
                                搜索 "<strong>${searchKeyword}</strong>"
                            </c:when>
                            <c:when test="${searchType == 'tag'}">
                                标签 "<strong>${tagName}</strong>"
                            </c:when>
                            <c:otherwise>
                                搜索文章
                            </c:otherwise>
                        </c:choose>
                    </h1>
                    <p class="text-muted mb-0">
                        <c:choose>
                            <c:when test="${resultCount > 0}">
                                找到 ${resultCount} 条结果
                            </c:when>
                            <c:otherwise>
                                没有找到相关文章
                            </c:otherwise>
                        </c:choose>
                    </p>
                </div>
                <div class="col-lg-4">
                    <!-- 侧边栏搜索框 -->
                    <div class="search-box-sidebar">
                        <form action="search" method="get">
                            <div class="input-group">
                                <input type="text" name="keyword" class="form-control" 
                                       placeholder="重新搜索..." value="${searchKeyword}">
                                <button class="btn btn-primary" type="submit">
                                    <i class="fas fa-search"></i>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="container">
        <div class="row">
            <!-- 搜索结果列表 -->
            <div class="col-lg-8">
                <c:if test="${not empty posts}">
                    <c:forEach var="post" items="${posts}">
                        <div class="post-card">
                            <h3>
                                <a href="post?id=${post.id}" class="text-decoration-none">
                                    ${post.title}
                                </a>
                            </h3>
                            
                            <p class="text-muted">${post.excerpt}</p>
                            
                            <div class="post-meta mb-2">
                                <span><i class="fas fa-user"></i> ${post.author}</span>
                                <span class="ms-3"><i class="fas fa-calendar"></i> ${post.createdAt}</span>
                                <span class="ms-3"><i class="fas fa-eye"></i> ${post.viewCount}</span>
                                <span class="ms-3"><i class="fas fa-comments"></i> ${post.commentCount}</span>
                            </div>
                            
                            <div class="post-tags">
                                <c:forEach var="tag" items="${post.tags}">
                                    <a href="search?tag=${tag}" class="tag">
                                        <i class="fas fa-tag"></i> ${tag}
                                    </a>
                                </c:forEach>
                            </div>
                        </div>
                    </c:forEach>
                </c:if>
                
                <c:if test="${empty posts && resultCount == 0}">
                    <div class="text-center py-5">
                        <i class="fas fa-search fa-3x text-muted mb-3"></i>
                        <h4 class="text-muted">没有找到相关文章</h4>
                        <p class="text-muted">尝试使用其他关键词搜索，或浏览热门标签</p>
                    </div>
                </c:if>
            </div>
            
            <!-- 侧边栏 -->
            <div class="col-lg-4">
                <!-- 热门标签 -->
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0">
                            <i class="fas fa-tags"></i> 热门标签
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="tags-cloud">
                            <c:forEach var="tag" items="${popularTags}">
                                <a href="search?tag=${tag}" class="tag mb-2">
                                    ${tag}
                                </a>
                            </c:forEach>
                        </div>
                    </div>
                </div>
                
                <!-- 搜索提示 -->
                <div class="card mt-4">
                    <div class="card-header">
                        <h5 class="card-title mb-0">
                            <i class="fas fa-lightbulb"></i> 搜索提示
                        </h5>
                    </div>
                    <div class="card-body">
                        <ul class="list-unstyled mb-0">
                            <li><small class="text-muted">• 使用关键词搜索文章标题和内容</small></li>
                            <li><small class="text-muted">• 点击标签查看相关文章</small></li>
                            <li><small class="text-muted">• 尝试使用更具体的关键词</small></li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>