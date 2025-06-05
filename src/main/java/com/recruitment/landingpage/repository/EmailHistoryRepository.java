package com.recruitment.landingpage.repository;

import com.recruitment.landingpage.entity.EmailHistoryEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface EmailHistoryRepository extends JpaRepository<EmailHistoryEntity, Long> {
    
    // Find by candidate ID
    List<EmailHistoryEntity> findByCandidateIdOrderBySentAtDesc(Long candidateId);
    
    // Find by sent by (admin username)
    Page<EmailHistoryEntity> findBySentByOrderBySentAtDesc(String sentBy, Pageable pageable);
    
    // Find all ordered by sent date
    Page<EmailHistoryEntity> findAllByOrderBySentAtDesc(Pageable pageable);
    
    // Find by date range
    @Query("SELECT e FROM EmailHistoryEntity e WHERE e.sentAt BETWEEN :startDate AND :endDate ORDER BY e.sentAt DESC")
    Page<EmailHistoryEntity> findByDateRange(@Param("startDate") LocalDateTime startDate, 
                                           @Param("endDate") LocalDateTime endDate, 
                                           Pageable pageable);
    
    // Find successful emails
    Page<EmailHistoryEntity> findBySuccessTrueOrderBySentAtDesc(Pageable pageable);
    
    // Find failed emails
    Page<EmailHistoryEntity> findBySuccessFalseOrderBySentAtDesc(Pageable pageable);
    
    // Search by email or subject
    @Query("SELECT e FROM EmailHistoryEntity e WHERE " +
           "e.toEmail LIKE %:keyword% OR " +
           "e.subject LIKE %:keyword% OR " +
           "e.content LIKE %:keyword% " +
           "ORDER BY e.sentAt DESC")
    Page<EmailHistoryEntity> searchEmails(@Param("keyword") String keyword, Pageable pageable);
}
