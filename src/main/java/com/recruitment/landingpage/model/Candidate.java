package com.recruitment.landingpage.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import org.springframework.web.multipart.MultipartFile;

public class Candidate {
    
    @NotBlank(message = "Họ và tên không được để trống")
    private String fullName;
    
    @NotBlank(message = "Số điện thoại không được để trống")
    @Pattern(regexp = "^(\\+84|0)[3-9][0-9]{8}$", message = "Số điện thoại không hợp lệ")
    private String phoneNumber;
    
    @NotBlank(message = "Địa chỉ không được để trống")
    private String address;
    
    @NotBlank(message = "Thời gian có thể nhận việc không được để trống")
    private String availableStartTime;
    
    private MultipartFile cvFile;
    
    // Constructors
    public Candidate() {}
    
    public Candidate(String fullName, String phoneNumber, String address, String availableStartTime) {
        this.fullName = fullName;
        this.phoneNumber = phoneNumber;
        this.address = address;
        this.availableStartTime = availableStartTime;
    }
    
    // Getters and Setters
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
    
    public MultipartFile getCvFile() {
        return cvFile;
    }
    
    public void setCvFile(MultipartFile cvFile) {
        this.cvFile = cvFile;
    }
    
    @Override
    public String toString() {
        return "Candidate{" +
                "fullName='" + fullName + '\'' +
                ", phoneNumber='" + phoneNumber + '\'' +
                ", address='" + address + '\'' +
                ", availableStartTime='" + availableStartTime + '\'' +
                ", cvFile=" + (cvFile != null ? cvFile.getOriginalFilename() : "null") +
                '}';
    }
}
