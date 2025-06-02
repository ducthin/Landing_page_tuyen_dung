# Hướng dẫn cấu hình lưu trữ File CV

Ứng dụng này hỗ trợ 2 cách lưu trữ file CV:

## 1. Lưu vào Database (Mặc định - Khuyến nghị)

```properties
# trong application.properties
app.storage.type=DATABASE
```

**Ưu điểm:**
- ✅ Không cần thư mục uploads
- ✅ File được backup cùng database
- ✅ Bảo mật cao hơn
- ✅ Dễ quản lý, di chuyển
- ✅ Không lo mất file khi deploy

**Nhược điểm:**
- ❌ Database sẽ lớn hơn
- ❌ Tốc độ truy vấn chậm hơn với file lớn

## 2. Lưu vào Thư mục File

```properties
# trong application.properties
app.storage.type=FILE
app.upload.dir=d:/recruitment_files/
```

**Các tùy chọn thư mục:**
```properties
# Windows
app.upload.dir=d:/recruitment_files/
app.upload.dir=c:/temp/cv-files/

# Thư mục người dùng
app.upload.dir=${user.home}/recruitment_cv/

# Thư mục tương đối (trong project)
app.upload.dir=uploads/
```

**Ưu điểm:**
- ✅ Database nhỏ gọn
- ✅ Truy cập file nhanh
- ✅ Dễ backup riêng file

**Nhược điểm:**
- ❌ Phải quản lý thư mục
- ❌ Có thể mất file khi di chuyển server
- ❌ Cần cấu hình permission

## 3. Các tùy chọn khác (có thể implement thêm)

### Cloud Storage
- AWS S3
- Google Cloud Storage
- Azure Blob Storage

### Database khác
- MongoDB GridFS
- PostgreSQL BYTEA

## Cách thay đổi

1. **Sửa file `application.properties`:**
```properties
# Lưu vào database (không cần thư mục)
app.storage.type=DATABASE

# Hoặc lưu vào thư mục
app.storage.type=FILE
app.upload.dir=d:/your-custom-folder/
```

2. **Restart ứng dụng**

## Lưu ý

- File CV tối đa 5MB
- Hỗ trợ định dạng: PDF, DOC, DOCX
- Khi chuyển từ FILE sang DATABASE, các file cũ vẫn hoạt động
- Database sẽ tự tạo cột mới để lưu BLOB data
