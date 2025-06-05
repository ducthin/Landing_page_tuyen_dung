# Tính năng Gửi Email Admin - WELL CENTER

## Tổng quan

Tính năng gửi email cho phép admin trả lời tin nhắn/email ứng viên trực tiếp qua Gmail từ trang admin, lưu lịch sử email đã gửi.

## Các tính năng chính

### 1. Thu thập Email từ Ứng viên
- Thêm trường email (tùy chọn) trong form ứng tuyển
- Validation email format chuẩn
- Lưu trữ email trong database

### 2. Gửi Email từ Admin
- **Soạn Email mới**: `/admin/email/compose`
- **Template có sẵn**: 
  - Xác nhận nhận hồ sơ
  - Mời phỏng vấn
  - Thư mời làm việc
  - Từ chối ứng viên
- **Rich Text Editor**: Sử dụng Quill editor
- **CC/BCC**: Hỗ trợ gửi bản sao

### 3. Gửi Email từ Trang Ứng viên
- Nút "Gửi Email" trên dashboard cho ứng viên có email
- Nút "Gửi Email" trên trang chi tiết ứng viên
- Tự động điền email ứng viên khi click

### 4. Lịch sử Email
- **Xem tất cả**: `/admin/email/history`
- **Tìm kiếm**: Theo email, tiêu đề, nội dung
- **Lọc**: Email thành công/thất bại
- **Phân trang**: 20 email/trang
- **Chi tiết**: Thời gian, người gửi, trạng thái

### 5. Lịch sử Email theo Ứng viên
- Xem tất cả email đã gửi cho ứng viên cụ thể
- Timeline email theo thời gian
- Trạng thái gửi thành công/thất bại

## Cấu hình Email

### Environment Variables (.env)
```bash
# Gmail Configuration
SPRING_MAIL_HOST=smtp.gmail.com
SPRING_MAIL_PORT=587
SPRING_MAIL_USERNAME=your-email@gmail.com
SPRING_MAIL_PASSWORD=your-app-password
SPRING_MAIL_PROPERTIES_MAIL_SMTP_AUTH=true
SPRING_MAIL_PROPERTIES_MAIL_SMTP_STARTTLS_ENABLE=true

# Application Base URL (for email links)
APP_BASE_URL=https://yourdomain.com
```

### Cấu hình Gmail App Password
1. Bật 2-Factor Authentication cho Gmail
2. Tạo App Password trong Google Account Settings
3. Sử dụng App Password làm `SPRING_MAIL_PASSWORD`

## Database Migration

Chạy script SQL sau để thêm cột email cho database hiện có:

```sql
-- Add email column to candidates table
ALTER TABLE candidates ADD COLUMN email VARCHAR(255) NULL;

-- Add index for better performance
CREATE INDEX idx_candidates_email ON candidates(email);
```

## API Endpoints

### Email Controller
- `GET /admin/email/compose` - Trang soạn email
- `POST /admin/email/send` - Gửi email
- `GET /admin/email/history` - Lịch sử email
- `GET /admin/email/candidate/{id}` - Lịch sử email của ứng viên
- `GET /admin/email/template/{type}` - Lấy template email
- `POST /admin/email/quick-reply` - Gửi email nhanh

### Dashboard Updates
- Hiển thị cột email trong bảng ứng viên
- Nút "Gửi Email" cho ứng viên có email
- Navigation menu có liên kết email

## Templates Email Có Sẵn

### 1. Xác nhận nhận hồ sơ
```
Chào [Tên ứng viên],

Chúng tôi đã nhận được hồ sơ ứng tuyển của bạn tại WELL CENTER. 
Chúng tôi sẽ xem xét và liên hệ lại với bạn trong thời gian sớm nhất.

Trân trọng,
WELL CENTER Team
```

### 2. Mời phỏng vấn
```
Chào [Tên ứng viên],

Sau khi xem xét hồ sơ, chúng tôi muốn mời bạn tham gia phỏng vấn tại WELL CENTER.

Thời gian: [Thời gian phỏng vấn]
Địa điểm: [Địa chỉ công ty]

Vui lòng xác nhận tham gia.

Trân trọng,
WELL CENTER Team
```

### 3. Thư mời làm việc
```
Chào [Tên ứng viên],

Chúc mừng! Bạn đã được chọn làm việc tại WELL CENTER.

Chi tiết công việc và điều kiện làm việc sẽ được thông báo cụ thể khi bạn xác nhận nhận việc.

Trân trọng,
WELL CENTER Team
```

### 4. Từ chối ứng viên
```
Chào [Tên ứng viên],

Cảm ơn bạn đã quan tâm đến WELL CENTER. 
Sau khi xem xét, chúng tôi quyết định không tiếp tục với hồ sơ của bạn lần này.

Chúc bạn thành công trong việc tìm kiếm công việc phù hợp.

Trân trọng,
WELL CENTER Team
```

## Cách sử dụng

### 1. Gửi Email từ Dashboard
1. Vào `/admin/dashboard`
2. Tìm ứng viên có email
3. Click nút "Gửi Email" (màu vàng)
4. Soạn nội dung và gửi

### 2. Gửi Email từ Chi tiết Ứng viên
1. Vào chi tiết ứng viên
2. Click "Gửi Email" (nếu có email)
3. Email tự động được điền
4. Chọn template hoặc soạn tự do

### 3. Xem Lịch sử Email
1. Vào `/admin/email/history`
2. Tìm kiếm theo từ khóa
3. Click vào email để xem chi tiết
4. Xem trạng thái gửi thành công/thất bại

### 4. Quản lý Template
- Sử dụng các template có sẵn
- Chỉnh sửa nội dung theo nhu cầu
- Hỗ trợ HTML và plain text

## Lưu ý Bảo mật

1. **App Password**: Sử dụng App Password của Gmail, không dùng mật khẩu chính
2. **HTTPS**: Chỉ sử dụng qua HTTPS trên production
3. **Rate Limiting**: Gmail có giới hạn số email gửi/ngày
4. **Email Validation**: Validate email format trước khi gửi
5. **Error Handling**: Log lỗi gửi email để debug

## Troubleshooting

### Email không gửi được
1. Kiểm tra App Password Gmail
2. Kiểm tra cấu hình SMTP
3. Kiểm tra kết nối internet
4. Xem log lỗi trong console

### Template không hiển thị
1. Kiểm tra file template
2. Kiểm tra controller mapping
3. Restart ứng dụng

### Database lỗi
1. Chạy migration script
2. Kiểm tra kết nối database
3. Backup trước khi thay đổi

## Phát triển thêm

### Tính năng có thể bổ sung
- [ ] Email templates động từ database
- [ ] Bulk email cho nhiều ứng viên
- [ ] Email scheduling (gửi sau)
- [ ] Email analytics (open rate, click rate)
- [ ] File attachment trong email
- [ ] Email signatures tùy chỉnh
- [ ] Email auto-reply
- [ ] Integration với CRM khác

### Performance Optimization
- [ ] Async email sending
- [ ] Email queue system
- [ ] Caching for templates
- [ ] Database indexing optimization

## File Structure

```
src/main/java/com/recruitment/landingpage/
├── controller/
│   └── EmailController.java          # Email management endpoints
├── entity/
│   ├── CandidateEntity.java         # Updated with email field
│   └── EmailHistoryEntity.java      # Email history storage
├── model/
│   ├── Candidate.java               # Updated with email field
│   └── EmailReply.java              # Email sending model
├── repository/
│   └── EmailHistoryRepository.java  # Email history queries
└── service/
    └── EmailService.java            # Email business logic

src/main/resources/templates/admin/
├── email-compose.html               # Email composition page
├── email-history.html               # Email history listing
├── candidate-email-history.html     # Per-candidate email history
├── dashboard.html                   # Updated with email buttons
└── candidate-detail.html            # Updated with email info

Database:
├── add_email_column.sql             # Migration script
└── Email history tables (auto-created by JPA)
```

## Changelog

### v1.0.0 - Initial Release
- ✅ Email field in candidate form
- ✅ Email composition with rich editor
- ✅ Email templates
- ✅ Email history tracking
- ✅ Per-candidate email history
- ✅ Search and pagination
- ✅ Gmail integration
- ✅ Dashboard integration
- ✅ Error handling and logging

### Next Release (Planned)
- 🔄 Email attachments
- 🔄 Email scheduling
- 🔄 Bulk email operations
- 🔄 Advanced analytics
