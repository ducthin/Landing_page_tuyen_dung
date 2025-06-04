package com.recruitment.landingpage.repository;

import com.recruitment.landingpage.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    
    @Modifying
    @Transactional
    @Query("DELETE FROM User u WHERE u.role = :role")
    void deleteByRole(@Param("role") String role);
}
