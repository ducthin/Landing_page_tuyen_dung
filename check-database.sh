#!/bin/bash

# Script kiểm tra và làm sạch database trên VPS
echo "🔍 Kiểm tra database trên VPS..."

# Kiểm tra xem có container MySQL đang chạy không
if docker ps | grep -q mysql; then
    echo "📊 MySQL container đang chạy"
    
    # Kết nối vào MySQL và kiểm tra table users
    echo "🔍 Kiểm tra users trong database..."
    docker exec -it $(docker ps -q --filter "name=mysql") mysql -u recruitment_user -pWellCenter2025! -D recruitment_db -e "SELECT username, role FROM users WHERE role='ADMIN';"
    
    echo ""
    echo "⚠️  Nếu thấy tài khoản admin cũ ở trên, chúng ta sẽ xóa toàn bộ để đảm bảo bảo mật"
    read -p "🗑️  Bạn có muốn xóa TẤT CẢ users admin cũ? (y/N): " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo "🗑️ Xóa tất cả admin users cũ..."
        docker exec -it $(docker ps -q --filter "name=mysql") mysql -u recruitment_user -pWellCenter2025! -D recruitment_db -e "DELETE FROM users WHERE role='ADMIN';"
        echo "✅ Đã xóa tất cả admin users cũ"
        
        echo "📊 Kiểm tra lại database:"
        docker exec -it $(docker ps -q --filter "name=mysql") mysql -u recruitment_user -pWellCenter2025! -D recruitment_db -e "SELECT username, role FROM users WHERE role='ADMIN';"
    fi
    
else
    echo "❌ Không tìm thấy MySQL container đang chạy"
    echo "💡 Hãy chạy: docker-compose up -d mysql"
fi

echo ""
echo "🚀 Bây giờ hãy build và deploy lại ứng dụng để DataLoader tạo admin mới:"
echo "   ./deploy.sh"
