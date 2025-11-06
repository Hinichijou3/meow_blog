<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>文件上传测试</title>
</head>
<body>
    <h1>文件上传测试</h1>
    <form action="ad" method="post" enctype="multipart/form-data">
        <input type="hidden" name="action" value="purchase">
        <input type="hidden" name="adType" value="single">
        <input type="hidden" name="price" value="10">
        
        <div>
            <label>标题:</label>
            <input type="text" name="title" value="测试广告">
        </div>
        
        <div>
            <label>链接:</label>
            <input type="url" name="targetUrl" value="https://example.com">
        </div>
        
        <div>
            <label>图片:</label>
            <input type="file" name="imageFile" accept="image/*">
        </div>
        
        <button type="submit">测试上传</button>
    </form>
</body>
</html>