#!/bin/bash

# Environment Setup Script for AI Interview Training System
# This script sets up the development environment

set -e

echo "🚀 Setting up AI Interview Training System..."

# Check system requirements
check_requirements() {
    echo "📋 Checking system requirements..."
    
    # Check Python version
    if ! command -v python3 &> /dev/null; then
        echo "❌ Python 3.9+ is required"
        exit 1
    fi
    
    python_version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    if [[ $(echo "$python_version 3.9" | awk '{print ($1 >= $2)}') -eq 0 ]]; then
        echo "❌ Python 3.9+ is required (found $python_version)"
        exit 1
    fi
    echo "✅ Python $python_version found"
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker is required"
        exit 1
    fi
    echo "✅ Docker found"
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        echo "❌ Docker Compose is required"
        exit 1
    fi
    echo "✅ Docker Compose found"
    
    # Check available memory
    available_memory=$(free -m | awk 'NR==2{print $7}')
    if [ "$available_memory" -lt 8192 ]; then
        echo "⚠️  Warning: Available memory is ${available_memory}MB. Recommended: 8GB+"
    else
        echo "✅ Memory: ${available_memory}MB available"
    fi
}

# Setup Python environment
setup_python_env() {
    echo "🐍 Setting up Python environment..."
    
    cd ai-interview-system/api
    
    # Create virtual environment
    if [ ! -d "venv" ]; then
        python3 -m venv venv
        echo "✅ Virtual environment created"
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Upgrade pip
    pip install --upgrade pip
    
    # Install requirements
    echo "📦 Installing Python dependencies..."
    pip install -r requirements.txt
    
    echo "✅ Python environment setup complete"
    cd ../..
}

# Setup environment configuration
setup_env_config() {
    echo "⚙️  Setting up environment configuration..."
    
    # Create .env file for API
    if [ ! -f "ai-interview-system/api/.env" ]; then
        cat > ai-interview-system/api/.env << EOF
# API Configuration
API_TITLE="AI Interview Training System"
API_VERSION="1.0.0"
DEBUG=true
LOG_LEVEL=INFO

# Model Configuration
MODEL_PATH=./models/ai-interview-model
BASE_MODEL_NAME=Qwen/Qwen2.5-Coder-7B-Instruct
MAX_NEW_TOKENS=200
TEMPERATURE=0.7

# Generation Configuration
MAX_QUESTIONS_PER_REQUEST=5
DEFAULT_TIMEOUT=30

# Session Configuration
SESSION_DURATION_MINUTES=30
MAX_CONCURRENT_SESSIONS=10

# Database Configuration
DATABASE_URL=postgresql://ai_interview_user:secure_password_123@localhost:5432/ai_interview
REDIS_URL=redis://localhost:6379

# Security Configuration
API_KEY=dev-api-key-change-in-production
CORS_ORIGINS=http://localhost:3000,http://localhost:8080

# Performance Configuration
ENABLE_CACHING=true
CACHE_TTL=3600
USE_QUANTIZATION=true
DEVICE=auto
TORCH_DTYPE=float16
EOF
        echo "✅ Environment configuration created"
    else
        echo "✅ Environment configuration already exists"
    fi
}

# Setup Docker services
setup_docker_services() {
    echo "🐳 Setting up Docker services..."
    
    # Create Docker network
    docker network create ai-interview-network 2>/dev/null || echo "Network already exists"
    
    # Start Redis
    if [ ! "$(docker ps -q -f name=ai-interview-redis)" ]; then
        echo "🔴 Starting Redis..."
        docker run -d --name ai-interview-redis \
            --network ai-interview-network \
            -p 6379:6379 \
            redis:7-alpine redis-server --appendonly yes
        echo "✅ Redis started"
    else
        echo "✅ Redis already running"
    fi
    
    # Start PostgreSQL
    if [ ! "$(docker ps -q -f name=ai-interview-postgres)" ]; then
        echo "🐘 Starting PostgreSQL..."
        docker run -d --name ai-interview-postgres \
            --network ai-interview-network \
            -e POSTGRES_DB=ai_interview \
            -e POSTGRES_USER=ai_interview_user \
            -e POSTGRES_PASSWORD=secure_password_123 \
            -p 5432:5432 \
            postgres:15-alpine
        
        # Wait for PostgreSQL to start
        echo "⏳ Waiting for PostgreSQL to start..."
        sleep 10
        echo "✅ PostgreSQL started"
    else
        echo "✅ PostgreSQL already running"
    fi
}

# Setup model directory
setup_model_directory() {
    echo "🤖 Setting up model directory..."
    
    mkdir -p ai-interview-system/api/models
    
    if [ ! -d "ai-interview-system/api/models/ai-interview-model" ]; then
        echo "📁 Model directory created at ai-interview-system/api/models/"
        echo "📝 Place your trained model files in this directory:"
        echo "   - adapter_config.json"
        echo "   - adapter_model.bin"
        echo "   - tokenizer files"
        echo ""
        echo "💡 Follow the Kaggle training guide to train your model first"
    else
        echo "✅ Model directory already exists"
    fi
}

# Create development scripts
create_dev_scripts() {
    echo "📝 Creating development scripts..."
    
    # Start development server script
    cat > start_dev.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting AI Interview API development server..."

cd ai-interview-system/api
source venv/bin/activate

# Check if model exists
if [ ! -d "models/ai-interview-model" ]; then
    echo "⚠️  Warning: Model not found. API will start but model endpoints will return 503"
    echo "📝 Train your model first using the Kaggle notebook"
fi

# Start the API server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
EOF

    chmod +x start_dev.sh
    
    # Stop services script
    cat > stop_services.sh << 'EOF'
#!/bin/bash
echo "🛑 Stopping AI Interview services..."

# Stop Docker containers
docker stop ai-interview-redis ai-interview-postgres 2>/dev/null || true

echo "✅ Services stopped"
EOF

    chmod +x stop_services.sh
    
    # Health check script
    cat > health_check.sh << 'EOF'
#!/bin/bash
echo "🔍 Checking AI Interview system health..."

# Check Redis
if docker ps | grep -q ai-interview-redis; then
    echo "✅ Redis: Running"
else
    echo "❌ Redis: Not running"
fi

# Check PostgreSQL
if docker ps | grep -q ai-interview-postgres; then
    echo "✅ PostgreSQL: Running"
else
    echo "❌ PostgreSQL: Not running"
fi

# Check API
if curl -s http://localhost:8000/health > /dev/null 2>&1; then
    api_status=$(curl -s http://localhost:8000/health | python3 -c "import sys, json; print(json.load(sys.stdin)['status'])")
    model_status=$(curl -s http://localhost:8000/health | python3 -c "import sys, json; print(json.load(sys.stdin)['model_status'])")
    echo "✅ API: $api_status"
    echo "🤖 Model: $model_status"
else
    echo "❌ API: Not running"
fi
EOF

    chmod +x health_check.sh
    
    echo "✅ Development scripts created"
}

# Test installation
test_installation() {
    echo "🧪 Testing installation..."
    
    # Test API import
    cd ai-interview-system/api
    source venv/bin/activate
    
    python3 -c "
try:
    from main import app
    print('✅ API imports successfully')
except ImportError as e:
    print(f'❌ API import failed: {e}')
    exit(1)
"
    
    cd ../..
    
    # Test Docker services
    if docker ps | grep -q ai-interview-redis && docker ps | grep -q ai-interview-postgres; then
        echo "✅ Docker services running"
    else
        echo "❌ Docker services not running"
    fi
}

# Display setup completion
show_completion() {
    echo ""
    echo "🎉 AI Interview Training System setup complete!"
    echo ""
    echo "📝 Next steps:"
    echo "1. Train your model using the Kaggle notebook:"
    echo "   📓 ai-interview-system/kaggle/ai_interview_training.ipynb"
    echo ""
    echo "2. Download and place the trained model in:"
    echo "   📁 ai-interview-system/api/models/ai-interview-model/"
    echo ""
    echo "3. Start the development server:"
    echo "   🚀 ./start_dev.sh"
    echo ""
    echo "4. Access the API documentation:"
    echo "   📖 http://localhost:8000/docs"
    echo ""
    echo "5. Check system health:"
    echo "   🔍 ./health_check.sh"
    echo ""
    echo "📚 Documentation:"
    echo "   - Kaggle Training Guide: ai-interview-system/docs/kaggle_training_guide.md"
    echo "   - API Documentation: ai-interview-system/docs/api_documentation.md"
    echo "   - Deployment Guide: ai-interview-system/docs/deployment_guide.md"
    echo ""
    echo "🆘 Need help? Check the troubleshooting section in the deployment guide"
    echo ""
}

# Main execution
main() {
    echo "AI Interview Training System Setup"
    echo "=================================="
    echo ""
    
    check_requirements
    setup_python_env
    setup_env_config
    setup_docker_services
    setup_model_directory
    create_dev_scripts
    test_installation
    show_completion
}

# Run main function
main "$@"