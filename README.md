# 🎯 Hệ Thống Tuyển Dụng Trực Tuyến

Hệ thống tuyển dụng hoàn chỉnh được xây dựng bằng Spring Boot với giao diện thân thiện, hỗ trợ quản lý ứng viên và thông báo email tự động.

## ✨ Tính năng chính

### � **Dành cho Ứng viên**
- **�📝 Form ứng tuyển trực tuyến**: Giao diện đơn giản, dễ sử dụng
- **📎 Upload CV**: Hỗ trợ PDF, DOC, DOCX (tối đa 5MB)
- **✅ Validation thông minh**: Kiểm tra dữ liệu realtime
- **📱 Responsive**: Tương thích mọi thiết bị

### 🔐 **Dành cho Admin**
- **📊 Dashboard quản lý**: Xem danh sách tất cả ứng viên
- **👁️ Xem CV trực tiếp**: Xem CV ngay trong trình duyệt
- **📧 Thông báo email**: Nhận email khi có ứng viên mới
- **🔍 Chi tiết ứng viên**: Xem thông tin đầy đủ từng ứng viên

### 🛠️ **Tính năng kỹ thuật**
- **🗄️ Database MySQL**: Lưu trữ dữ liệu ổn định
- **💾 Lưu trữ linh hoạt**: Hỗ trợ lưu CV trong database hoặc file
- **📨 Email tự động**: Gửi thông báo ngay khi có ứng viên mới
- **🔒 Bảo mật**: Xác thực admin với Spring Security

## 🚀 Công nghệ sử dụng

| Công nghệ | Phiên bản | Mục đích |
|-----------|-----------|----------|
| **Spring Boot** | 3.5.0 | Framework chính |
| **MySQL** | 8.0+ | Cơ sở dữ liệu |
| **Thymeleaf** | 3.1+ | Template engine |
| **Spring Security** | 6.0+ | Bảo mật và xác thực |
| **Spring Mail** | 6.0+ | Gửi email |
| **Bootstrap** | 5.3 | Giao diện responsive |
| **Font Awesome** | 6.0+ | Icons |

## 📋 Yêu cầu hệ thống

- ☕ **Java 17** hoặc cao hơn
- 🔨 **Maven 3.6+**
- 🗄️ **MySQL 8.0+**
- 📧 **Gmail account** (cho email notifications)

## ⚡ Cài đặt và cấu hình

### 1️⃣ **Chuẩn bị Database**

```sql
-- Tạo database
CREATE DATABASE recruitment_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Tạo user (tuỳ chọn)
CREATE USER 'recruitment_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON recruitment_db.* TO 'recruitment_user'@'localhost';
FLUSH PRIVILEGES;
```

### 2️⃣ **Cấu hình Email (Gmail)**

1. Bật **2-Factor Authentication** cho Gmail
2. Tạo **App Password**:
   - Vào Google Account Settings
   - Security → 2-Step Verification → App passwords
   - Chọn "Mail" → Generate password
3. Sao chép App Password để dùng trong cấu hình

### 3️⃣ **Cấu hình ứng dụng**

Tạo file `src/main/resources/application.properties`:

```properties
# Database Configuration
spring.datasource.url=jdbc:mysql://localhost:3306/recruitment_db?useSSL=false&serverTimezone=UTC&characterEncoding=UTF-8
spring.datasource.username=recruitment_user
spring.datasource.password=your_password
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQLDialect
spring.jpa.properties.hibernate.format_sql=true

# File Upload Configuration
spring.servlet.multipart.max-file-size=5MB
spring.servlet.multipart.max-request-size=5MB

# CV Storage Configuration (FILE hoặc DATABASE)
app.cv.storage.type=DATABASE

# Email Configuration
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=your-email@gmail.com
spring.mail.password=your-app-password
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true

# Admin Configuration
app.admin.email=admin@company.com
app.admin.name=HR Manager
app.admin.username=admin
app.admin.password=admin123

# Server Configuration
server.port=8080
```

### 4️⃣ **Chạy ứng dụng**

```bash
# Clone và vào thư mục project
cd recruitment-landing-page

# Chạy ứng dụng (Linux/Mac)
./mvnw spring-boot:run

# Hoặc trên Windows
mvnw.cmd spring-boot:run
```

### 5️⃣ **Truy cập hệ thống**

| Trang | URL | Mô tả |
|-------|-----|-------|
| **Trang ứng tuyển** | `http://localhost:8080` | Form cho ứng viên |
| **Admin Login** | `http://localhost:8080/login` | Đăng nhập admin |
| **Dashboard** | `http://localhost:8080/admin/dashboard` | Quản lý ứng viên |
| **Test Email** | `http://localhost:8080/test-email` | Kiểm tra cấu hình email |

**🔑 Thông tin đăng nhập admin:**
- Username: `admin`
- Password: `admin123`

## 📁 Cấu trúc dự án

```
src/
├── main/
│   ├── java/com/recruitment/landingpage/
│   │   ├── RecruitmentLandingPageApplication.java
│   │   ├── config/
│   │   │   ├── DataInitializer.java         # Khởi tạo dữ liệu admin
│   │   │   └── SecurityConfig.java          # Cấu hình bảo mật
│   │   ├── controller/
│   │   │   ├── AdminController.java         # Quản lý admin
│   │   │   ├── EmailTestController.java     # Test email
│   │   │   ├── LoginController.java         # Xử lý đăng nhập
│   │   │   └── RecruitmentController.java   # Form ứng tuyển
│   │   ├── entity/
│   │   │   ├── CandidateEntity.java         # Entity ứng viên
│   │   │   └── User.java                    # Entity user/admin
│   │   ├── model/
│   │   │   └── Candidate.java               # Model form
│   │   ├── repository/
│   │   │   ├── CandidateRepository.java     # Repository ứng viên
│   │   │   └── UserRepository.java          # Repository user
│   │   └── service/
│   │       ├── CustomUserDetailsService.java # Service xác thực
│   │       └── EmailService.java            # Service email
│   └── resources/
│       ├── application.properties
│       └── templates/
│           ├── index.html                   # Trang ứng tuyển
│           ├── login.html                   # Trang đăng nhập
│           ├── success.html                 # Trang thành công
│           └── admin/
│               ├── dashboard.html           # Dashboard admin
│               └── candidate-detail.html    # Chi tiết ứng viên
```

## 🎨 Screenshots

### 📝 **Trang ứng tuyển**
- Form nhập liệu với validation đầy đủ
- Upload CV với kiểm tra định dạng
- Giao diện responsive trên mobile

### 🔐 **Trang đăng nhập Admin**
- Form đăng nhập đơn giản
- Xác thực với Spring Security
- Redirect về dashboard sau khi đăng nhập

### 📊 **Dashboard Admin**
- Danh sách tất cả ứng viên
- Thông tin tóm tắt từng ứng viên
- Nút "Xem CV" để xem trực tiếp
- Nút "Chi tiết" để xem thông tin đầy đủ

### 📧 **Email thông báo**
- Email đơn giản, dễ đọc
- Thông tin đầy đủ về ứng viên mới
- Link trực tiếp đến dashboard

## 🧪 Test và Debug

### **Kiểm tra cấu hình Email**
```bash
GET http://localhost:8080/email-config
```

### **Test gửi email**
```bash
GET http://localhost:8080/test-email
```

### **Xem log ứng dụng**
- Email success/error logs trong console
- Database connection status
- File upload status

## 🔧 Tính năng nâng cao có thể bổ sung

- [ ] 📱 **Mobile App** (React Native/Flutter)
- [ ] 🌐 **Multi-language** support (EN/VI)
- [ ] 📈 **Analytics** dashboard
- [ ] 🔔 **Real-time notifications**
- [ ] 📋 **Interview scheduling**
- [ ] 💼 **Multiple job positions**
- [ ] 🔍 **Advanced search & filters**
- [ ] 📊 **Export reports** (Excel/PDF)
- [ ] 🔐 **OAuth login** (Google/Facebook)
- [ ] ☁️ **Cloud storage** (AWS S3/Google Drive)

## 🤝 Đóng góp

Mọi đóng góp đều được chào đón! 

1. **Fork** repository
2. Tạo **feature branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit** changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to branch (`git push origin feature/AmazingFeature`)
5. Tạo **Pull Request**

## 📄 License

Dự án được phân phối dưới **MIT License**. Xem file `LICENSE` để biết thêm chi tiết.

---

💡 **Lưu ý**: Đây là hệ thống hoàn chỉnh với đầy đủ tính năng quản lý ứng viên, email notifications và admin panel. Phù hợp cho các công ty nhỏ và vừa muốn có hệ thống tuyển dụng riêng.

📞 **Hỗ trợ**: Nếu gặp vấn đề, vui lòng tạo issue trên GitHub hoặc liên hệ qua email.
