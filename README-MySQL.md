# Recruitment Landing Page - MySQL Version

Ứng dụng Spring Boot cho tuyển dụng với database MySQL.

## Yêu cầu hệ thống

- Java 17+
- Maven 3.6+
- MySQL 8.0+ (hoặc MySQL 5.7+)

## Cài đặt MySQL

### 1. Cài đặt MySQL Server
Tham khảo file `database/README.md` để biết chi tiết cách cài đặt MySQL.

### 2. Cấu hình Database

#### Cách 1: Sử dụng root user (đơn giản)
MySQL sẽ tự tạo database `recruitment_db`. Chỉ cần:
- Đảm bảo MySQL đang chạy
- Username: `root`
- Password: (để trống hoặc password của bạn)

#### Cách 2: Tạo user riêng (khuyến nghị)
```sql
mysql -u root -p
CREATE DATABASE recruitment_db;
CREATE USER 'recruitment_user'@'localhost' IDENTIFIED BY 'recruitment_password';
GRANT ALL PRIVILEGES ON recruitment_db.* TO 'recruitment_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

Sau đó cập nhật username/password trong `application.properties`.

## Chạy ứng dụng

### Development Mode
```bash
./mvnw.cmd spring-boot:run
```

### Production Mode với MySQL profile
```bash
./mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=mysql
```

## Cấu hình

### Cấu hình chính: `application.properties`
- Database URL: `jdbc:mysql://localhost:3306/recruitment_db`
- Hibernate DDL: `update` (tự động tạo/cập nhật bảng)

### Cấu hình MySQL riêng: `application-mysql.properties`
Sử dụng khi cần cấu hình MySQL chi tiết hơn.

## Truy cập ứng dụng

- **Trang chủ (Form tuyển dụng)**: http://localhost:8080
- **Admin Login**: http://localhost:8080/admin/login
- **Admin Dashboard**: http://localhost:8080/admin/dashboard

### Tài khoản Admin mặc định
- Username: `admin`
- Password: `admin123`

## Tính năng

✅ **Form tuyển dụng công khai**
- Nhập thông tin ứng viên
- Upload CV (PDF/DOC/DOCX, tối đa 5MB)
- Google Maps hiển thị vị trí công ty

✅ **Hệ thống Admin**
- Đăng nhập bảo mật
- Dashboard thống kê
- Xem danh sách ứng viên
- Tải CV và xem chi tiết
- Xóa ứng viên

✅ **Database MySQL**
- Lưu trữ dữ liệu persistent
- Quản lý users và candidates
- Auto-create database và tables

## Troubleshooting

### Lỗi kết nối MySQL
1. Kiểm tra MySQL service: `sudo systemctl status mysql` (Linux) hoặc Services (Windows)
2. Kiểm tra username/password trong `application.properties`
3. Kiểm tra port 3306 có bị chặn không

### Lỗi permissions
```sql
GRANT ALL PRIVILEGES ON recruitment_db.* TO 'your_user'@'localhost';
FLUSH PRIVILEGES;
```

### Lỗi timezone
Đã được cấu hình sẵn với timezone Vietnam: `Asia/Ho_Chi_Minh`

## Cấu trúc Database

### Bảng `users`
- id, username, password, role, enabled

### Bảng `candidates`
- id, full_name, phone_number, address, available_start_time
- cv_filename, cv_original_filename, created_at

---

**Lưu ý**: Dữ liệu sẽ được lưu trữ persistent trong MySQL, khác với H2 in-memory database trước đó.
