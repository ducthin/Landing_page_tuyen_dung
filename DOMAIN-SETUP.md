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

# DOMAIN & SSL SETUP GUIDE

## Tổng quan
Hướng dẫn cấu hình domain và SSL certificate cho ứng dụng tuyển dụng WELL CENTER.

## Bước 1: Cấu hình DNS

### 1.1. Truy cập quản lý DNS của domain
- Đăng nhập vào tài khoản domain provider (VD: GoDaddy, Namecheap, etc.)
- Tìm phần DNS Management hoặc DNS Records

### 1.2. Tạo DNS Records
Tạo 2 records sau:

```
Type: A
Name: @
Value: [IP_ADDRESS_CUA_VPS]
TTL: 300 (5 phút)

Type: A  
Name: www
Value: [IP_ADDRESS_CUA_VPS]
TTL: 300 (5 phút)
```

**Lưu ý**: Thay `[IP_ADDRESS_CUA_VPS]` bằng IP thực tế của VPS

### 1.3. Kiểm tra DNS propagation
```bash
# Kiểm tra domain chính
dig tuyendungwellcenter.com

# Kiểm tra www subdomain  
dig www.tuyendungwellcenter.com

# Hoặc sử dụng online tool
# https://www.whatsmydns.net/
```

**Chờ 5-15 phút** để DNS propagation hoàn tất.

## Bước 2: Chạy setup domain (HTTP only)

```bash
# Trên VPS, chạy script setup domain
sudo ./setup-domain.sh
```

Script này sẽ:
- Backup nginx config hiện tại
- Cấu hình nginx cho domain (HTTP only)
- Restart Docker containers
- Test HTTP connection

## Bước 3: Cài đặt SSL Certificate

### 3.1. Chạy script SSL
```bash
# Chạy script cài đặt SSL
sudo ./setup-ssl.sh
```

### 3.2. Nếu gặp lỗi SSL
Sử dụng script khắc phục nhanh:
```bash
# Script này sẽ dừng tất cả services và tạo lại certificate
sudo ./fix-ssl.sh
```

## Troubleshooting SSL Issues

### Lỗi: "Could not bind to port 80"

**Nguyên nhân**: Có service khác đang sử dụng port 80

**Giải pháp**:
```bash
# Dừng tất cả Docker containers
sudo docker-compose down

# Dừng nginx system service nếu có
sudo systemctl stop nginx

# Kiểm tra process nào đang dùng port 80
sudo lsof -i :80

# Hoặc
sudo netstat -tlnp | grep :80

# Dừng process (thay PID bằng process ID thực tế)
sudo kill -9 [PID]

# Chạy lại script SSL
sudo ./fix-ssl.sh
```

### Lỗi: DNS không trỏ về server

**Kiểm tra**:
```bash
# IP của server
curl ifconfig.me

# IP mà domain trỏ tới
dig +short tuyendungwellcenter.com
```

**Giải pháp**: Đợi DNS propagation hoàn tất (có thể mất tới 24h)

### Lỗi: Certificate không được tạo

**Kiểm tra logs**:
```bash
# Xem Certbot logs
sudo tail -f /var/log/letsencrypt/letsencrypt.log

# Xem Docker logs
sudo docker-compose logs nginx
```

**Các nguyên nhân thường gặp**:
1. DNS chưa trỏ về server
2. Firewall chặn port 80/443
3. Domain không accessible từ internet

## Bước 4: Kiểm tra kết quả

### 4.1. Test HTTP và HTTPS
```bash
# Test HTTP (sẽ redirect về HTTPS)
curl -I http://tuyendungwellcenter.com

# Test HTTPS
curl -I https://tuyendungwellcenter.com

# Test WWW
curl -I https://www.tuyendungwellcenter.com
```

### 4.2. Kiểm tra SSL certificate
```bash
# Xem thông tin certificate
openssl x509 -in /etc/letsencrypt/live/tuyendungwellcenter.com/fullchain.pem -text -noout | grep -A 2 "Validity"

# Test SSL online
# https://www.ssllabs.com/ssltest/
```

## Bước 5: Auto-renewal

Certificate sẽ tự động renew qua cron job. Kiểm tra:
```bash
# Xem cron jobs
sudo crontab -l

# Test renewal thủ công
sudo certbot renew --dry-run
```

## Các lệnh hữu ích

### Quản lý services
```bash
# Restart tất cả services
sudo docker-compose restart

# Xem logs
sudo docker-compose logs -f

# Xem logs của nginx
sudo docker-compose logs nginx

# Restart chỉ nginx
sudo docker-compose restart nginx
```

### Quản lý SSL
```bash
# Xem tất cả certificates
sudo certbot certificates

# Renew thủ công
sudo certbot renew

# Xóa certificate
sudo certbot delete --cert-name tuyendungwellcenter.com
```

### Debug nginx
```bash
# Test nginx config
sudo docker-compose exec nginx nginx -t

# Reload nginx config
sudo docker-compose exec nginx nginx -s reload
```

## Kết quả cuối cùng

Sau khi hoàn tất, bạn sẽ có:
- ✅ Website accessible tại: https://tuyendungwellcenter.com
- ✅ WWW redirect: https://www.tuyendungwellcenter.com
- ✅ HTTP redirect tự động về HTTPS
- ✅ SSL certificate A+ rating
- ✅ Auto-renewal cho certificate

## Liên hệ hỗ trợ

Nếu gặp vấn đề, cung cấp thông tin sau:
1. Output của: `sudo docker-compose logs`
2. Output của: `dig tuyendungwellcenter.com`
3. Output của: `sudo certbot certificates`
4. Screenshot lỗi trong browser (nếu có)
