package com.yourblog.controller;

import com.yourblog.dao.UserDAO;
import com.yourblog.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;

@WebServlet("/upload-header")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1MB
    maxFileSize = 1024 * 1024 * 10,  // 10MB
    maxRequestSize = 1024 * 1024 * 20 // 20MB
)
public class UploadHeaderServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        Part filePart = request.getPart("headerFile");
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = "header_" + currentUser.getId() + "_" + System.currentTimeMillis() + ".jpg";
            String uploadPath = getServletContext().getRealPath("") + "images/headers";
            
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
            
            // 更新数据库中的头图路径
            String headerUrl = "images/headers/" + fileName;
            UserDAO userDao = new UserDAO();
            if (userDao.updateUserHeaderImage(currentUser.getId(), headerUrl)) {
                currentUser.setHeaderImageUrl(headerUrl);
                session.setAttribute("user", currentUser);
                request.setAttribute("success", "头图上传成功！");
            } else {
                request.setAttribute("error", "头图更新失败，请重试");
            }
        } else {
            request.setAttribute("error", "请选择要上传的头图文件");
        }
        
        request.getRequestDispatcher("my-profile.jsp").forward(request, response);
    }
}