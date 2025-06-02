# Recruitment Landing Page

Trang web tuyển dụng được xây dựng bằng Spring Boot với giao diện thân thiện và responsive, cho phép ứng viên nộp hồ sơ trực tuyến.

## Tính năng

### 📝 Form Ứng Tuyển
- **Họ và tên**: Trường bắt buộc để nhập tên đầy đủ
- **Số điện thoại**: Validation cho số điện thoại Việt Nam
- **Địa chỉ**: Địa chỉ hiện tại của ứng viên
- **Thời gian có thể nhận việc**: Thời điểm ứng viên có thể bắt đầu làm việc
- **Upload CV**: Hỗ trợ file PDF, DOC, DOCX (tối đa 5MB)

### ✅ Validation
- Tất cả các trường đều có validation phù hợp
- Thông báo lỗi bằng tiếng Việt
- Kiểm tra định dạng và kích thước file

### 🎨 Giao diện
- Responsive design với Bootstrap 5
- Hiệu ứng hover và animation mượt mà
- Icons từ Font Awesome
- Gradient background đẹp mắt

## Công nghệ sử dụng

- **Backend**: Spring Boot 3.5.0
- **Template Engine**: Thymeleaf
- **Frontend**: Bootstrap 5, Font Awesome
- **Validation**: Spring Validation
- **Build Tool**: Maven

## Cài đặt và chạy

### Yêu cầu hệ thống
- Java 17+
- Maven 3.6+

### Chạy ứng dụng

1. **Clone project và di chuyển vào thư mục:**
   ```bash
   cd recruitment-landing-page
   ```

2. **Chạy ứng dụng:**
   ```bash
   ./mvnw spring-boot:run
   ```
   
   Hoặc trên Windows:
   ```cmd
   mvnw.cmd spring-boot:run
   ```

3. **Truy cập ứng dụng:**
   Mở trình duyệt và truy cập: `http://localhost:8080`

### Build file JAR

```bash
./mvnw clean package
java -jar target/landing-page-0.0.1-SNAPSHOT.jar
```

## Cấu trúc project

```
src/
├── main/
│   ├── java/
│   │   └── com/recruitment/landingpage/
│   │       ├── RecruitmentLandingPageApplication.java
│   │       ├── controller/
│   │       │   └── RecruitmentController.java
│   │       └── model/
│   │           └── Candidate.java
│   └── resources/
│       ├── application.properties
│       └── templates/
│           ├── index.html
│           └── success.html
└── test/
    └── java/
        └── com/recruitment/landingpage/
            └── RecruitmentLandingPageApplicationTests.java
```

## Cấu hình

File `application.properties` chứa các cấu hình chính:

```properties
# File upload configuration
spring.servlet.multipart.max-file-size=5MB
spring.servlet.multipart.max-request-size=5MB

# Server configuration  
server.port=8080

# Thymeleaf configuration
spring.thymeleaf.cache=false
```

## Tính năng nâng cao có thể bổ sung

- [ ] Lưu trữ database (MySQL, PostgreSQL)
- [ ] Email notification
- [ ] Admin panel để quản lý ứng viên
- [ ] Integration với các job boards
- [ ] Multi-language support
- [ ] OAuth login
- [ ] File preview functionality

## Screenshots

### Trang ứng tuyển
- Form nhập liệu với validation đầy đủ
- Upload CV với drag & drop
- Responsive design trên mobile

### Trang thành công
- Thông báo ứng tuyển thành công
- Hướng dẫn các bước tiếp theo
- Link quay về trang chủ

## Đóng góp

Mọi đóng góp đều được chào đón! Vui lòng tạo issue hoặc pull request.

## License

This project is licensed under the MIT License.
