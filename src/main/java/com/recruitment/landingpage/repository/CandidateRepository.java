package com.recruitment.landingpage.repository;

import com.recruitment.landingpage.entity.CandidateEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface CandidateRepository extends JpaRepository<CandidateEntity, Long> {
    List<CandidateEntity> findAllByOrderByCreatedAtDesc();
      @Query("SELECT COUNT(c) FROM CandidateEntity c WHERE c.cvFilename IS NOT NULL")
    long countByCvFilenameIsNotNull();
    
    long countByCreatedAtBetween(LocalDateTime start, LocalDateTime end);
}
