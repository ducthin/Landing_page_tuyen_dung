package com.recruitment.landingpage.service;

import com.recruitment.landingpage.entity.CandidateEntity;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.time.format.DateTimeFormatter;

@Service
public class EmailService {
    
    @Autowired
    private JavaMailSender mailSender;
      @Value("${app.admin.email}")
    private String adminEmail;
    
    @Value("${app.admin.name}")
    private String adminName;
    
    @Value("${spring.mail.username}")
    private String fromEmail;
    
    @Value("${app.base.url:https://tuyendungwellcenter.com}")
    private String baseUrl;
      public void sendNewCandidateNotification(CandidateEntity candidate) {
        // Kiểm tra cấu hình email trước khi gửi
        if (fromEmail == null || fromEmail.trim().isEmpty()) {
            System.err.println("Email configuration error: spring.mail.username is not configured");
            return;
        }
        
        if (adminEmail == null || adminEmail.trim().isEmpty()) {
            System.err.println("Email configuration error: app.admin.email is not configured");
            return;
        }
        
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail);
            helper.setTo(adminEmail);
            helper.setSubject("Ứng viên mới đã nộp hồ sơ - " + candidate.getFullName());
            
            String htmlContent = buildEmailContent(candidate);
            helper.setText(htmlContent, true);
            
            mailSender.send(message);
            System.out.println("Email notification sent successfully to: " + adminEmail);
            
        } catch (MessagingException e) {
            System.err.println("Error sending email notification: " + e.getMessage());
            e.printStackTrace();
        }
    }    private String buildEmailContent(CandidateEntity candidate) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy 'lúc' HH:mm");
        String formattedDate = candidate.getCreatedAt().format(formatter);
        
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    body { 
                        font-family: Arial, sans-serif; 
                        line-height: 1.6; 
                        color: #000; 
                        max-width: 600px; 
                        margin: 0 auto; 
                        padding: 20px; 
                        background-color: #fff;
                    }
                    h2 { 
                        color: #000; 
                        margin: 0 0 15px 0; 
                        font-size: 20px;
                        font-weight: bold;
                    }
                    .subtitle {
                        margin: 0 0 25px 0;
                        font-size: 14px;
                        color: #666;
                    }
                    .info-section {
                        margin: 25px 0;
                    }
                    .info-item {
                        margin: 10px 0;
                        font-size: 14px;
                    }
                    .label {
                        font-weight: bold;
                        display: inline-block;
                        width: 180px;
                        color: #000;
                    }
                    .value {
                        color: #333;
                    }
                    .action-section {
                        margin: 30px 0;
                        padding: 15px;
                        border: 1px solid #ddd;
                        background-color: #f9f9f9;
                    }
                    .action-title {
                        font-weight: bold;
                        margin: 0 0 8px 0;
                        color: #000;
                    }
                    .link {
                        color: #0066cc;
                        text-decoration: underline;
                    }
                    .footer {
                        margin-top: 30px;
                        padding-top: 15px;
                        border-top: 1px solid #ddd;
                        font-size: 12px;
                        color: #666;
                    }
                    hr {
                        border: none;
                        border-top: 1px solid #ddd;
                        margin: 25px 0;
                    }
                </style>
            </head>
            <body>
                <h2>Ứng viên mới đã nộp hồ sơ</h2>
                <p class="subtitle">Bạn có một ứng viên mới cần xem xét</p>
                
                <hr>
                
                <div class="info-section">
                    <div class="info-item">
                        <span class="label">Họ và tên:</span>
                        <span class="value">%s</span>
                    </div>
                    
                    <div class="info-item">
                        <span class="label">Số điện thoại:</span>
                        <span class="value">%s</span>
                    </div>
                    
                    <div class="info-item">
                        <span class="label">Địa chỉ:</span>
                        <span class="value">%s</span>
                    </div>
                    
                    <div class="info-item">
                        <span class="label">Thời gian có thể làm việc:</span>
                        <span class="value">%s</span>
                    </div>
                    
                    <div class="info-item">
                        <span class="label">Thời gian nộp hồ sơ:</span>
                        <span class="value">%s</span>
                    </div>
                    
                    <div class="info-item">
                        <span class="label">Tình trạng CV:</span>
                        <span class="value">%s</span>
                    </div>
                </div>
                  <div class="action-section">
                    <div class="action-title">Hành động tiếp theo:</div>
                    <p>Truy cập <a href="%s/admin/dashboard" class="link">hệ thống quản lý</a> để xem chi tiết và tải CV.</p>
                </div>
                
                <div class="footer">
                    <p>Email này được gửi tự động từ hệ thống tuyển dụng.</p>
                    <p>Vui lòng không trả lời email này.</p>
                </div>
            </body>
            </html>            """.formatted(
                candidate.getFullName(),
                candidate.getPhoneNumber(),
                candidate.getAddress(),
                candidate.getAvailableStartTime(),
                formattedDate,
                candidate.getCvOriginalFilename() != null ? 
                    "Đã tải lên CV: " + candidate.getCvOriginalFilename() : 
                    "Chưa có CV",
                baseUrl
            );
    }
}
