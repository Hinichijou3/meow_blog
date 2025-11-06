package com.yourblog.controller;

import com.yourblog.dao.AdDAO;
import com.yourblog.dao.CoinDAO;
import com.yourblog.model.Ad;
import com.yourblog.model.User;
import com.yourblog.util.FileUploadUtil;
import com.yourblog.util.UserSessionUtil;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.MultipartConfig;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.Date;

@MultipartConfig(
    maxFileSize = 5 * 1024 * 1024,      // 5MB
    maxRequestSize = 10 * 1024 * 1024   // 10MB
)
public class AdServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("purchase".equals(action)) {
            purchaseAd(request, response, user, session);
        }
    }
    
    private void purchaseAd(HttpServletRequest request, HttpServletResponse response, User user, HttpSession session) 
            throws ServletException, IOException {
        
        String title = request.getParameter("title");
        String targetUrl = request.getParameter("targetUrl");
        String adType = request.getParameter("adType");
        String priceStr = request.getParameter("price");
        Part imagePart = request.getPart("imageFile");
        
        // 参数验证
        if (title == null || title.trim().isEmpty() ||
            targetUrl == null || targetUrl.trim().isEmpty() ||
            adType == null || priceStr == null || imagePart == null) {
            request.setAttribute("error", "请填写所有必填字段");
            request.getRequestDispatcher("store.jsp").forward(request, response);
            return;
        }
        
        int price;
        try {
            price = Integer.parseInt(priceStr);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "价格格式错误");
            request.getRequestDispatcher("store.jsp").forward(request, response);
            return;
        }
        
        // 验证图片文件
        String fileName = getFileName(imagePart);
        if (fileName == null || fileName.isEmpty()) {
            request.setAttribute("error", "请选择广告图片");
            request.getRequestDispatcher("store.jsp").forward(request, response);
            return;
        }
        
        if (!FileUploadUtil.isValidImageFile(fileName)) {
            request.setAttribute("error", "只支持 JPG, PNG, GIF 格式的图片");
            request.getRequestDispatcher("store.jsp").forward(request, response);
            return;
        }
        
        if (!FileUploadUtil.isValidImageSize(imagePart.getSize())) {
            request.setAttribute("error", "图片大小不能超过 5MB");
            request.getRequestDispatcher("store.jsp").forward(request, response);
            return;
        }
        
        // 检查用户硬币是否足够
        if (user.getCoins() < price) {
            request.setAttribute("error", "硬币不足，无法购买广告位");
            request.getRequestDispatcher("store.jsp").forward(request, response);
            return;
        }
        
        // 保存上传的图片
        String imageUrl;
        try {
            String realPath = getServletContext().getRealPath("/");
            imageUrl = FileUploadUtil.saveAdImage(imagePart, realPath);
        } catch (IOException e) {
            e.printStackTrace();
            request.setAttribute("error", "图片上传失败，请重试");
            request.getRequestDispatcher("store.jsp").forward(request, response);
            return;
        }
        
        // 创建广告
        Ad ad = new Ad();
        ad.setUserId(user.getId());
        ad.setTitle(title);
        ad.setImageUrl(imageUrl); // 使用上传后的图片路径
        ad.setTargetUrl(targetUrl);
        ad.setAdType(adType);
        ad.setPrice(price);
        ad.setStatus("active");
        ad.setStartDate(new Timestamp(new Date().getTime()));
        // 设置结束时间为30天后
        long thirtyDays = 30L * 24 * 60 * 60 * 1000;
        ad.setEndDate(new Timestamp(new Date().getTime() + thirtyDays));
        
        AdDAO adDao = new AdDAO();
        CoinDAO coinDao = new CoinDAO();
        
        // 扣除硬币并创建广告
        boolean success = false;
        try {
            // 先扣除硬币
            if (coinDao.updateUserCoins(user.getId(), user.getCoins() - price)) {
                // 再创建广告
                if (adDao.createAd(ad)) {
                    success = true;
                    
                    // 立即刷新session中的用户信息
                    UserSessionUtil.refreshUserInSession(session);
                } else {
                    // 如果创建广告失败，需要回退硬币
                    coinDao.updateUserCoins(user.getId(), user.getCoins());
                    // 删除已上传的图片
                    String realPath = getServletContext().getRealPath("/");
                    FileUploadUtil.deleteAdImage(imageUrl, realPath);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            // 发生异常时删除已上传的图片
            String realPath = getServletContext().getRealPath("/");
            FileUploadUtil.deleteAdImage(imageUrl, realPath);
        }
        
        if (success) {
            request.setAttribute("success", "广告购买成功！");
        } else {
            request.setAttribute("error", "广告购买失败，请重试");
        }
        
        request.getRequestDispatcher("store.jsp").forward(request, response);
    }
    
    /**
     * 获取上传文件的文件名
     */
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        String[] tokens = contentDisposition.split(";");
        
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return null;
    }
}