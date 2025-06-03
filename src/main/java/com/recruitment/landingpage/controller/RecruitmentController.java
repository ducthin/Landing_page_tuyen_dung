package com.recruitment.landingpage.controller;

import com.recruitment.landingpage.model.Candidate;
import com.recruitment.landingpage.entity.CandidateEntity;
import com.recruitment.landingpage.repository.CandidateRepository;
import com.recruitment.landingpage.service.EmailService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Controller
public class RecruitmentController {
    
    @Autowired
    private CandidateRepository candidateRepository;
    
    @Autowired
    private EmailService emailService;
    
    @Value("${app.upload.dir:uploads/}")
    private String uploadDir;
    
    @Value("${app.storage.type:DATABASE}")
    private String storageType;
    
    @GetMapping("/")
    public String index(Model model) {
        model.addAttribute("candidate", new Candidate());
        return "index";
    }
    
    @PostMapping("/submit")
    public String submitApplication(@Valid Candidate candidate, 
                                   BindingResult bindingResult,
                                   @RequestParam("cvFile") MultipartFile file,
                                   RedirectAttributes redirectAttributes,
                                   Model model) {
        
        // Validate file upload
        if (file.isEmpty()) {
            bindingResult.rejectValue("cvFile", "file.empty", "Vui lòng chọn file CV");
        } else {
            // Check file type
            String contentType = file.getContentType();
            if (contentType == null || 
                (!contentType.equals("application/pdf") && 
                 !contentType.equals("application/msword") && 
                 !contentType.equals("application/vnd.openxmlformats-officedocument.wordprocessingml.document"))) {
                bindingResult.rejectValue("cvFile", "file.type", "Chỉ chấp nhận file PDF, DOC, DOCX");
            }
            
            // Check file size (5MB max)
            if (file.getSize() > 5 * 1024 * 1024) {
                bindingResult.rejectValue("cvFile", "file.size", "File không được vượt quá 5MB");
            }
        }
        
        if (bindingResult.hasErrors()) {
            return "index";
        }
        
        try {
            CandidateEntity candidateEntity;
            
            if ("DATABASE".equals(storageType)) {
                candidateEntity = new CandidateEntity(
                    candidate.getFullName(),
                    candidate.getPhoneNumber(), 
                    candidate.getAddress(),
                    candidate.getAvailableStartTime(),
                    file.getBytes(),  
                    file.getContentType(),
                    file.getOriginalFilename()
                );
                System.out.println("CV saved to DATABASE");
                
            } else {
                Path uploadPath = Paths.get(uploadDir);
                if (!Files.exists(uploadPath)) {
                    Files.createDirectories(uploadPath);
                }
                
                String originalFilename = file.getOriginalFilename();
                if (originalFilename == null || originalFilename.isEmpty()) {
                    originalFilename = "cv.pdf";
                }
                String fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
                String uniqueFilename = UUID.randomUUID().toString() + fileExtension;
                Path filePath = uploadPath.resolve(uniqueFilename);
                Files.copy(file.getInputStream(), filePath);
                
                candidateEntity = new CandidateEntity(
                    candidate.getFullName(),
                    candidate.getPhoneNumber(), 
                    candidate.getAddress(),
                    candidate.getAvailableStartTime(),
                    uniqueFilename,
                    originalFilename
                );
                System.out.println("CV saved to FILE: " + uploadPath.resolve(uniqueFilename));
            }
            candidate.setCvFile(file);
            candidateRepository.save(candidateEntity);
            
            System.out.println("New application saved to database: " + candidateEntity.getId());
            
            try {
                emailService.sendNewCandidateNotification(candidateEntity);
            } catch (Exception e) {
                System.err.println("Failed to send email notification: " + e.getMessage());
            }
            
            redirectAttributes.addFlashAttribute("successMessage", 
                "Cảm ơn bạn đã ứng tuyển! Chúng tôi sẽ liên hệ với bạn sớm nhất.");
            
        } catch (IOException e) {
            e.printStackTrace();
            model.addAttribute("errorMessage", "Có lỗi xảy ra khi tải file. Vui lòng thử lại.");
            return "index";
        }
        
        return "redirect:/success";
    }
    
    @GetMapping("/success")
    public String success() {
        return "success";
    }
}
