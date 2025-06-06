package com.recruitment.landingpage.controller;

import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Controller
public class CustomErrorController implements ErrorController {

    @RequestMapping("/error")
    public String handleError(HttpServletRequest request, Model model) {
        Object status = request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);
        Object errorMessage = request.getAttribute(RequestDispatcher.ERROR_MESSAGE);
        Object requestUri = request.getAttribute(RequestDispatcher.ERROR_REQUEST_URI);
        Object exception = request.getAttribute(RequestDispatcher.ERROR_EXCEPTION);

        // Add common attributes
        model.addAttribute("timestamp", LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss")));
        model.addAttribute("path", requestUri);

        if (status != null) {
            Integer statusCode = Integer.valueOf(status.toString());
            model.addAttribute("status", statusCode);

            // Add error message
            if (errorMessage != null) {
                model.addAttribute("message", errorMessage.toString());
            }

            // Add exception details for development
            if (exception != null) {
                model.addAttribute("error", exception.getClass().getSimpleName());
                // Only show stack trace in development mode
                // model.addAttribute("trace", getStackTrace((Exception) exception));
            }

            // Route to specific error pages
            if (statusCode == HttpStatus.NOT_FOUND.value()) {
                model.addAttribute("errorTitle", "Trang Không Tìm Thấy");
                model.addAttribute("errorDescription", "Trang bạn đang tìm kiếm không tồn tại hoặc đã bị di chuyển.");
                return "error/404";
            } else if (statusCode == HttpStatus.INTERNAL_SERVER_ERROR.value()) {
                model.addAttribute("errorTitle", "Lỗi Máy Chủ Nội Bộ");
                model.addAttribute("errorDescription", "Đã xảy ra lỗi kỹ thuật. Chúng tôi đang khắc phục sự cố.");
                return "error/500";
            } else if (statusCode == HttpStatus.FORBIDDEN.value()) {
                model.addAttribute("errorTitle", "Truy Cập Bị Từ Chối");
                model.addAttribute("errorDescription", "Bạn không có quyền truy cập vào trang này.");
                return "error";
            } else if (statusCode == HttpStatus.BAD_REQUEST.value()) {
                model.addAttribute("errorTitle", "Yêu Cầu Không Hợp Lệ");
                model.addAttribute("errorDescription", "Yêu cầu của bạn không hợp lệ hoặc thiếu thông tin.");
                return "error";
            }
        }

        // Default error page
        model.addAttribute("errorTitle", "Có Lỗi Xảy Ra");
        model.addAttribute("errorDescription", "Hệ thống gặp sự cố không mong muốn. Chúng tôi sẽ khắc phục trong thời gian sớm nhất.");
        return "error";
    }

    // Helper method to get stack trace (for development)
    private String getStackTrace(Exception ex) {
        java.io.StringWriter sw = new java.io.StringWriter();
        java.io.PrintWriter pw = new java.io.PrintWriter(sw);
        ex.printStackTrace(pw);
        return sw.toString();
    }
}
