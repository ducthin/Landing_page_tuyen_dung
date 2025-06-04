package com.recruitment.landingpage.config;

import com.recruitment.landingpage.entity.User;
import com.recruitment.landingpage.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataLoader implements ApplicationRunner {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Value("${app.admin.username:admintuyendung}")
    private String adminUsername;    @Value("${app.admin.password:Wellcenter}")
    private String adminPassword;

    @Override
    public void run(ApplicationArguments args) throws Exception {
        // Bước 1: Xóa TẤT CẢ các user admin cũ để đảm bảo bảo mật
        userRepository.deleteByRole("ADMIN");
        System.out.println("🗑️ Removed all existing admin users for security");
        
        // Bước 2: Tạo DUY NHẤT 1 admin user mới từ biến môi trường
        User admin = new User();
        admin.setUsername(adminUsername);
        admin.setPassword(passwordEncoder.encode(adminPassword));
        admin.setRole("ADMIN");
        admin.setEnabled(true);
        
        userRepository.save(admin);
        System.out.println("✅ New admin user created successfully!");
        System.out.println("   Username: " + adminUsername);
        System.out.println("   Password: " + adminPassword);
        System.out.println("🔒 All default admin accounts have been removed for security");
    }
}
