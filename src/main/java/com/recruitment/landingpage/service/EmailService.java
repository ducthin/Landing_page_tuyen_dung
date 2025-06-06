package com.recruitment.landingpage.service;

import com.recruitment.landingpage.entity.CandidateEntity;
import com.recruitment.landingpage.entity.EmailHistoryEntity;
import com.recruitment.landingpage.model.EmailReply;
import com.recruitment.landingpage.repository.EmailHistoryRepository;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.time.format.DateTimeFormatter;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class EmailService {
    
    @Autowired
    private JavaMailSender mailSender;
    
    @Autowired
    private EmailHistoryRepository emailHistoryRepository;
    
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
    }
    
    private String buildEmailContent(CandidateEntity candidate) {
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
    
    /**
     * Send email reply from admin
     */
    public boolean sendEmailReply(EmailReply emailReply) {
        String currentUser = getCurrentUsername();
        EmailHistoryEntity history = new EmailHistoryEntity();
        
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail);
            helper.setTo(emailReply.getTo());
            
            if (emailReply.getCc() != null && !emailReply.getCc().trim().isEmpty()) {
                helper.setCc(emailReply.getCc());
            }
            
            if (emailReply.getBcc() != null && !emailReply.getBcc().trim().isEmpty()) {
                helper.setBcc(emailReply.getBcc());
            }            helper.setSubject(emailReply.getSubject());
            
            if (emailReply.isHtml()) {
                helper.setText(emailReply.getContent(), true);
            } else {
                helper.setText(emailReply.getContent());
            }
            
            // Send email
            mailSender.send(message);
            
            // Save to history
            history.setToEmail(emailReply.getTo());
            history.setCcEmail(emailReply.getCc());            
            history.setBccEmail(emailReply.getBcc());
            history.setSubject(emailReply.getSubject());
            history.setContent(emailReply.getContent());
            history.setHtml(emailReply.isHtml());
            history.setCandidateId(emailReply.getCandidateId());
            history.setSentBy(currentUser);
            history.setSuccess(true);
            
            emailHistoryRepository.save(history);
            
            System.out.println("Email sent successfully to: " + emailReply.getTo());
            return true;
            
        } catch (Exception e) {
            System.err.println("Failed to send email to: " + emailReply.getTo());
            e.printStackTrace();
            
            // Save failed attempt to history
            history.setToEmail(emailReply.getTo());
            history.setCcEmail(emailReply.getCc());
            history.setBccEmail(emailReply.getBcc());            history.setSubject(emailReply.getSubject());
            history.setContent(emailReply.getContent());
            history.setHtml(emailReply.isHtml());
            history.setCandidateId(emailReply.getCandidateId());
            history.setSentBy(currentUser);
            history.setSuccess(false);
            history.setErrorMessage(e.getMessage());
            
            emailHistoryRepository.save(history);
            return false;
        }
    }
    
    /**
     * Get email history with pagination
     */
    public Page<EmailHistoryEntity> getEmailHistory(Pageable pageable) {
        return emailHistoryRepository.findAllByOrderBySentAtDesc(pageable);
    }
    
    /**
     * Get email history by admin username
     */
    public Page<EmailHistoryEntity> getEmailHistoryByUser(String username, Pageable pageable) {
        return emailHistoryRepository.findBySentByOrderBySentAtDesc(username, pageable);
    }
    
    /**
     * Get email history for specific candidate
     */
    public List<EmailHistoryEntity> getEmailHistoryForCandidate(Long candidateId) {
        return emailHistoryRepository.findByCandidateIdOrderBySentAtDesc(candidateId);
    }
    
    /**
     * Search emails
     */
    public Page<EmailHistoryEntity> searchEmails(String keyword, Pageable pageable) {
        return emailHistoryRepository.searchEmails(keyword, pageable);
    }
    
    /**
     * Get current logged in username
     */
    private String getCurrentUsername() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication != null ? authentication.getName() : "admin";
    }
    
    /**
     * Get email templates
     */
    public String getEmailTemplate(String templateType, String candidateName) {
        switch (templateType.toLowerCase()) {
            case "interview_invitation":
                return buildInterviewInvitationTemplate(candidateName);
            case "application_received":
                return buildApplicationReceivedTemplate(candidateName);
            case "rejection":
                return buildRejectionTemplate(candidateName);
            case "job_offer":
                return buildJobOfferTemplate(candidateName);
            default:
                return "";
        }
    }
    
    private String buildInterviewInvitationTemplate(String candidateName) {
        return """
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f9f9f9;">
                <div style="background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                    <h2 style="color: #2c5aa0; margin-bottom: 20px;">Thư mời phỏng vấn</h2>
                    
                    <p>Kính chào %s,</p>
                    
                    <p>Chúng tôi đã xem xét hồ sơ của bạn và rất ấn tượng với kinh nghiệm cũng như kỹ năng mà bạn sở hữu.</p>
                    
                    <p>Chúng tôi xin mời bạn tham gia buổi phỏng vấn tại WELL CENTER với thông tin sau:</p>
                    
                    <div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 15px 0;">
                        <strong>Thời gian:</strong> [Vui lòng điền thời gian cụ thể]<br>
                        <strong>Địa điểm:</strong> 154 Đ. Phạm Văn Chiêu, Phường 8, Gò Vấp, TP.HCM<br>
                        <strong>Liên hệ:</strong> [Số điện thoại liên hệ]
                    </div>
                    
                    <p>Vui lòng xác nhận sự tham gia của bạn bằng cách trả lời email này hoặc gọi điện trực tiếp.</p>
                    
                    <p>Chúng tôi rất mong được gặp bạn!</p>
                    
                    <p style="margin-top: 30px;">
                        Trân trọng,<br>
                        <strong>Phòng Nhân sự WELL CENTER</strong>
                    </p>
                </div>
            </div>
            """.formatted(candidateName);
    }
    
    private String buildApplicationReceivedTemplate(String candidateName) {
        return """
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f9f9f9;">
                <div style="background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                    <h2 style="color: #2c5aa0; margin-bottom: 20px;">Xác nhận nhận hồ sơ</h2>
                    
                    <p>Kính chào %s,</p>
                    
                    <p>Cảm ơn bạn đã quan tâm và gửi hồ sơ ứng tuyển đến WELL CENTER.</p>
                    
                    <p>Chúng tôi đã nhận được hồ sơ của bạn và sẽ xem xét kỹ lưỡng. Nếu hồ sơ của bạn phù hợp với vị trí tuyển dụng, chúng tôi sẽ liên hệ với bạn trong thời gian sớm nhất.</p>
                    
                    <p>Mọi thắc mắc, vui lòng liên hệ với chúng tôi qua email này hoặc số điện thoại trên website.</p>
                    
                    <p style="margin-top: 30px;">
                        Trân trọng,<br>
                        <strong>Phòng Nhân sự WELL CENTER</strong>
                    </p>
                </div>
            </div>
            """.formatted(candidateName);
    }
    
    private String buildRejectionTemplate(String candidateName) {
        return """
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f9f9f9;">
                <div style="background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                    <h2 style="color: #2c5aa0; margin-bottom: 20px;">Thông báo kết quả tuyển dụng</h2>
                    
                    <p>Kính chào %s,</p>
                    
                    <p>Cảm ơn bạn đã dành thời gian tham gia quy trình tuyển dụng tại WELL CENTER.</p>
                    
                    <p>Sau khi xem xét kỹ lưỡng, chúng tôi rất tiếc phải thông báo rằng hồ sơ của bạn chưa phù hợp với vị trí tuyển dụng lần này.</p>
                    
                    <p>Tuy nhiên, chúng tôi rất ấn tượng với profile của bạn và mong muốn có thể hợp tác trong tương lai khi có cơ hội phù hợp hơn.</p>
                    
                    <p>Chúc bạn thành công trong công việc và sự nghiệp!</p>
                    
                    <p style="margin-top: 30px;">
                        Trân trọng,<br>
                        <strong>Phòng Nhân sự WELL CENTER</strong>
                    </p>
                </div>
            </div>
            """.formatted(candidateName);
    }
    
    private String buildJobOfferTemplate(String candidateName) {
        return """
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f9f9f9;">
                <div style="background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                    <h2 style="color: #2c5aa0; margin-bottom: 20px;">🎉 Thư mời làm việc</h2>
                    
                    <p>Kính chào %s,</p>
                    
                    <p>Chúc mừng! Chúng tôi rất vui mừng thông báo rằng bạn đã được chọn để gia nhập đội ngũ WELL CENTER.</p>
                    
                    <p>Sau quá trình phỏng vấn và đánh giá, chúng tôi tin rằng bạn sẽ là một thành viên quý giá của team.</p>
                    
                    <div style="background-color: #e8f5e8; padding: 15px; border-radius: 5px; margin: 15px 0;">
                        <strong>Thông tin công việc:</strong><br>
                        <strong>Vị trí:</strong> [Tên vị trí]<br>
                        <strong>Ngày bắt đầu:</strong> [Ngày bắt đầu]<br>
                        <strong>Mức lương:</strong> [Thỏa thuận]<br>
                        <strong>Địa điểm làm việc:</strong> 154 Đ. Phạm Văn Chiêu, Phường 8, Gò Vấp, TP.HCM
                    </div>
                    
                    <p>Vui lòng xác nhận việc nhận offer này và thời gian có thể bắt đầu làm việc.</p>
                    
                    <p>Chúng tôi rất mong được chào đón bạn vào đại gia đình WELL CENTER!</p>
                    
                    <p style="margin-top: 30px;">
                        Trân trọng,<br>
                        <strong>Phòng Nhân sự WELL CENTER</strong>
                    </p>
                </div>
            </div>
            """.formatted(candidateName);
    }
}
