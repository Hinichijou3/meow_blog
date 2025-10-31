package com.yourblog.controller;

import com.yourblog.dao.UserDAO;
import com.yourblog.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;

@WebServlet("/upload-avatar")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1MB
    maxFileSize = 1024 * 1024 * 5,   // 5MB
    maxRequestSize = 1024 * 1024 * 10 // 10MB
)
public class UploadAvatarServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        Part filePart = request.getPart("avatarFile");
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = "avatar_" + currentUser.getId() + "_" + System.currentTimeMillis() + ".jpg";
            String uploadPath = getServletContext().getRealPath("") + "images/avatars";
            
            // 确保目录存在
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            // 保存文件
            String filePath = uploadPath + File.separator + fileName;
            try (InputStream fileContent = filePart.getInputStream();
                 OutputStream out = new FileOutputStream(filePath)) {
                
                byte[] buffer = new byte[1024];
                int bytesRead;
                while ((bytesRead = fileContent.read(buffer)) != -1) {
                    out.write(buffer, 0, bytesRead);
                }
            }
            
            // 更新数据库中的头像路径
            String avatarUrl = "images/avatars/" + fileName;
            UserDAO userDao = new UserDAO();
            if (userDao.updateUserAvatar(currentUser.getId(), avatarUrl)) {
                currentUser.setAvatarUrl(avatarUrl);
                session.setAttribute("user", currentUser);
                request.setAttribute("success", "头像上传成功！");
            } else {
                request.setAttribute("error", "头像更新失败，请重试");
            }
        } else {
            request.setAttribute("error", "请选择要上传的头像文件");
        }
        
        request.getRequestDispatcher("my-profile.jsp").forward(request, response);
    }
}