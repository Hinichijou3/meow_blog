package com.yourblog.controller;

import com.yourblog.dao.PostDAO;
import com.yourblog.model.Post;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/search")
public class SearchController extends HttpServlet {
    private PostDAO postDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        postDAO = new PostDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        String keyword = request.getParameter("keyword");
        String tag = request.getParameter("tag");
        
        System.out.println("=== 搜索请求 ===");
        System.out.println("action: " + action);
        System.out.println("keyword: " + keyword);
        System.out.println("tag: " + tag);
        
        try {
            if ("tag".equals(action) && tag != null && !tag.trim().isEmpty()) {
                // 按标签搜索
                searchByTag(tag, request, response);
            } else if (keyword != null && !keyword.trim().isEmpty()) {
                // 关键词搜索
                searchByKeyword(keyword, request, response);
            } else {
                // 显示搜索页面
                showSearchPage(request, response);
            }
        } catch (Exception e) {
            System.err.println("❌ 搜索处理失败: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "搜索失败，请稍后重试");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    /**
     * 关键词搜索
     */
    private void searchByKeyword(String keyword, HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("执行关键词搜索: " + keyword);
        
        List<Post> searchResults = postDAO.searchPosts(keyword);
        
        // 为每篇文章设置标签
        for (Post post : searchResults) {
            List<String> tags = postDAO.getTagsByPostId(post.getId());
            post.setTags(tags);
        }
        
        // 获取热门标签
        List<String> popularTags = postDAO.getPopularTags(10);
        
        request.setAttribute("posts", searchResults);
        request.setAttribute("searchKeyword", keyword);
        request.setAttribute("popularTags", popularTags);
        request.setAttribute("resultCount", searchResults.size());
        
        System.out.println("搜索完成，找到 " + searchResults.size() + " 条结果");
        
        request.getRequestDispatcher("/search-results.jsp").forward(request, response);
    }
    
    /**
     * 标签搜索
     */
    private void searchByTag(String tagName, HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("执行标签搜索: " + tagName);
        
        List<Post> tagResults = postDAO.searchPostsByTag(tagName);
        
        // 为每篇文章设置标签
        for (Post post : tagResults) {
            List<String> tags = postDAO.getTagsByPostId(post.getId());
            post.setTags(tags);
        }
        
        // 获取热门标签
        List<String> popularTags = postDAO.getPopularTags(10);
        
        request.setAttribute("posts", tagResults);
        request.setAttribute("tagName", tagName);
        request.setAttribute("popularTags", popularTags);
        request.setAttribute("resultCount", tagResults.size());
        
        System.out.println("标签搜索完成，找到 " + tagResults.size() + " 条结果");
        
        request.getRequestDispatcher("/tag-results.jsp").forward(request, response);
    }
    
    /**
     * 显示搜索页面
     */
    private void showSearchPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 获取热门标签
        List<String> popularTags = postDAO.getPopularTags(10);
        request.setAttribute("popularTags", popularTags);
        
        request.getRequestDispatcher("/search-page.jsp").forward(request, response);
    }
}