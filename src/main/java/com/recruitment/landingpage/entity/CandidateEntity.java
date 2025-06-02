package com.recruitment.landingpage.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "candidates")
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
    private String cvFilename;
    
    @Column(nullable = false)
    private LocalDateTime createdAt;
      
    // Constructors
    public CandidateEntity() {
        this.createdAt = LocalDateTime.now();
    }
    
    // Constructor cho database storage
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
    
    // Constructor cho file storage (backward compatibility)
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
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getFullName() {
        return fullName;
    }
    
    public void setFullName(String fullName) {
        this.fullName = fullName;
    }
    
    public String getPhoneNumber() {
        return phoneNumber;
    }
    
    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }
    
    public String getAddress() {
        return address;
    }
    
    public void setAddress(String address) {
        this.address = address;
    }
    
    public String getAvailableStartTime() {
        return availableStartTime;
    }
    
    public void setAvailableStartTime(String availableStartTime) {
        this.availableStartTime = availableStartTime;
    }
      
    public String getCvFilename() {
        return cvFilename;
    }
    
    public void setCvFilename(String cvFilename) {
        this.cvFilename = cvFilename;
    }
    
    public String getCvOriginalFilename() {
        return cvOriginalFilename;
    }
    
    public void setCvOriginalFilename(String cvOriginalFilename) {
        this.cvOriginalFilename = cvOriginalFilename;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    // New getters and setters for BLOB storage
    public byte[] getCvData() {
        return cvData;
    }

    public void setCvData(byte[] cvData) {
        this.cvData = cvData;
    }

    public String getCvContentType() {
        return cvContentType;
    }

    public void setCvContentType(String cvContentType) {
        this.cvContentType = cvContentType;
    }
}
