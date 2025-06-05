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
    private String adminUsername;    
    @Value("${app.admin.password:Wellcenter}")
    private String adminPassword;    @Override
    public void run(ApplicationArguments args) throws Exception {
        userRepository.deleteByRole("ADMIN");
        User admin = new User();
        admin.setUsername(adminUsername);
        admin.setPassword(passwordEncoder.encode(adminPassword));
        admin.setRole("ADMIN");
        admin.setEnabled(true);
        
        userRepository.save(admin);
    }
}
