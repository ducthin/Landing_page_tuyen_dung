package com.recruitment.landingpage.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;

@Entity
@Table(name = "email_history")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class EmailHistoryEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String toEmail;
    
    @Column
    private String ccEmail;
    
    @Column
    private String bccEmail;
    
    @Column(nullable = false, length = 500)
    private String subject;
    
    @Lob
    @Column(nullable = false, columnDefinition = "LONGTEXT")
    private String content;
    
    @Column(nullable = false)
    private boolean isHtml;
    
    @Column
    private Long candidateId; // Link to candidate if applicable
    
    @Column(nullable = false)
    private String sentBy; // Admin username who sent the email
    
    @Column(nullable = false)
    private LocalDateTime sentAt;
    
    @Column
    private boolean success;
    
    @Column(length = 1000)
    private String errorMessage;
    
    // JPA lifecycle method
    @PrePersist
    protected void onCreate() {
        if (sentAt == null) {
            sentAt = ZonedDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")).toLocalDateTime();
        }
    }
}
