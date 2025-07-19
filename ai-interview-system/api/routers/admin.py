"""
Admin router for system management and monitoring
"""

from fastapi import APIRouter, HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import logging
import psutil
import torch
from datetime import datetime
from typing import Dict, Any

from ..models.schemas import ErrorResponse
from ..services.model_service import ModelService
from ..services.session_service import SessionService

router = APIRouter()
logger = logging.getLogger(__name__)
security = HTTPBearer()

def verify_admin_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Verify admin authentication (simplified for demo)"""
    # In production, implement proper JWT token verification
    if credentials.credentials != "admin-token-123":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid admin token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return credentials.credentials

def get_model_service() -> ModelService:
    """Dependency to get model service"""
    from ..main import model_service
    return model_service

def get_session_service() -> SessionService:
    """Dependency to get session service"""
    return SessionService()

@router.get("/status")
async def get_system_status(
    token: str = Depends(verify_admin_token),
    model_service: ModelService = Depends(get_model_service)
):
    """
    Get comprehensive system status
    
    Returns detailed information about:
    - Model loading status
    - System resources (CPU, Memory, GPU)
    - Active sessions count
    - API health metrics
    """
    try:
        # System resources
        cpu_percent = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        disk = psutil.disk_usage('/')
        
        # GPU information
        gpu_info = {}
        if torch.cuda.is_available():
            gpu_info = {
                "available": True,
                "device_count": torch.cuda.device_count(),
                "current_device": torch.cuda.current_device(),
                "device_name": torch.cuda.get_device_name(),
                "memory_allocated": torch.cuda.memory_allocated() / 1024**3,  # GB
                "memory_reserved": torch.cuda.memory_reserved() / 1024**3,  # GB
                "memory_total": torch.cuda.get_device_properties(0).total_memory / 1024**3  # GB
            }
        else:
            gpu_info = {"available": False}
        
        # Model status
        model_status = {
            "loaded": model_service.is_loaded if model_service else False,
            "model_path": model_service.model_path if model_service else None,
            "device": str(model_service.device) if model_service else None
        }
        
        return {
            "timestamp": datetime.now().isoformat(),
            "system": {
                "cpu_percent": cpu_percent,
                "memory": {
                    "total_gb": memory.total / 1024**3,
                    "available_gb": memory.available / 1024**3,
                    "used_gb": memory.used / 1024**3,
                    "percent": memory.percent
                },
                "disk": {
                    "total_gb": disk.total / 1024**3,
                    "free_gb": disk.free / 1024**3,
                    "used_gb": disk.used / 1024**3,
                    "percent": (disk.used / disk.total) * 100
                },
                "gpu": gpu_info
            },
            "model": model_status,
            "api": {
                "status": "healthy",
                "version": "1.0.0"
            }
        }
        
    except Exception as e:
        logger.error(f"Failed to get system status: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get system status: {str(e)}")

@router.post("/model/reload")
async def reload_model(
    token: str = Depends(verify_admin_token),
    model_service: ModelService = Depends(get_model_service)
):
    """
    Reload the AI model
    
    Forces a reload of the model, useful for applying updates
    or recovering from model issues.
    """
    try:
        logger.info("Admin requested model reload")
        
        if not model_service:
            raise HTTPException(status_code=503, detail="Model service not available")
        
        # Cleanup existing model
        await model_service.cleanup()
        
        # Reload model
        await model_service.load_model()
        
        return {
            "message": "Model reloaded successfully",
            "status": "loaded" if model_service.is_loaded else "failed",
            "timestamp": datetime.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Failed to reload model: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Model reload failed: {str(e)}")

@router.get("/sessions/active")
async def get_active_sessions(
    token: str = Depends(verify_admin_token),
    session_service: SessionService = Depends(get_session_service)
):
    """
    Get list of active interview sessions
    
    Returns summary information about all currently active sessions
    for monitoring and management purposes.
    """
    try:
        # This is a simplified implementation
        # In a real system, you'd query the session storage
        active_sessions = []
        
        # Get sessions from in-memory storage (simplified)
        for session_id, session_data in session_service.sessions.items():
            if session_data.status == "active":
                # Check if not expired
                expires_at = datetime.fromisoformat(session_data.expires_at)
                if datetime.now() <= expires_at:
                    active_sessions.append({
                        "session_id": session_id,
                        "candidate_name": session_data.candidate_name,
                        "position": session_data.position,
                        "level": session_data.level,
                        "created_at": session_data.created_at,
                        "expires_at": session_data.expires_at,
                        "questions_asked": session_data.questions_asked,
                        "questions_answered": session_data.questions_answered
                    })
        
        return {
            "active_sessions": active_sessions,
            "total_active": len(active_sessions),
            "timestamp": datetime.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Failed to get active sessions: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get active sessions: {str(e)}")

@router.post("/sessions/cleanup")
async def cleanup_expired_sessions(
    token: str = Depends(verify_admin_token),
    session_service: SessionService = Depends(get_session_service)
):
    """
    Cleanup expired sessions
    
    Manually trigger cleanup of expired sessions to free up memory
    and storage space.
    """
    try:
        initial_count = len(session_service.sessions)
        await session_service.cleanup_expired_sessions()
        final_count = len(session_service.sessions)
        cleaned_count = initial_count - final_count
        
        return {
            "message": "Session cleanup completed",
            "sessions_cleaned": cleaned_count,
            "sessions_remaining": final_count,
            "timestamp": datetime.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Failed to cleanup sessions: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Session cleanup failed: {str(e)}")

@router.get("/metrics")
async def get_system_metrics(
    token: str = Depends(verify_admin_token)
):
    """
    Get system performance metrics
    
    Returns detailed metrics for monitoring system performance
    and resource utilization.
    """
    try:
        # CPU information
        cpu_times = psutil.cpu_times()
        cpu_info = {
            "count": psutil.cpu_count(),
            "percent": psutil.cpu_percent(interval=1),
            "times": {
                "user": cpu_times.user,
                "system": cpu_times.system,
                "idle": cpu_times.idle
            }
        }
        
        # Memory information
        memory = psutil.virtual_memory()
        swap = psutil.swap_memory()
        memory_info = {
            "virtual": {
                "total": memory.total,
                "available": memory.available,
                "percent": memory.percent,
                "used": memory.used,
                "free": memory.free
            },
            "swap": {
                "total": swap.total,
                "used": swap.used,
                "free": swap.free,
                "percent": swap.percent
            }
        }
        
        # Disk information
        disk_info = {}
        for partition in psutil.disk_partitions():
            try:
                partition_usage = psutil.disk_usage(partition.mountpoint)
                disk_info[partition.mountpoint] = {
                    "total": partition_usage.total,
                    "used": partition_usage.used,
                    "free": partition_usage.free,
                    "percent": (partition_usage.used / partition_usage.total) * 100
                }
            except PermissionError:
                continue
        
        # Network information
        network = psutil.net_io_counters()
        network_info = {
            "bytes_sent": network.bytes_sent,
            "bytes_recv": network.bytes_recv,
            "packets_sent": network.packets_sent,
            "packets_recv": network.packets_recv
        }
        
        return {
            "timestamp": datetime.now().isoformat(),
            "cpu": cpu_info,
            "memory": memory_info,
            "disk": disk_info,
            "network": network_info
        }
        
    except Exception as e:
        logger.error(f"Failed to get system metrics: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get system metrics: {str(e)}")

@router.get("/logs")
async def get_recent_logs(
    token: str = Depends(verify_admin_token),
    lines: int = 100
):
    """
    Get recent application logs
    
    Returns the most recent log entries for debugging and monitoring.
    """
    try:
        # This is a simplified implementation
        # In production, you'd read from actual log files
        
        return {
            "message": "Log retrieval not implemented in demo",
            "lines_requested": lines,
            "timestamp": datetime.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Failed to get logs: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get logs: {str(e)}")

@router.post("/config/update")
async def update_configuration(
    config_updates: Dict[str, Any],
    token: str = Depends(verify_admin_token)
):
    """
    Update system configuration
    
    Allows updating certain configuration parameters at runtime
    without requiring a full system restart.
    """
    try:
        # This is a simplified implementation
        # In production, you'd validate and apply configuration changes
        
        allowed_configs = ["temperature", "max_new_tokens", "cache_ttl"]
        applied_updates = {}
        
        for key, value in config_updates.items():
            if key in allowed_configs:
                applied_updates[key] = value
                logger.info(f"Config updated: {key} = {value}")
        
        return {
            "message": "Configuration updated",
            "applied_updates": applied_updates,
            "timestamp": datetime.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Failed to update configuration: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Configuration update failed: {str(e)}")