package com.recruitment.landingpage.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class EmailReply {
    private String to;
    private String cc;
    private String bcc;
    private String subject;
    private String content;
    private boolean html; // Thay đổi từ isHtml thành html
    private Long candidateId; // Optional: link to candidate
}
