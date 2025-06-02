package com.recruitment.landingpage.controller;

import com.recruitment.landingpage.entity.CandidateEntity;
import com.recruitment.landingpage.repository.CandidateRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.LocalDate;
import java.util.List;

@Controller
@RequestMapping("/admin")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {
    
    @Autowired
    private CandidateRepository candidateRepository;
    
    private static final String UPLOAD_DIR = "uploads/";
      @GetMapping("/dashboard")
    public String dashboard(Model model) {
        List<CandidateEntity> candidates = candidateRepository.findAllByOrderByCreatedAtDesc();
        
        // Thống kê
        long totalCandidates = candidateRepository.count();
        long totalCvs = candidateRepository.countByCvFilenameIsNotNull();
        
        // Ứng tuyển hôm nay
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = LocalDate.now().atTime(23, 59, 59);
        long todayApplications = candidateRepository.countByCreatedAtBetween(startOfDay, endOfDay);
        
        // Ứng tuyển tuần này
        LocalDateTime startOfWeek = LocalDate.now().minusDays(6).atStartOfDay();
        long thisWeekApplications = candidateRepository.countByCreatedAtBetween(startOfWeek, LocalDateTime.now());
        
        model.addAttribute("candidates", candidates);
        model.addAttribute("totalCandidates", totalCandidates);
        model.addAttribute("totalCvs", totalCvs);
        model.addAttribute("todayApplications", todayApplications);
        model.addAttribute("thisWeekApplications", thisWeekApplications);
        
        return "admin/dashboard";
    }
    
    @GetMapping("/candidate/{id}")
    public String viewCandidate(@PathVariable Long id, Model model) {
        CandidateEntity candidate = candidateRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Candidate not found"));
        model.addAttribute("candidate", candidate);
        return "admin/candidate-detail";
    }
    
    @GetMapping("/download-cv/{id}")
    public ResponseEntity<Resource> downloadCV(@PathVariable Long id) {
        CandidateEntity candidate = candidateRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Candidate not found"));
        
        try {
            Path filePath = Paths.get(UPLOAD_DIR).resolve(candidate.getCvFilename());
            File file = filePath.toFile();
            
            if (!file.exists()) {
                return ResponseEntity.notFound().build();
            }
            
            Resource resource = new FileSystemResource(file);
            
            return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .header(HttpHeaders.CONTENT_DISPOSITION, 
                           "attachment; filename=\"" + candidate.getCvOriginalFilename() + "\"")
                    .body(resource);
                    
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    @GetMapping("/delete-candidate/{id}")
    public String deleteCandidate(@PathVariable Long id) {
        try {
            CandidateEntity candidate = candidateRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Candidate not found"));
            
            // Xóa file CV nếu có
            if (candidate.getCvFilename() != null) {
                try {
                    Path filePath = Paths.get(UPLOAD_DIR).resolve(candidate.getCvFilename());
                    Files.deleteIfExists(filePath);
                } catch (Exception e) {
                    System.err.println("Error deleting CV file: " + e.getMessage());
                }
            }
            
            // Xóa candidate khỏi database
            candidateRepository.delete(candidate);
            
            System.out.println("Deleted candidate: " + candidate.getFullName() + " (ID: " + id + ")");
            
        } catch (Exception e) {
            System.err.println("Error deleting candidate: " + e.getMessage());
        }
        
        return "redirect:/admin/dashboard";
    }
}
