package com.recruitment.landingpage.controller;

import com.recruitment.landingpage.service.EmailService;
import com.recruitment.landingpage.entity.CandidateEntity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;

@RestController
public class EmailTestController {
    
    @Autowired
    private EmailService emailService;
    
    @Value("${spring.mail.username}")
    private String fromEmail;
    
    @Value("${app.admin.email}")
    private String adminEmail;
    
    @GetMapping("/test-email")
    public String testEmail() {
        // Kiểm tra cấu hình
        if (fromEmail == null || fromEmail.trim().isEmpty()) {
            return "❌ Error: spring.mail.username is not configured";
        }
        
        if (adminEmail == null || adminEmail.trim().isEmpty()) {
            return "❌ Error: app.admin.email is not configured";
        }
        
        try {
            // Tạo ứng viên test
            CandidateEntity testCandidate = new CandidateEntity();
            testCandidate.setId(999L);
            testCandidate.setFullName("Nguyễn Văn Test");
            testCandidate.setPhoneNumber("0123456789");
            testCandidate.setAddress("Hà Nội");
            testCandidate.setAvailableStartTime("Ngay lập tức");
            testCandidate.setCreatedAt(LocalDateTime.now());
            testCandidate.setCvOriginalFilename("test-cv.pdf");
            
            emailService.sendNewCandidateNotification(testCandidate);
            
            return "✅ Test email sent successfully!<br>" +
                   "From: " + fromEmail + "<br>" +
                   "To: " + adminEmail + "<br>" +
                   "Subject: 🎯 Ứng viên mới đã nộp hồ sơ - Nguyễn Văn Test<br><br>" +
                   "Check your email inbox and spam folder.";
                   
        } catch (Exception e) {
            return "❌ Error sending test email: " + e.getMessage();
        }
    }
    
    @GetMapping("/email-config")
    public String checkEmailConfig() {
        return """
            <h3>📧 Email Configuration Status</h3>
            <p><strong>From Email:</strong> %s</p>
            <p><strong>Admin Email:</strong> %s</p>
            <p><strong>Status:</strong> %s</p>
            <hr>
            <p><a href="/test-email">🧪 Send Test Email</a></p>
            <p><a href="/">🏠 Back to Home</a></p>
            """.formatted(
                fromEmail != null && !fromEmail.trim().isEmpty() ? fromEmail : "❌ Not configured",
                adminEmail != null && !adminEmail.trim().isEmpty() ? adminEmail : "❌ Not configured",
                (fromEmail != null && !fromEmail.trim().isEmpty() && 
                 adminEmail != null && !adminEmail.trim().isEmpty()) ? "✅ Ready" : "❌ Need configuration"
            );
    }
}
