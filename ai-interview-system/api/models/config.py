"""
Configuration settings for the AI Interview API
"""

from pydantic import BaseSettings, Field
from typing import Optional
import os

class Settings(BaseSettings):
    """Application settings"""
    
    # API Configuration
    api_title: str = Field(default="AI Interview Training System", env="API_TITLE")
    api_version: str = Field(default="1.0.0", env="API_VERSION")
    debug: bool = Field(default=False, env="DEBUG")
    
    # Model Configuration
    model_path: str = Field(default="./models/ai-interview-model", env="MODEL_PATH")
    base_model_name: str = Field(default="Qwen/Qwen2.5-Coder-7B-Instruct", env="BASE_MODEL_NAME")
    max_new_tokens: int = Field(default=200, env="MAX_NEW_TOKENS")
    temperature: float = Field(default=0.7, env="TEMPERATURE")
    
    # Generation Configuration
    max_questions_per_request: int = Field(default=5, env="MAX_QUESTIONS_PER_REQUEST")
    default_timeout: int = Field(default=30, env="DEFAULT_TIMEOUT")
    
    # Session Configuration
    session_duration_minutes: int = Field(default=30, env="SESSION_DURATION_MINUTES")
    max_concurrent_sessions: int = Field(default=10, env="MAX_CONCURRENT_SESSIONS")
    
    # Database Configuration (for session storage)
    database_url: Optional[str] = Field(default=None, env="DATABASE_URL")
    redis_url: Optional[str] = Field(default="redis://localhost:6379", env="REDIS_URL")
    
    # Security Configuration
    api_key: Optional[str] = Field(default=None, env="API_KEY")
    cors_origins: str = Field(default="*", env="CORS_ORIGINS")
    
    # Logging Configuration
    log_level: str = Field(default="INFO", env="LOG_LEVEL")
    log_file: Optional[str] = Field(default=None, env="LOG_FILE")
    
    # Performance Configuration
    enable_caching: bool = Field(default=True, env="ENABLE_CACHING")
    cache_ttl: int = Field(default=3600, env="CACHE_TTL")  # 1 hour
    
    # Model Loading Configuration
    use_quantization: bool = Field(default=True, env="USE_QUANTIZATION")
    device: str = Field(default="auto", env="DEVICE")
    torch_dtype: str = Field(default="float16", env="TORCH_DTYPE")
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"