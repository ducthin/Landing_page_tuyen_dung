# 🌐 Hướng Dẫn Cấu Hình Domain: tuyendungwellcenter.com

## 📋 Tổng Quan

Hướng dẫn này sẽ giúp bạn cấu hình domain `tuyendungwellcenter.com` với HTTPS/SSL cho website tuyển dụng WELL CENTER.

## 🎯 Các Bước Thực Hiện

### Bước 1: Cấu hình DNS (Quan trọng nhất!)

Truy cập vào nhà cung cấp domain của bạn và tạo các DNS records:

#### A Records cần tạo:
```
Type: A
Name: @
Value: YOUR_VPS_IP
TTL: 3600 (hoặc để mặc định)

Type: A
Name: www
Value: YOUR_VPS_IP
TTL: 3600 (hoặc để mặc định)
```

### Bước 2: Đẩy Code Lên VPS

```bash
# Trên máy local (Windows)
git add .
git commit -m "Configure domain tuyendungwellcenter.com with SSL"
git push origin main
```

### Bước 3: Cấu Hình Trên VPS

```bash
# SSH vào VPS
ssh root@your-vps-ip
cd /opt/wellcenter

# Pull latest changes
git pull origin main

# Cấp quyền execute cho scripts
chmod +x setup-domain.sh setup-ssl.sh restore-ssl.sh
```

### Bước 4: Test Domain (Chỉ HTTP trước)

```bash
# Cấu hình domain tạm thời (HTTP only)
./setup-domain.sh
```

**Kiểm tra DNS đã cập nhật:**
```bash
# Kiểm tra domain trỏ về VPS
dig +short tuyendungwellcenter.com
dig +short www.tuyendungwellcenter.com

# Kết quả phải là IP của VPS
```

**Test website:**
```bash
# Test từ VPS
curl -I http://tuyendungwellcenter.com

# Hoặc mở browser: http://tuyendungwellcenter.com
```

### Bước 5: Cài Đặt SSL (Sau khi domain hoạt động)

```bash
# Cài đặt SSL với Let's Encrypt
sudo ./setup-ssl.sh
```

Script này sẽ:
- ✅ Cài đặt Certbot
- ✅ Tạo SSL certificate cho domain và www
- ✅ Cấu hình Nginx với HTTPS
- ✅ Thiết lập auto-renewal
- ✅ Redirect HTTP → HTTPS

## 🔍 Kiểm Tra Kết Quả

### Sau khi hoàn tất:

✅ **HTTP redirect to HTTPS:**
```bash
curl -I http://tuyendungwellcenter.com
# Phải thấy: Location: https://tuyendungwellcenter.com
```

✅ **HTTPS hoạt động:**
```bash
curl -I https://tuyendungwellcenter.com
# Phải thấy: HTTP/2 200
```

✅ **WWW redirect:**
```bash
curl -I https://www.tuyendungwellcenter.com
# Phải hoạt động bình thường
```

## 🌟 URLs Cuối Cùng

Sau khi hoàn tất, website sẽ accessible tại:

- 🌐 **Main:** https://tuyendungwellcenter.com
- 🌐 **WWW:** https://www.tuyendungwellcenter.com
- 🔒 **SSL:** Tự động từ Let's Encrypt
- ♻️  **Auto-renewal:** Đã được cấu hình

## 🛠️ Troubleshooting

### DNS chưa cập nhật:
```bash
# Kiểm tra DNS
nslookup tuyendungwellcenter.com
dig tuyendungwellcenter.com

# Đợi 5-60 phút và thử lại
```

### SSL không hoạt động:
```bash
# Kiểm tra logs
docker-compose logs nginx

# Kiểm tra certificate
sudo certbot certificates

# Khôi phục config
./restore-ssl.sh
```

### Website không truy cập được:
```bash
# Kiểm tra services
docker-compose ps

# Kiểm tra port
netstat -tlnp | grep :80
netstat -tlnp | grep :443

# Restart services
docker-compose restart
```

## 📊 Monitoring & Maintenance

### Auto-renewal SSL:
```bash
# Kiểm tra cron job
crontab -l

# Test renewal
sudo certbot renew --dry-run
```

### Backup:
```bash
# Backup database
docker-compose exec mysql mysqldump -u recruitment_user -p recruitment_db > backup.sql

# Backup SSL certificates
sudo cp -r /etc/letsencrypt /backup/letsencrypt-$(date +%Y%m%d)
```

## 🎉 Hoàn Tất!

Sau khi hoàn tất các bước trên, website WELL CENTER sẽ hoạt động tại:

**🌐 https://tuyendungwellcenter.com**

Với các tính năng:
- ✅ SSL/HTTPS an toàn
- ✅ Professional domain
- ✅ Auto-renewal SSL
- ✅ Security headers
- ✅ Gzip compression
- ✅ Static files caching
