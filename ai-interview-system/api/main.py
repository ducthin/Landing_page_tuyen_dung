"""
Main FastAPI application for AI Interview Training System
Serves the fine-tuned Qwen model for interview question generation
"""

from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import logging
import uvicorn
from typing import Optional
import os

from .routers import interview, evaluation, admin
from .services.model_service import ModelService
from .models.config import Settings

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Global model service instance
model_service: Optional[ModelService] = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage application lifespan - load model on startup"""
    global model_service
    
    logger.info("Starting AI Interview API service...")
    
    # Load settings
    settings = Settings()
    
    # Initialize model service
    try:
        model_service = ModelService(settings.model_path)
        await model_service.load_model()
        logger.info("✅ Model loaded successfully")
    except Exception as e:
        logger.error(f"❌ Failed to load model: {str(e)}")
        raise
    
    # Store model service in app state
    app.state.model_service = model_service
    
    yield
    
    # Cleanup
    logger.info("Shutting down AI Interview API service...")
    if model_service:
        await model_service.cleanup()

# Create FastAPI app
app = FastAPI(
    title="AI Interview Training System",
    description="AI-powered interview question generation and evaluation system",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this properly in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(interview.router, prefix="/api/v1/interview", tags=["Interview"])
app.include_router(evaluation.router, prefix="/api/v1/evaluation", tags=["Evaluation"])
app.include_router(admin.router, prefix="/api/v1/admin", tags=["Admin"])

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "AI Interview Training System API",
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs"
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    try:
        model_status = "loaded" if model_service and model_service.is_loaded else "not_loaded"
        return {
            "status": "healthy",
            "model_status": model_status,
            "version": "1.0.0"
        }
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        raise HTTPException(status_code=500, detail="Service unhealthy")

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )