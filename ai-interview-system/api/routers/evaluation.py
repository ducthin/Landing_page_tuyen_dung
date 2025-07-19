"""
Answer evaluation router
Handles answer evaluation endpoints
"""

from fastapi import APIRouter, HTTPException, Depends
import logging
import time

from ..models.schemas import (
    AnswerEvaluationRequest,
    AnswerEvaluationResponse,
    ErrorResponse
)
from ..services.model_service import ModelService

router = APIRouter()
logger = logging.getLogger(__name__)

def get_model_service() -> ModelService:
    """Dependency to get model service"""
    from ..main import model_service
    if not model_service or not model_service.is_loaded:
        raise HTTPException(status_code=503, detail="Model service not available")
    return model_service

@router.post("/evaluate", response_model=AnswerEvaluationResponse)
async def evaluate_answer(
    request: AnswerEvaluationRequest,
    model_service: ModelService = Depends(get_model_service)
):
    """
    Evaluate an interview answer
    
    This endpoint evaluates the quality of an interview answer by analyzing:
    - Technical accuracy and completeness
    - Clarity and structure of explanation
    - Coverage of expected keywords
    - Appropriateness for the difficulty level
    
    Returns detailed scores, feedback, and improvement suggestions.
    """
    try:
        logger.info(f"Evaluating answer for {request.skill_focus} ({request.difficulty})")
        
        # Evaluate the answer using the model service
        evaluation = await model_service.evaluate_answer(
            question=request.question,
            answer=request.answer,
            expected_keywords=request.expected_keywords,
            skill_focus=request.skill_focus,
            difficulty=request.difficulty.value
        )
        
        logger.info(f"Answer evaluated. Overall score: {evaluation.scores.overall_score:.1f}")
        return evaluation
        
    except Exception as e:
        logger.error(f"Failed to evaluate answer: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Answer evaluation failed: {str(e)}")

@router.post("/bulk-evaluate")
async def bulk_evaluate_answers(
    requests: list[AnswerEvaluationRequest],
    model_service: ModelService = Depends(get_model_service)
):
    """
    Evaluate multiple answers in batch
    
    Useful for evaluating multiple answers from the same session
    or for batch processing of evaluation requests.
    """
    try:
        if len(requests) > 10:
            raise HTTPException(status_code=400, detail="Maximum 10 answers per batch")
        
        logger.info(f"Bulk evaluating {len(requests)} answers")
        
        evaluations = []
        for i, request in enumerate(requests):
            try:
                evaluation = await model_service.evaluate_answer(
                    question=request.question,
                    answer=request.answer,
                    expected_keywords=request.expected_keywords,
                    skill_focus=request.skill_focus,
                    difficulty=request.difficulty.value
                )
                evaluations.append({
                    "index": i,
                    "evaluation": evaluation,
                    "success": True
                })
            except Exception as e:
                logger.error(f"Failed to evaluate answer {i}: {str(e)}")
                evaluations.append({
                    "index": i,
                    "error": str(e),
                    "success": False
                })
        
        return {
            "evaluations": evaluations,
            "total_processed": len(evaluations),
            "successful": sum(1 for e in evaluations if e["success"]),
            "failed": sum(1 for e in evaluations if not e["success"])
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Bulk evaluation failed: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Bulk evaluation failed: {str(e)}")

@router.get("/evaluation-criteria/{level}")
async def get_evaluation_criteria(level: str):
    """
    Get evaluation criteria for a specific level
    
    Returns the criteria used to evaluate answers for junior, mid, or senior levels.
    """
    criteria_map = {
        "junior": [
            "Basic concept understanding",
            "Clarity of explanation",
            "Learning approach",
            "Fundamental knowledge"
        ],
        "mid": [
            "Technical accuracy",
            "Understanding of concepts", 
            "Practical application knowledge",
            "Problem-solving approach",
            "Completeness of answer"
        ],
        "senior": [
            "Technical accuracy",
            "Best practices knowledge",
            "Real-world experience examples",
            "Problem-solving approach",
            "Completeness of answer",
            "System design considerations",
            "Performance and scalability awareness"
        ]
    }
    
    if level not in criteria_map:
        raise HTTPException(status_code=400, detail="Invalid level. Must be junior, mid, or senior")
    
    return {
        "level": level,
        "criteria": criteria_map[level],
        "description": f"Evaluation criteria for {level} level candidates"
    }

@router.get("/keyword-suggestions/{skill_focus}")
async def get_keyword_suggestions(skill_focus: str):
    """
    Get keyword suggestions for a specific skill focus
    
    Returns common keywords that evaluators look for when assessing
    answers related to the specified technology or skill area.
    """
    keyword_map = {
        "python": ["python", "django", "flask", "fastapi", "pandas", "numpy", "pip", "virtual environment"],
        "javascript": ["javascript", "node.js", "react", "vue", "angular", "npm", "async/await", "promises"],
        "java": ["java", "spring", "hibernate", "maven", "junit", "jvm", "garbage collection"],
        "react": ["components", "jsx", "props", "state", "hooks", "virtual dom", "lifecycle"],
        "django": ["models", "views", "templates", "orm", "migrations", "middleware", "urls"],
        "aws": ["ec2", "s3", "lambda", "cloudformation", "vpc", "iam", "security groups"],
        "docker": ["containers", "dockerfile", "images", "volumes", "networking", "compose"],
        "kubernetes": ["pods", "services", "deployments", "configmaps", "secrets", "ingress"],
        "database": ["sql", "indexes", "normalization", "transactions", "acid", "joins"],
        "system_design": ["scalability", "load balancing", "caching", "microservices", "api design"]
    }
    
    skill_lower = skill_focus.lower()
    suggested_keywords = []
    
    # Find exact match first
    if skill_lower in keyword_map:
        suggested_keywords = keyword_map[skill_lower]
    else:
        # Find partial matches
        for skill, keywords in keyword_map.items():
            if skill in skill_lower or skill_lower in skill:
                suggested_keywords.extend(keywords)
        
        # Remove duplicates
        suggested_keywords = list(set(suggested_keywords))
    
    if not suggested_keywords:
        suggested_keywords = ["technical accuracy", "best practices", "problem solving"]
    
    return {
        "skill_focus": skill_focus,
        "suggested_keywords": suggested_keywords[:10],  # Limit to 10 keywords
        "description": f"Commonly expected keywords for {skill_focus} related questions"
    }