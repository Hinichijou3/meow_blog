package com.yourblog.controller;

import com.yourblog.dao.AdDAO;
import com.yourblog.model.Ad;
import com.yourblog.model.User;
import com.yourblog.util.FileUploadUtil;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class AdDeleteServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String adIdParam = request.getParameter("adId");
        
        if (adIdParam == null) {
            request.setAttribute("error", "广告ID不能为空");
            request.getRequestDispatcher("store.jsp").forward(request, response);
            return;
        }
        
        try {
            int adId = Integer.parseInt(adIdParam);
            AdDAO adDao = new AdDAO();
            
            // 首先获取广告信息，确保用户只能删除自己的广告
            Ad ad = adDao.getAdById(adId);
            
            if (ad == null) {
                request.setAttribute("error", "广告不存在");
                request.getRequestDispatcher("store.jsp").forward(request, response);
                return;
            }
            
            // 检查广告是否属于当前用户
            if (ad.getUserId() != user.getId()) {
                request.setAttribute("error", "无权删除此广告");
                request.getRequestDispatcher("store.jsp").forward(request, response);
                return;
            }
            
            // 删除广告图片文件
            String realPath = getServletContext().getRealPath("/");
            FileUploadUtil.deleteAdImage(ad.getImageUrl(), realPath);
            
            // 删除广告记录
            boolean success = adDao.deleteAdByUser(adId, user.getId());
            
            if (success) {
                request.setAttribute("success", "广告删除成功");
            } else {
                request.setAttribute("error", "广告删除失败");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "广告ID格式错误");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "删除广告时发生错误");
        }
        
        request.getRequestDispatcher("store.jsp").forward(request, response);
    }
}