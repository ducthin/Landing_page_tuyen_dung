package com.recruitment.landingpage.controller;

import com.recruitment.landingpage.entity.CandidateEntity;
import com.recruitment.landingpage.repository.CandidateRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
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
import java.time.LocalDate;
import java.util.List;

@Controller
@RequestMapping("/admin")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {
    
    @Autowired
    private CandidateRepository candidateRepository;
    
    @Value("${app.upload.dir:uploads/}")
    private String uploadDir;
    
    @Value("${app.storage.type:DATABASE}")
    private String storageType;
      
    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        List<CandidateEntity> candidates = candidateRepository.findAll();
        model.addAttribute("candidates", candidates);
        
        // Thống kê
        model.addAttribute("totalCandidates", candidates.size());
        model.addAttribute("totalCvs", candidates.size());
        
        // Ứng viên hôm nay
        LocalDate today = LocalDate.now();
        long todayApplications = candidates.stream()
            .filter(c -> c.getCreatedAt().toLocalDate().equals(today))
            .count();
        model.addAttribute("todayApplications", todayApplications);
        
        // Ứng viên tuần này
        LocalDate weekStart = today.minusDays(today.getDayOfWeek().getValue() - 1);
        long thisWeekApplications = candidates.stream()
            .filter(c -> c.getCreatedAt().toLocalDate().isAfter(weekStart.minusDays(1)) &&
                        c.getCreatedAt().toLocalDate().isBefore(today.plusDays(1)))
            .count();
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
            if ("DATABASE".equals(storageType) && candidate.getCvData() != null) {
                // Download từ database
                ByteArrayResource resource = new ByteArrayResource(candidate.getCvData());
                
                String contentType = candidate.getCvContentType();
                if (contentType == null) {
                    contentType = "application/octet-stream";
                }
                
                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(contentType))
                        .header(HttpHeaders.CONTENT_DISPOSITION, 
                               "attachment; filename=\"" + candidate.getCvOriginalFilename() + "\"")
                        .body(resource);
                        
            } else if (candidate.getCvFilename() != null) {
                // Download từ file system
                Path filePath = Paths.get(uploadDir).resolve(candidate.getCvFilename());
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
            } else {
                return ResponseEntity.notFound().build();
            }
                    
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }
    
    @GetMapping("/view-cv/{id}")
    public ResponseEntity<Resource> viewCV(@PathVariable Long id) {
        CandidateEntity candidate = candidateRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Candidate not found"));
        
        try {
            if ("DATABASE".equals(storageType) && candidate.getCvData() != null) {
                // View từ database
                ByteArrayResource resource = new ByteArrayResource(candidate.getCvData());
                
                String contentType = candidate.getCvContentType();
                if (contentType == null) {
                    contentType = "application/pdf";
                }
                
                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(contentType))
                        .header(HttpHeaders.CONTENT_DISPOSITION, 
                               "inline; filename=\"" + candidate.getCvOriginalFilename() + "\"")
                        .body(resource);
                        
            } else if (candidate.getCvFilename() != null) {
                // View từ file system
                Path filePath = Paths.get(uploadDir).resolve(candidate.getCvFilename());
                File file = filePath.toFile();
                
                if (!file.exists()) {
                    return ResponseEntity.notFound().build();
                }
                
                Resource resource = new FileSystemResource(file);
                
                // Xác định content type
                String contentType = Files.probeContentType(filePath);
                if (contentType == null) {
                    contentType = "application/pdf";
                }
                
                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(contentType))
                        .header(HttpHeaders.CONTENT_DISPOSITION, 
                               "inline; filename=\"" + candidate.getCvOriginalFilename() + "\"")
                        .body(resource);
            } else {
                return ResponseEntity.notFound().build();
            }
                    
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }
    
    @GetMapping("/delete-candidate/{id}")
    public String deleteCandidate(@PathVariable Long id) {
        CandidateEntity candidate = candidateRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Candidate not found"));
        
        // Xóa file nếu lưu trong file system
        if ("FILE".equals(storageType) && candidate.getCvFilename() != null) {
            try {
                Path filePath = Paths.get(uploadDir).resolve(candidate.getCvFilename());
                Files.deleteIfExists(filePath);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        candidateRepository.delete(candidate);
        return "redirect:/admin/dashboard";
    }
}
