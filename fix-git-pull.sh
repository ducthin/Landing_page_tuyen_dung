#!/bin/bash

# Script để xử lý Git conflicts khi pull code mới từ Windows lên VPS

echo "🔄 RESOLVING GIT CONFLICTS ON VPS"
echo "================================="

VPS_HOST="root@tuyendungwellcenter.com"
VPS_PATH="/opt/wellcenter"

echo "1️⃣ Checking current Git status on VPS..."
ssh $VPS_HOST "cd $VPS_PATH && git status"

echo ""
echo "2️⃣ Backing up local changes..."
ssh $VPS_HOST "cd $VPS_PATH && cp src/main/resources/application-prod.properties src/main/resources/application-prod.properties.backup"

echo ""
echo "3️⃣ Showing differences in application-prod.properties..."
ssh $VPS_HOST "cd $VPS_PATH && git diff src/main/resources/application-prod.properties"

echo ""
echo "4️⃣ Options to resolve conflict:"
echo "   a) Stash local changes and pull (recommended)"
echo "   b) Reset local changes and pull (lose local changes)"
echo "   c) Commit local changes first"
echo ""

read -p "Select option (a/b/c): " choice

case $choice in
    a)
        echo "🔄 Stashing local changes and pulling..."
        ssh $VPS_HOST "cd $VPS_PATH && git stash && git pull origin main"
        echo ""
        echo "✅ Pull completed. Local changes are stashed."
        echo "📋 To see stashed changes: git stash show -p"
        echo "📋 To apply stashed changes: git stash pop"
        echo "📋 Backup file available at: application-prod.properties.backup"
        ;;
    b)
        echo "⚠️ Resetting local changes and pulling..."
        ssh $VPS_HOST "cd $VPS_PATH && git checkout -- src/main/resources/application-prod.properties && git pull origin main"
        echo "✅ Pull completed. Local changes discarded."
        echo "📋 Backup file available at: application-prod.properties.backup"
        ;;
    c)
        echo "💾 Committing local changes first..."
        ssh $VPS_HOST "cd $VPS_PATH && git add src/main/resources/application-prod.properties && git commit -m 'Local VPS changes to application-prod.properties' && git pull origin main"
        echo "✅ Local changes committed and pulled."
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo ""
echo "5️⃣ Final Git status:"
ssh $VPS_HOST "cd $VPS_PATH && git status"

echo ""
echo "6️⃣ Verifying new test scripts are available:"
ssh $VPS_HOST "cd $VPS_PATH && ls -la *.sh *.ps1 *.md | grep -E '(test-direct|cleanup|monitor|upload|DIRECT)'"

echo ""
echo "🎉 Git pull resolved successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Set permissions: chmod +x *.sh"
echo "   2. Run direct test: ./test-direct-run.sh"
echo "   3. Check guide: cat DIRECT-RUN-GUIDE.md"
