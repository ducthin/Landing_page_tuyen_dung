package com.recruitment.landingpage.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.ToString;
import org.springframework.web.multipart.MultipartFile;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(exclude = "cvFile") // Exclude cvFile from toString to avoid large output
public class Candidate {
    
    @NotBlank(message = "Họ và tên không được để trống")
    private String fullName;
      @NotBlank(message = "Số điện thoại không được để trống")
    @Pattern(regexp = "^(\\+84|0)[3-9][0-9]{8}$", message = "Số điện thoại không hợp lệ")
    private String phoneNumber;
    
    @Pattern(regexp = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", message = "Email không hợp lệ")
    private String email;
    
    @NotBlank(message = "Địa chỉ không được để trống")
    private String address;
    
    @NotBlank(message = "Thời gian có thể nhận việc không được để trống")
    private String availableStartTime;    
    private MultipartFile cvFile;
    
    // Custom constructor without cvFile (for forms without file upload)
    public Candidate(String fullName, String phoneNumber, String address, String availableStartTime) {
        this.fullName = fullName;
        this.phoneNumber = phoneNumber;
        this.address = address;
        this.availableStartTime = availableStartTime;
    }
}
