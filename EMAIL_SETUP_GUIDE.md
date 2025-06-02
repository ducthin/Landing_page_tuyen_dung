# Hướng dẫn cấu hình Gmail cho ứng dụng

## 1. Tạo App Password cho Gmail

### Bước 1: Bật 2-Step Verification
1. Đi tới [Google Account Security](https://myaccount.google.com/security)
2. Trong phần "Signing in to Google", click vào "2-Step Verification"
3. Làm theo hướng dẫn để bật 2-Step Verification

### Bước 2: Tạo App Password
1. Quay lại [Google Account Security](https://myaccount.google.com/security)
2. Trong phần "Signing in to Google", click vào "App passwords"
3. Chọn "Mail" và "Other (Custom name)"
4. Nhập tên: "Recruitment App"
5. Click "Generate"
6. Copy password 16 ký tự được tạo ra

## 2. Cấu hình trong application.properties

Mở file `src/main/resources/application.properties` và cập nhật:

```properties
# Email configuration (Gmail)
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=your_email@gmail.com
spring.mail.password=your_16_digit_app_password
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
spring.mail.properties.mail.smtp.ssl.trust=smtp.gmail.com

# Admin email for notifications
app.admin.email=admin@company.com
app.admin.name=HR Admin
```

### Thay thế:
- `your_email@gmail.com`: Email Gmail của bạn
- `your_16_digit_app_password`: App password 16 ký tự vừa tạo
- `admin@company.com`: Email sẽ nhận thông báo ứng viên mới

## 3. Test cấu hình

1. Restart ứng dụng
2. Truy cập http://localhost:8080
3. Điền form và upload CV
4. Kiểm tra email admin để xem thông báo

## 4. Ví dụ email thông báo

Email sẽ có nội dung:
- Thông tin ứng viên đầy đủ
- Thời gian nộp hồ sơ
- Thông tin CV
- Link truy cập hệ thống admin

## 5. Troubleshooting

### Lỗi thường gặp:
1. **Authentication failed**: Kiểm tra app password
2. **Invalid username/password**: Đảm bảo đã bật 2-Step Verification
3. **Connection timeout**: Kiểm tra firewall/network

### Log kiểm tra:
- Console sẽ hiển thị "Email notification sent successfully" nếu thành công
- Nếu lỗi, kiểm tra stack trace trong console

## 6. Bảo mật

⚠️ **Quan trọng**:
- Không commit app password vào git
- Sử dụng environment variables trong production
- Kiểm tra email admin thường xuyên

## 7. Tùy chỉnh email template

File EmailService.java chứa template HTML có thể tùy chỉnh:
- Thay đổi màu sắc, font chữ
- Thêm logo công ty
- Cập nhật nội dung thông báo
