#!/bin/bash

# Script để setup sau khi git pull thành công

echo "🔧 SETUP AFTER GIT PULL"
echo "======================="

# Khôi phục local changes
echo "1️⃣ Restoring local Gmail SMTP changes..."
git stash pop

# Cấp quyền cho scripts
echo "2️⃣ Setting execute permissions for scripts..."
chmod +x *.sh

# Kiểm tra scripts có sẵn
echo "3️⃣ Available test scripts:"
ls -la *.sh | grep "test\|cleanup\|monitor"

# Hiển thị hướng dẫn
echo ""
echo "✅ SETUP COMPLETED!"
echo ""
echo "🚀 READY TO TEST DIRECT RUN:"
echo "   ./test-direct-run.sh"
echo ""
echo "🧪 IN ANOTHER TERMINAL:"
echo "   ./test-email-direct.sh"
echo ""
echo "🧹 AFTER TESTING:"
echo "   ./cleanup-direct-test.sh"
echo ""
echo "📖 FOR DETAILED GUIDE:"
echo "   cat DIRECT-RUN-GUIDE.md"
