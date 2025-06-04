# Quick Upload Script for WELL CENTER
# Usage: .\quick-upload.ps1

$VPS_IP = "14.225.207.250"
$VPS_USER = "root"
$REMOTE_DIR = "/opt/wellcenter"

Write-Host "📤 WELL CENTER - Quick Upload Script" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

# Show menu
Write-Host ""
Write-Host "Choose upload option:" -ForegroundColor Yellow
Write-Host "1. Upload entire project" -ForegroundColor White
Write-Host "2. Upload source code only (src/)" -ForegroundColor White
Write-Host "3. Upload specific file" -ForegroundColor White
Write-Host "4. Upload and deploy automatically" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-4)"

switch ($choice) {
    "1" {
        Write-Host "📦 Uploading entire project..." -ForegroundColor Yellow
        try {
            scp -r . ${VPS_USER}@${VPS_IP}:${REMOTE_DIR}/
            Write-Host "✅ Project uploaded successfully!" -ForegroundColor Green
        } catch {
            Write-Host "❌ Upload failed: $_" -ForegroundColor Red
        }
    }
    
    "2" {
        Write-Host "📦 Uploading source code..." -ForegroundColor Yellow
        try {
            scp -r src ${VPS_USER}@${VPS_IP}:${REMOTE_DIR}/
            scp pom.xml ${VPS_USER}@${VPS_IP}:${REMOTE_DIR}/
            Write-Host "✅ Source code uploaded successfully!" -ForegroundColor Green
        } catch {
            Write-Host "❌ Upload failed: $_" -ForegroundColor Red
        }
    }
    
    "3" {
        $filename = Read-Host "Enter filename to upload"
        if (Test-Path $filename) {
            Write-Host "📦 Uploading $filename..." -ForegroundColor Yellow
            try {
                scp $filename ${VPS_USER}@${VPS_IP}:${REMOTE_DIR}/
                Write-Host "✅ File uploaded successfully!" -ForegroundColor Green
            } catch {
                Write-Host "❌ Upload failed: $_" -ForegroundColor Red
            }
        } else {
            Write-Host "❌ File not found: $filename" -ForegroundColor Red
        }
    }
    
    "4" {
        Write-Host "🚀 Uploading and deploying..." -ForegroundColor Yellow
        
        # Create compressed package
        Write-Host "📦 Creating package..." -ForegroundColor Cyan
        tar -czf deployment.tar.gz --exclude='target' --exclude='*.log' --exclude='.git' .
        
        # Upload package
        Write-Host "📤 Uploading package..." -ForegroundColor Cyan
        scp deployment.tar.gz ${VPS_USER}@${VPS_IP}:/tmp/
        
        # Deploy on VPS
        Write-Host "🔧 Deploying on VPS..." -ForegroundColor Cyan
        $deployScript = @"
cd ${REMOTE_DIR}
tar -xzf /tmp/deployment.tar.gz
docker-compose down
docker-compose up --build -d
docker-compose ps
"@
        
        try {
            $deployScript | ssh ${VPS_USER}@${VPS_IP}
            Remove-Item deployment.tar.gz -ErrorAction SilentlyContinue
            Write-Host "✅ Upload and deployment completed!" -ForegroundColor Green
            Write-Host "🌐 Access: http://14.225.207.250" -ForegroundColor Cyan
        } catch {
            Write-Host "❌ Deployment failed: $_" -ForegroundColor Red
        }
    }
    
    default {
        Write-Host "❌ Invalid choice!" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "📝 Useful commands:" -ForegroundColor Yellow
Write-Host "- Connect to VPS: ssh root@14.225.207.250" -ForegroundColor White
Write-Host "- Check app status: ssh root@14.225.207.250 'cd /opt/wellcenter && docker-compose ps'" -ForegroundColor White
Write-Host "- View logs: ssh root@14.225.207.250 'cd /opt/wellcenter && docker-compose logs -f app'" -ForegroundColor White
