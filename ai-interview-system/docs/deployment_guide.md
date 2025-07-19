# Deployment Guide - AI Interview Training System

## Overview

This guide covers the complete deployment process for the AI Interview Training System, from development setup to production deployment with Docker.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Development Setup](#local-development-setup)
3. [Model Preparation](#model-preparation)
4. [Docker Deployment](#docker-deployment)
5. [Production Configuration](#production-configuration)
6. [Integration with Spring Boot App](#integration-with-spring-boot-app)
7. [Monitoring and Maintenance](#monitoring-and-maintenance)
8. [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements

**Minimum:**
- CPU: 4 cores
- RAM: 16GB 
- Storage: 50GB available
- GPU: 8GB VRAM (recommended)

**Recommended:**
- CPU: 8+ cores
- RAM: 32GB+
- Storage: 100GB+ SSD
- GPU: 16GB+ VRAM (RTX 4090, V100, etc.)

### Software Requirements

- Docker 24.0+
- Docker Compose 2.0+
- Python 3.9+ (for local development)
- Node.js 18+ (for frontend)
- Git

### Network Requirements

- Internet access for model download
- Ports 8000, 3000, 6379, 5432 available
- SSL certificate (for production)

## Local Development Setup

### 1. Clone Repository

```bash
git clone https://github.com/your-repo/Landing_page_tuyen_dung.git
cd Landing_page_tuyen_dung/ai-interview-system
```

### 2. Setup Python Environment

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
cd api
pip install -r requirements.txt
```

### 3. Environment Configuration

Create `.env` file in `api/` directory:

```bash
# API Configuration
API_TITLE="AI Interview Training System"
DEBUG=true
LOG_LEVEL=INFO

# Model Configuration
MODEL_PATH=./models/ai-interview-model
BASE_MODEL_NAME=Qwen/Qwen2.5-Coder-7B-Instruct
MAX_NEW_TOKENS=200
TEMPERATURE=0.7

# Database Configuration
DATABASE_URL=postgresql://ai_interview_user:password@localhost:5432/ai_interview
REDIS_URL=redis://localhost:6379

# Security
API_KEY=your-secret-api-key-here
CORS_ORIGINS=http://localhost:3000,http://localhost:8080

# Performance
ENABLE_CACHING=true
CACHE_TTL=3600
USE_QUANTIZATION=true
```

### 4. Start Development Services

```bash
# Start Redis
docker run -d --name redis -p 6379:6379 redis:7-alpine

# Start PostgreSQL
docker run -d --name postgres \
  -e POSTGRES_DB=ai_interview \
  -e POSTGRES_USER=ai_interview_user \
  -e POSTGRES_PASSWORD=password \
  -p 5432:5432 postgres:15-alpine

# Start API server
cd api
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 5. Verify Setup

```bash
# Check API health
curl http://localhost:8000/health

# Expected response:
# {"status":"healthy","model_status":"not_loaded","version":"1.0.0"}
```

## Model Preparation

### 1. Download Trained Model

After training on Kaggle, download the model:

```bash
# Create models directory
mkdir -p api/models

# Extract trained model
cd api/models
unzip ai_interview_model_deployment.zip
```

### 2. Verify Model Files

```bash
ls -la ai-interview-model/
# Should contain:
# - adapter_config.json
# - adapter_model.bin
# - tokenizer.json
# - tokenizer_config.json
# - special_tokens_map.json
```

### 3. Test Model Loading

```bash
# Start API with model
cd api
python -c "
from services.model_service import ModelService
import asyncio

async def test():
    service = ModelService('./models/ai-interview-model')
    await service.load_model()
    print('✅ Model loaded successfully!')

asyncio.run(test())
"
```

## Docker Deployment

### 1. Build Docker Images

```bash
# Build API image
cd ai-interview-system
docker build -f docker/Dockerfile.api -t ai-interview-api:latest ./api

# Build frontend image (if separate)
docker build -f docker/Dockerfile.frontend -t ai-interview-frontend:latest ./frontend
```

### 2. Start with Docker Compose

```bash
# Copy model to volume
docker volume create model_data
docker run --rm -v model_data:/models \
  -v $(pwd)/api/models:/source alpine \
  cp -r /source/ai-interview-model /models/

# Start all services
docker-compose -f docker/docker-compose.yml up -d
```

### 3. Verify Docker Deployment

```bash
# Check container status
docker-compose ps

# Check API health
curl http://localhost:8000/health

# Check logs
docker-compose logs ai-interview-api
```

## Production Configuration

### 1. Environment Variables

Create production `.env` file:

```bash
# Production API Configuration
API_TITLE="AI Interview Training System"
DEBUG=false
LOG_LEVEL=WARNING

# Model Configuration
MODEL_PATH=/app/models/ai-interview-model
USE_QUANTIZATION=true
DEVICE=auto

# Database Configuration
DATABASE_URL=postgresql://user:password@db:5432/ai_interview
REDIS_URL=redis://redis:6379

# Security
API_KEY=your-production-api-key-very-secure
CORS_ORIGINS=https://your-domain.com

# Performance
ENABLE_CACHING=true
CACHE_TTL=3600
MAX_CONCURRENT_SESSIONS=50

# Monitoring
LOG_FILE=/app/logs/api.log
```

### 2. SSL Configuration

```bash
# Generate SSL certificate
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/private.key -out ssl/certificate.crt

# Update nginx.conf for HTTPS
```

### 3. Production Docker Compose

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.prod.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - ai-interview-api

  ai-interview-api:
    image: ai-interview-api:latest
    environment:
      - DEBUG=false
      - LOG_LEVEL=WARNING
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 8G
        reservations:
          memory: 4G
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### 4. Database Migration

```bash
# Run database migrations
docker-compose exec ai-interview-api python -c "
from sqlalchemy import create_engine
from models.database import Base
import os

engine = create_engine(os.getenv('DATABASE_URL'))
Base.metadata.create_all(engine)
print('✅ Database initialized')
"
```

## Integration with Spring Boot App

### 1. Add AI Interview Service to Spring Boot

Create `AIInterviewService.java`:

```java
@Service
public class AIInterviewService {
    
    @Value("${ai.interview.api.url:http://localhost:8000}")
    private String aiApiUrl;
    
    private final RestTemplate restTemplate;
    
    public AIInterviewService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }
    
    public InterviewSessionResponse startInterview(InterviewRequest request) {
        String url = aiApiUrl + "/api/v1/interview/session/start";
        return restTemplate.postForObject(url, request, InterviewSessionResponse.class);
    }
    
    public AnswerEvaluationResponse submitAnswer(AnswerRequest request) {
        String url = aiApiUrl + "/api/v1/interview/session/progress";
        return restTemplate.postForObject(url, request, AnswerEvaluationResponse.class);
    }
}
```

### 2. Add Interview Controller

```java
@Controller
@RequestMapping("/interview")
public class InterviewController {
    
    @Autowired
    private AIInterviewService aiInterviewService;
    
    @GetMapping("/start")
    public String showInterviewStart(Model model) {
        model.addAttribute("interviewRequest", new InterviewRequest());
        return "interview/start";
    }
    
    @PostMapping("/start")
    public String startInterview(@ModelAttribute InterviewRequest request, 
                               RedirectAttributes redirectAttributes) {
        try {
            InterviewSessionResponse response = aiInterviewService.startInterview(request);
            redirectAttributes.addFlashAttribute("session", response);
            return "redirect:/interview/session";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Failed to start interview");
            return "redirect:/interview/start";
        }
    }
    
    @GetMapping("/session")
    public String showInterviewSession() {
        return "interview/session";
    }
}
```

### 3. Add Frontend Integration

In your existing Thymeleaf template, add:

```html
<!-- interview/start.html -->
<div id="ai-interview-root"></div>

<script>
// Initialize React component
const InterviewApp = React.createElement(InterviewInterface, {
    apiUrl: '/api/ai-interview',
    onComplete: function(results) {
        // Handle interview completion
        window.location.href = '/interview/results';
    }
});

ReactDOM.render(InterviewApp, document.getElementById('ai-interview-root'));
</script>
```

### 4. Proxy API Calls

Add to `application.properties`:

```properties
# AI Interview API configuration
ai.interview.api.url=http://ai-interview-api:8000
ai.interview.enabled=true
```

Create API proxy controller:

```java
@RestController
@RequestMapping("/api/ai-interview")
public class AIInterviewProxyController {
    
    @Autowired
    private AIInterviewService aiInterviewService;
    
    @PostMapping("/**")
    public ResponseEntity<?> proxyPost(HttpServletRequest request, 
                                     @RequestBody String body) {
        // Forward requests to AI Interview API
        String path = request.getRequestURI().substring("/api/ai-interview".length());
        return aiInterviewService.forwardRequest("POST", path, body);
    }
}
```

## Monitoring and Maintenance

### 1. Health Checks

```bash
#!/bin/bash
# healthcheck.sh

# Check API health
api_health=$(curl -s http://localhost:8000/health | jq -r '.status')
if [ "$api_health" != "healthy" ]; then
    echo "❌ API unhealthy"
    exit 1
fi

# Check model status
model_status=$(curl -s http://localhost:8000/health | jq -r '.model_status')
if [ "$model_status" != "loaded" ]; then
    echo "❌ Model not loaded"
    exit 1
fi

echo "✅ All systems healthy"
```

### 2. Log Monitoring

```bash
# Monitor API logs
docker-compose logs -f ai-interview-api

# Monitor system resources
docker stats

# Check disk usage
df -h
```

### 3. Performance Monitoring

```bash
# Monitor GPU usage (if available)
nvidia-smi

# Monitor memory usage
free -h

# Monitor API response times
curl -w "@curl-format.txt" -s -o /dev/null http://localhost:8000/health
```

### 4. Backup Procedures

```bash
#!/bin/bash
# backup.sh

# Backup database
docker-compose exec postgres pg_dump -U ai_interview_user ai_interview > backup_$(date +%Y%m%d).sql

# Backup model files
tar -czf model_backup_$(date +%Y%m%d).tar.gz api/models/

# Backup configuration
tar -czf config_backup_$(date +%Y%m%d).tar.gz docker/ api/.env
```

## Troubleshooting

### Common Issues

#### 1. Model Loading Errors

```bash
# Check model files
ls -la api/models/ai-interview-model/

# Check logs
docker-compose logs ai-interview-api | grep -i error

# Verify model path
docker-compose exec ai-interview-api ls -la /app/models/
```

#### 2. Memory Issues

```bash
# Monitor memory usage
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Reduce model size by enabling quantization
# In .env:
USE_QUANTIZATION=true
```

#### 3. Performance Issues

```bash
# Check GPU usage
nvidia-smi

# Monitor API response times
curl -w "Time: %{time_total}s\n" http://localhost:8000/health

# Scale API containers
docker-compose up -d --scale ai-interview-api=3
```

#### 4. Connection Issues

```bash
# Check network connectivity
docker network ls
docker network inspect ai-interview-network

# Test API connectivity
curl -v http://localhost:8000/health

# Check firewall rules
sudo ufw status
```

### Performance Tuning

#### 1. API Optimization

```python
# In api/models/config.py
class Settings(BaseSettings):
    # Increase worker processes
    workers: int = Field(default=4, env="WORKERS")
    
    # Enable caching
    enable_caching: bool = Field(default=True, env="ENABLE_CACHING")
    cache_ttl: int = Field(default=3600, env="CACHE_TTL")
    
    # Optimize model settings
    max_new_tokens: int = Field(default=150, env="MAX_NEW_TOKENS")  # Reduce for speed
    temperature: float = Field(default=0.7, env="TEMPERATURE")
```

#### 2. Database Optimization

```sql
-- Create indexes for better performance
CREATE INDEX idx_sessions_status ON interview_sessions(status);
CREATE INDEX idx_sessions_created_at ON interview_sessions(created_at);
CREATE INDEX idx_answers_session_id ON interview_answers(session_id);
```

#### 3. Nginx Optimization

```nginx
# nginx.conf
worker_processes auto;
worker_connections 1024;

http {
    # Enable compression
    gzip on;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript;
    
    # Connection pooling
    upstream api_backend {
        least_conn;
        server ai-interview-api-1:8000;
        server ai-interview-api-2:8000;
        keepalive 32;
    }
    
    # Caching
    proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=api_cache:10m max_size=1g;
}
```

### Security Considerations

#### 1. API Security

```python
# Enable rate limiting
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

@app.post("/api/v1/interview/generate")
@limiter.limit("10/minute")
async def generate_questions(request: Request, ...):
    pass
```

#### 2. Network Security

```bash
# Configure firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

#### 3. Container Security

```dockerfile
# In Dockerfile.api
FROM python:3.9-slim

# Create non-root user
RUN useradd --create-home --shell /bin/bash app
USER app

# Security headers
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
```

## Scaling Considerations

### Horizontal Scaling

```yaml
# docker-compose.scale.yml
services:
  ai-interview-api:
    deploy:
      replicas: 3
    environment:
      - WORKERS=2
      
  nginx:
    depends_on:
      - ai-interview-api
    volumes:
      - ./nginx.scale.conf:/etc/nginx/nginx.conf
```

### Load Balancing

```nginx
# nginx.scale.conf
upstream api_cluster {
    least_conn;
    server ai-interview-api-1:8000 max_fails=3 fail_timeout=30s;
    server ai-interview-api-2:8000 max_fails=3 fail_timeout=30s;
    server ai-interview-api-3:8000 max_fails=3 fail_timeout=30s;
}
```

### Resource Monitoring

```bash
# Set up monitoring alerts
docker run -d --name monitoring \
  -p 9090:9090 \
  -v ./prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus

# Monitor with Grafana
docker run -d --name grafana \
  -p 3001:3000 \
  grafana/grafana
```

## Maintenance Schedule

### Daily Tasks
- Check system health
- Monitor resource usage
- Review error logs

### Weekly Tasks
- Update security patches
- Backup configuration
- Performance review

### Monthly Tasks
- Full system backup
- Security audit
- Capacity planning review

### Quarterly Tasks
- Model retraining
- Security penetration testing
- Disaster recovery testing

---

**Deployment Complete! 🚀**

Your AI Interview Training System is now ready for production use. Monitor the system regularly and follow the maintenance schedule for optimal performance.