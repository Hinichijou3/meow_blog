<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.yourblog.model.User" %>
<%@ page import="com.yourblog.dao.AdDAO, com.yourblog.model.Ad, java.util.List" %>
<%@ page import="com.yourblog.util.UserSessionUtil" %>

<%
// 使用带刷新的方式获取用户信息
User currentUser = (User) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

AdDAO adDao = new AdDAO();
List<Ad> userAds = adDao.getAdsByUserId(currentUser.getId());
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>广告商店 - 多用户博客系统</title>
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v6.6.0/css/all.css">
    <style>
        /* 返回首页按钮样式 */
        .back-to-home-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: #6c757d;
            color: white;
            text-decoration: none;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: 500;
            transition: all 0.3s ease;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .back-to-home-btn:hover {
            background: #5a6268;
            color: white;
            text-decoration: none;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }

        .back-to-home-btn i {
            font-size: 0.9em;
        }

        /* 商店容器样式 */
        .store-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        /* 广告套餐样式 */
        .ad-packages {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }
        
        .ad-package {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            text-align: center;
            transition: transform 0.3s ease;
        }
        
        .ad-package:hover {
            transform: translateY(-5px);
        }
        
        .ad-package.carousel {
            border-top: 4px solid #667eea;
        }
        
        .ad-package.single {
            border-top: 4px solid #28a745;
        }
        
        .package-price {
            font-size: 2em;
            color: #ff6b6b;
            margin: 15px 0;
        }
        
        .package-features {
            list-style: none;
            padding: 0;
            margin: 20px 0;
        }
        
        .package-features li {
            padding: 8px 0;
            border-bottom: 1px solid #eee;
        }
        
        .buy-btn {
            background: #667eea;
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 25px;
            cursor: pointer;
            font-size: 1.1em;
            transition: background 0.3s ease;
        }
        
        .buy-btn:hover {
            background: #764ba2;
        }
        
        /* 用户广告列表样式 */
        .user-ads {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }
        
        .ad-item {
            display: flex;
            align-items: center;
            padding: 15px;
            border-bottom: 1px solid #eee;
        }
        
        .ad-item:last-child {
            border-bottom: none;
        }
        
        .ad-image {
            width: 100px;
            height: 60px;
            object-fit: cover;
            border-radius: 6px;
            margin-right: 20px;
        }
        
        .ad-info {
            flex: 1;
        }
        
        .ad-stats {
            color: #666;
            font-size: 0.9em;
        }
        
        /* 表单样式 */
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
        }
        
        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 1em;
        }
        
        /* 文件上传样式 */
        .file-upload-container {
            border: 2px dashed #ddd;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            background: #fafafa;
        }
        
        .upload-icon {
            font-size: 2em;
            color: #667eea;
            margin-bottom: 10px;
        }
        
        .upload-text {
            margin-bottom: 15px;
            color: #666;
        }
        
        .browse-btn {
            background: #667eea;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
            transition: background 0.3s ease;
        }
        
        .browse-btn:hover {
            background: #764ba2;
        }
        
        .file-info {
            margin-top: 10px;
            font-size: 0.9em;
            color: #666;
        }

        /* 广告操作按钮样式 */
        .ad-actions {
            display: flex;
            gap: 10px;
            margin-left: 15px;
        }

        .delete-ad-btn {
            background: #dc3545;
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.9em;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .delete-ad-btn:hover {
            background: #c82333;
            transform: translateY(-1px);
        }

        /* 广告预览样式 */
        .preview-section {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }

        .preview-title {
            margin-bottom: 20px;
            color: #333;
            border-bottom: 2px solid #667eea;
            padding-bottom: 10px;
        }

        .preview-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
        }

        .preview-item {
            border: 2px solid #eee;
            border-radius: 8px;
            padding: 15px;
        }

        .preview-label {
            font-weight: 600;
            margin-bottom: 10px;
            color: #333;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .preview-label i {
            color: #667eea;
        }

        .preview-dimensions {
            font-size: 0.8em;
            color: #666;
            margin-bottom: 10px;
        }

        .carousel-preview {
            width: 100%;
            height: 120px;
            background: #f8f9fa;
            border-radius: 6px;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }

        .single-preview {
            width: 100%;
            height: 200px;
            background: #f8f9fa;
            border-radius: 6px;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }

        .preview-image {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }

        .preview-placeholder {
            color: #999;
            text-align: center;
        }

        .preview-placeholder i {
            font-size: 2em;
            margin-bottom: 10px;
            display: block;
        }

        .recommendation {
            background: #e7f3ff;
            border-left: 4px solid #667eea;
            padding: 10px 15px;
            margin-top: 10px;
            border-radius: 4px;
            font-size: 0.9em;
        }

        /* 模态框样式 */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
        }

        .modal-content {
            background-color: white;
            margin: 15% auto;
            padding: 20px;
            border-radius: 12px;
            width: 400px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
            animation: modalFadeIn 0.3s;
        }

        @keyframes modalFadeIn {
            from {
                opacity: 0;
                transform: translateY(-50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* 响应式设计 */
        @media (max-width: 768px) {
            .back-to-home-btn {
                width: 100%;
                justify-content: center;
                padding: 12px 20px;
            }
            
            .store-container {
                padding: 15px;
            }

            .ad-item {
                flex-direction: column;
                text-align: center;
            }
            
            .ad-image {
                margin-right: 0;
                margin-bottom: 15px;
            }
            
            .ad-actions {
                margin-left: 0;
                margin-top: 15px;
                justify-content: center;
            }
            
            .modal-content {
                width: 90%;
                margin: 20% auto;
            }

            .preview-container {
                grid-template-columns: 1fr;
                gap: 20px;
            }

            .carousel-preview {
                height: 100px;
            }

            .single-preview {
                height: 150px;
            }
        }
    </style>
</head>
<body>
    
    <div class="store-container">
        <!-- 返回首页按钮 -->
        <div style="margin-bottom: 20px;">
            <a href="default.jsp" class="back-to-home-btn">
                <i class="fas fa-arrow-left"></i> 返回首页
            </a>
        </div>
        
        <h1>广告商店</h1>
        <p>当前硬币: <strong style="color: #ffd700;">🪙 <%= currentUser.getCoins() %></strong></p>
        
        <% if (request.getAttribute("success") != null) { %>
            <div style="background: #d4edda; color: #155724; padding: 12px; border-radius: 6px; margin-bottom: 20px;">
                <%= request.getAttribute("success") %>
            </div>
        <% } %>
        
        <% if (request.getAttribute("error") != null) { %>
            <div style="background: #f8d7da; color: #721c24; padding: 12px; border-radius: 6px; margin-bottom: 20px;">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>
        
        <!-- 广告效果预览 -->
        <div class="preview-section">
            <h3 class="preview-title"><i class="fas fa-eye"></i> 广告效果预览</h3>
            <div class="preview-container">
                <div class="preview-item">
                    <div class="preview-label">
                        <i class="fas fa-images"></i> 轮播广告预览
                    </div>
                    <div class="preview-dimensions">推荐尺寸: 1200 × 200 像素 (6:1 横屏)</div>
                    <div class="carousel-preview">
                        <div class="preview-placeholder" id="carouselPlaceholder">
                            <i class="fas fa-image"></i>
                            <div>轮播广告预览</div>
                        </div>
                        <img id="carouselPreviewImg" class="preview-image" style="display: none;">
                    </div>
                    <div class="recommendation">
                        建议使用横向图片，避免重要内容被裁剪
                    </div>
                </div>
                
                <div class="preview-item">
                    <div class="preview-label">
                        <i class="fas fa-ad"></i> 单图广告预览
                    </div>
                    <div class="preview-dimensions">推荐尺寸: 300 × 400 像素 (3:4 竖屏)</div>
                    <div class="single-preview">
                        <div class="preview-placeholder" id="singlePlaceholder">
                            <i class="fas fa-image"></i>
                            <div>单图广告预览</div>
                        </div>
                        <img id="singlePreviewImg" class="preview-image" style="display: none;">
                    </div>
                    <div class="recommendation">
                        建议使用竖向图片，适合侧边栏展示
                    </div>
                </div>
            </div>
        </div>
        
        <div class="ad-packages">
            <div class="ad-package carousel">
                <h3>轮播广告位</h3>
                <div class="package-price">🪙 15 硬币/月</div>
                <ul class="package-features">
                    <li>在首页导航栏下方展示</li>
                    <li>轮播显示，多个广告交替展示</li>
                    <li>吸引更多用户点击</li>
                    <li>展示期限: 30天</li>
                </ul>
                <button class="buy-btn" onclick="showPurchaseForm('carousel', 15)">购买</button>
            </div>
            
            <div class="ad-package single">
                <h3>单图广告位</h3>
                <div class="package-price">🪙 10 硬币/月</div>
                <ul class="package-features">
                    <li>在首页侧边固定位置展示</li>
                    <li>静态图片，持续曝光</li>
                    <li>适合品牌宣传</li>
                    <li>展示期限: 30天</li>
                </ul>
                <button class="buy-btn" onclick="showPurchaseForm('single', 10)">购买</button>
            </div>
        </div>
        
        <!-- 购买表单 -->
        <div id="purchaseForm" style="display: none; background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); margin-bottom: 40px;">
            <h3>购买广告</h3>
            <form action="ad" method="post" enctype="multipart/form-data">
                <input type="hidden" name="action" value="purchase">
                <input type="hidden" name="adType" id="formAdType">
                <input type="hidden" name="price" id="formPrice">
                
                <div class="form-group">
                    <label for="title">广告标题:</label>
                    <input type="text" id="title" name="title" class="form-control" required>
                </div>
                
                <div class="form-group">
                    <label for="imageFile">广告图片:</label>
                    <input type="file" id="imageFile" name="imageFile" accept="image/*" required 
                           onchange="handleFileSelect(this)" style="margin-bottom: 10px;">
                    <div class="file-info" id="fileInfo" style="display: none;"></div>
                </div>
                
                <div class="form-group">
                    <label for="targetUrl">目标链接:</label>
                    <input type="url" id="targetUrl" name="targetUrl" class="form-control" required 
                           placeholder="https://example.com">
                </div>
                
                <div style="display: flex; gap: 10px;">
                    <button type="submit" class="buy-btn">确认购买</button>
                    <button type="button" class="buy-btn" style="background: #6c757d;" onclick="hidePurchaseForm()">取消</button>
                </div>
            </form>
        </div>
        
        <!-- 用户广告列表 -->
        <div class="user-ads">
            <h3>我的广告</h3>
            <% if (userAds.isEmpty()) { %>
                <p>您还没有购买任何广告</p>
            <% } else { %>
                <% for (Ad ad : userAds) { %>
                    <div class="ad-item">
                        <img src="<%= ad.getImageUrl() %>" alt="<%= ad.getTitle() %>" class="ad-image" 
                             onerror="this.src='images/default-ad.jpg'">
                        <div class="ad-info">
                            <h4><%= ad.getTitle() %></h4>
                            <p>
                                <%= ad.getAdType().equals("carousel") ? "轮播广告" : "单图广告" %> | 
                                状态: <span style="color: <%= ad.getStatus().equals("active") ? "#28a745" : "#dc3545" %>">
                                <%= ad.getStatus().equals("active") ? "活跃" : "未激活" %></span> |
                                价格: <span style="color: #ff6b6b;">🪙 <%= ad.getPrice() %></span>
                            </p>
                            <div class="ad-stats">
                                浏览: <%= ad.getViews() %> | 点击: <%= ad.getClicks() %> | 
                                点击率: <%= ad.getViews() > 0 ? String.format("%.2f", (double)ad.getClicks() / ad.getViews() * 100) : 0 %>%
                            </div>
                            <div class="ad-dates" style="font-size: 0.8em; color: #888; margin-top: 5px;">
                                开始: <%= ad.getStartDate() %> | 结束: <%= ad.getEndDate() %>
                            </div>
                        </div>
                        <div class="ad-actions">
                            <button class="delete-ad-btn" onclick="confirmDeleteAd(<%= ad.getId() %>, '<%= ad.getTitle() %>')">
                                <i class="fas fa-trash"></i> 删除
                            </button>
                        </div>
                    </div>
                <% } %>
            <% } %>
        </div>
        
        <!-- 删除确认模态框 -->
        <div id="deleteModal" class="modal" style="display: none;">
            <div class="modal-content">
                <h3>确认删除广告</h3>
                <p id="deleteMessage" style="margin: 15px 0;">您确定要删除这个广告吗？</p>
                <p style="color: #dc3545; font-size: 0.9em; margin: 10px 0;">
                    <i class="fas fa-exclamation-triangle"></i> 删除后无法恢复，且不会退还硬币！
                </p>
                <div style="display: flex; gap: 10px; justify-content: flex-end; margin-top: 20px;">
                    <button type="button" class="btn-cancel" onclick="closeDeleteModal()" style="background: #6c757d; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;">取消</button>
                    <button type="button" class="btn-confirm" onclick="deleteAd()" style="background: #dc3545; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;">确认删除</button>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        let adToDelete = null;
        
        // 文件选择处理
        function handleFileSelect(input) {
            const file = input.files[0];
            const fileInfo = document.getElementById('fileInfo');
            
            if (file) {
                // 显示文件信息
                fileInfo.innerHTML = 
                    '<strong>已选择文件:</strong> ' + file.name + '<br>' +
                    '<strong>文件大小:</strong> ' + (file.size / 1024 / 1024).toFixed(2) + ' MB<br>' +
                    '<strong>文件类型:</strong> ' + file.type;
                fileInfo.style.display = 'block';
                
                // 预览图片
                previewImage(file);
            }
        }
        
        // 图片预览功能
        function previewImage(file) {
            const reader = new FileReader();
            
            reader.onload = function(e) {
                const imageUrl = e.target.result;
                
                // 更新轮播广告预览
                const carouselPreviewImg = document.getElementById('carouselPreviewImg');
                const carouselPlaceholder = document.getElementById('carouselPlaceholder');
                carouselPreviewImg.src = imageUrl;
                carouselPreviewImg.style.display = 'block';
                carouselPlaceholder.style.display = 'none';
                
                // 更新单图广告预览
                const singlePreviewImg = document.getElementById('singlePreviewImg');
                const singlePlaceholder = document.getElementById('singlePlaceholder');
                singlePreviewImg.src = imageUrl;
                singlePreviewImg.style.display = 'block';
                singlePlaceholder.style.display = 'none';
                
                // 检查图片尺寸并给出建议
                const img = new Image();
                img.onload = function() {
                    const width = img.width;
                    const height = img.height;
                    const aspectRatio = width / height;
                    
                    // 更新文件信息，添加尺寸信息
                    const fileInfo = document.getElementById('fileInfo');
                    fileInfo.innerHTML += '<br><strong>图片尺寸:</strong> ' + width + ' × ' + height + ' 像素';
                    
                    // 给出建议
                    let recommendation = '';
                    if (aspectRatio > 1.5) {
                        recommendation = '这张图片适合轮播广告（横屏）';
                    } else if (aspectRatio < 0.8) {
                        recommendation = '这张图片适合单图广告（竖屏）';
                    } else {
                        recommendation = '这张图片比例较为均衡，两种广告位都适用';
                    }
                    
                    fileInfo.innerHTML += '<br><strong>建议:</strong> ' + recommendation;
                };
                img.src = imageUrl;
            };
            
            reader.readAsDataURL(file);
        }
        
        // 显示购买表单
        function showPurchaseForm(adType, price) {
            document.getElementById('formAdType').value = adType;
            document.getElementById('formPrice').value = price;
            document.getElementById('purchaseForm').style.display = 'block';
            
            // 重置表单
            document.querySelector('form').reset();
            document.getElementById('fileInfo').style.display = 'none';
            
            // 重置预览
            resetPreview();
            
            document.getElementById('purchaseForm').scrollIntoView({ behavior: 'smooth' });
        }
        
        // 重置预览
        function resetPreview() {
            // 重置轮播广告预览
            const carouselPreviewImg = document.getElementById('carouselPreviewImg');
            const carouselPlaceholder = document.getElementById('carouselPlaceholder');
            carouselPreviewImg.style.display = 'none';
            carouselPlaceholder.style.display = 'block';
            
            // 重置单图广告预览
            const singlePreviewImg = document.getElementById('singlePreviewImg');
            const singlePlaceholder = document.getElementById('singlePlaceholder');
            singlePreviewImg.style.display = 'none';
            singlePlaceholder.style.display = 'block';
        }
        
        function hidePurchaseForm() {
            document.getElementById('purchaseForm').style.display = 'none';
        }
        
        // 删除广告相关函数
        function confirmDeleteAd(adId, adTitle) {
            adToDelete = adId;
            document.getElementById('deleteMessage').textContent = '您确定要删除广告 "' + adTitle + '" 吗？';
            document.getElementById('deleteModal').style.display = 'block';
        }
        
        function closeDeleteModal() {
            document.getElementById('deleteModal').style.display = 'none';
            adToDelete = null;
        }
        
        function deleteAd() {
            if (!adToDelete) {
                alert('请选择要删除的广告');
                return;
            }
            
            // 创建表单并提交
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'delete-ad';
            
            const adIdInput = document.createElement('input');
            adIdInput.type = 'hidden';
            adIdInput.name = 'adId';
            adIdInput.value = adToDelete;
            
            form.appendChild(adIdInput);
            document.body.appendChild(form);
            form.submit();
        }
        
        // 点击模态框外部关闭
        window.onclick = function(event) {
            const modal = document.getElementById('deleteModal');
            if (event.target === modal) {
                closeDeleteModal();
            }
        }
    </script>
</body>
</html>