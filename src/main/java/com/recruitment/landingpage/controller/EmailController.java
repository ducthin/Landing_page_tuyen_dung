package com.recruitment.landingpage.controller;

import com.recruitment.landingpage.entity.EmailHistoryEntity;
import com.recruitment.landingpage.model.EmailReply;
import com.recruitment.landingpage.service.EmailService;
import com.recruitment.landingpage.entity.CandidateEntity;
import com.recruitment.landingpage.repository.CandidateRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/admin/email")
@PreAuthorize("hasRole('ADMIN')")
public class EmailController {
    
    @Autowired
    private EmailService emailService;
    
    @Autowired
    private CandidateRepository candidateRepository;
      /**
     * Show compose email page
     */
    @GetMapping("/compose")
    public String composeEmail(@RequestParam(required = false) Long candidateId, Model model) {
        EmailReply emailReply = new EmailReply();
        
        if (candidateId != null) {
            Optional<CandidateEntity> candidate = candidateRepository.findById(candidateId);
            if (candidate.isPresent()) {
                emailReply.setCandidateId(candidateId);
                // Tự động điền email của ứng viên nếu có
                if (candidate.get().getEmail() != null && !candidate.get().getEmail().trim().isEmpty()) {
                    emailReply.setTo(candidate.get().getEmail().trim());
                }
                model.addAttribute("candidate", candidate.get());
                model.addAttribute("candidateName", candidate.get().getFullName());
            }
        }
        
        model.addAttribute("emailReply", emailReply);
        return "admin/email-compose";
    }
    
    /**
     * Send email
     */
    @PostMapping("/send")
    public String sendEmail(@ModelAttribute EmailReply emailReply, 
                           RedirectAttributes redirectAttributes) {
        try {
            boolean success = emailService.sendEmailReply(emailReply);
            
            if (success) {
                redirectAttributes.addFlashAttribute("successMessage", 
                    "Email đã được gửi thành công đến " + emailReply.getTo());
            } else {
                redirectAttributes.addFlashAttribute("errorMessage", 
                    "Có lỗi xảy ra khi gửi email. Vui lòng thử lại.");
            }
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", 
                "Lỗi: " + e.getMessage());
        }
        
        return "redirect:/admin/email/history";
    }
    
    /**
     * Show email history
     */
    @GetMapping("/history")
    public String emailHistory(@RequestParam(defaultValue = "0") int page,
                              @RequestParam(defaultValue = "20") int size,
                              @RequestParam(required = false) String search,
                              Model model) {
        Pageable pageable = PageRequest.of(page, size);
        Page<EmailHistoryEntity> emails;
        
        if (search != null && !search.trim().isEmpty()) {
            emails = emailService.searchEmails(search.trim(), pageable);
            model.addAttribute("search", search);
        } else {
            emails = emailService.getEmailHistory(pageable);
        }
        
        model.addAttribute("emails", emails);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", emails.getTotalPages());
        model.addAttribute("totalItems", emails.getTotalElements());
        
        return "admin/email-history";
    }
    
    /**
     * Show email history for specific candidate
     */
    @GetMapping("/candidate/{candidateId}")
    public String candidateEmailHistory(@PathVariable Long candidateId, Model model) {
        Optional<CandidateEntity> candidate = candidateRepository.findById(candidateId);
        if (candidate.isPresent()) {
            List<EmailHistoryEntity> emails = emailService.getEmailHistoryForCandidate(candidateId);
            model.addAttribute("candidate", candidate.get());
            model.addAttribute("emails", emails);
            return "admin/candidate-email-history";
        }
        return "redirect:/admin/dashboard";
    }
    
    /**
     * Get email template via AJAX
     */
    @GetMapping("/template/{templateType}")
    @ResponseBody
    public String getEmailTemplate(@PathVariable String templateType, 
                                  @RequestParam(required = false) String candidateName) {
        if (candidateName == null || candidateName.trim().isEmpty()) {
            candidateName = "[Tên ứng viên]";
        }
        return emailService.getEmailTemplate(templateType, candidateName);
    }
    
    /**
     * Quick reply from candidate detail page
     */
    @PostMapping("/quick-reply")
    public String quickReply(@RequestParam Long candidateId,
                            @RequestParam String subject,
                            @RequestParam String content,
                            @RequestParam(defaultValue = "true") boolean html,
                            RedirectAttributes redirectAttributes) {
        try {
            Optional<CandidateEntity> candidate = candidateRepository.findById(candidateId);
            if (candidate.isPresent()) {
                // Extract email from phone/address or use a default pattern
                String candidateEmail = extractEmailFromCandidate(candidate.get());
                
                if (candidateEmail != null) {
                    EmailReply emailReply = new EmailReply();
                    emailReply.setTo(candidateEmail);
                    emailReply.setSubject(subject);
                    emailReply.setContent(content);
                    emailReply.setHtml(html);
                    emailReply.setCandidateId(candidateId);
                    
                    boolean success = emailService.sendEmailReply(emailReply);
                    
                    if (success) {
                        redirectAttributes.addFlashAttribute("successMessage", 
                            "Email đã được gửi thành công!");
                    } else {
                        redirectAttributes.addFlashAttribute("errorMessage", 
                            "Có lỗi xảy ra khi gửi email.");
                    }
                } else {
                    redirectAttributes.addFlashAttribute("errorMessage", 
                        "Không tìm thấy email của ứng viên.");
                }
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", 
                "Lỗi: " + e.getMessage());
        }
        
        return "redirect:/admin/candidate/" + candidateId;
    }
      /**
     * Extract email from candidate info
     */
    private String extractEmailFromCandidate(CandidateEntity candidate) {
        // Trả về email từ database nếu có
        if (candidate.getEmail() != null && !candidate.getEmail().trim().isEmpty()) {
            return candidate.getEmail().trim();
        }
        // Nếu không có email, trả về null
        return null;
    }
    
    /**
     * Test editor page (for debugging)
     */
    @GetMapping("/test-editor")
    public String testEditor() {
        return "admin/test-editor";
    }
}
