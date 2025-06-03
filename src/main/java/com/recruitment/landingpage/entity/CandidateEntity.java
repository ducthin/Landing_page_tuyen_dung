package com.recruitment.landingpage.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.ToString;
import java.time.LocalDateTime;

@Entity
@Table(name = "candidates")
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(exclude = {"cvData"}) // Exclude large binary data from toString
public class CandidateEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String fullName;
    
    @Column(nullable = false)
    private String phoneNumber;
    
    @Column(nullable = false, length = 1000)
    private String address;
    
    @Column(nullable = false)
    private String availableStartTime;
    
    // Option 1: Lưu file vào database (LONGBLOB cho file lớn)
    @Lob
    @Column(name = "cv_data", columnDefinition = "LONGBLOB")
    private byte[] cvData;
    
    @Column(name = "cv_content_type")
    private String cvContentType;
    
    @Column(nullable = false)
    private String cvOriginalFilename;
    
    // Option 2: Lưu đường dẫn file (giữ lại để tương thích)
    @Column(name = "cv_filename")
    private String cvFilename;    @Column(nullable = false)
    private LocalDateTime createdAt;
    
    // Custom constructor for database storage (with binary data)
    public CandidateEntity(String fullName, String phoneNumber, String address, 
                          String availableStartTime, byte[] cvData, String cvContentType, String cvOriginalFilename) {
        this.fullName = fullName;
        this.phoneNumber = phoneNumber;
        this.address = address;
        this.availableStartTime = availableStartTime;
        this.cvData = cvData;
        this.cvContentType = cvContentType;
        this.cvOriginalFilename = cvOriginalFilename;
        this.createdAt = LocalDateTime.now();
    }
    
    // Custom constructor for file storage (backward compatibility)
    public CandidateEntity(String fullName, String phoneNumber, String address, 
                          String availableStartTime, String cvFilename, String cvOriginalFilename) {
        this.fullName = fullName;
        this.phoneNumber = phoneNumber;
        this.address = address;
        this.availableStartTime = availableStartTime;
        this.cvFilename = cvFilename;
        this.cvOriginalFilename = cvOriginalFilename;
        this.createdAt = LocalDateTime.now();
    }
    
    // JPA lifecycle method để tự động set createdAt
    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
