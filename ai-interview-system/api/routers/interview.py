"""
Interview question generation router
Handles interview question generation endpoints
"""

from fastapi import APIRouter, HTTPException, Depends, BackgroundTasks
from typing import List
import time
import logging
import asyncio

from ..models.schemas import (
    InterviewQuestionRequest,
    InterviewQuestionResponse,
    InterviewQuestion,
    InterviewSessionRequest,
    InterviewSessionResponse,
    SessionProgressRequest,
    SessionProgressResponse,
    ErrorResponse
)
from ..services.model_service import ModelService
from ..services.session_service import SessionService

router = APIRouter()
logger = logging.getLogger(__name__)

def get_model_service() -> ModelService:
    """Dependency to get model service"""
    from ..main import model_service
    if not model_service or not model_service.is_loaded:
        raise HTTPException(status_code=503, detail="Model service not available")
    return model_service

def get_session_service() -> SessionService:
    """Dependency to get session service"""
    return SessionService()

@router.post("/generate", response_model=InterviewQuestionResponse)
async def generate_interview_questions(
    request: InterviewQuestionRequest,
    model_service: ModelService = Depends(get_model_service)
):
    """
    Generate interview questions based on CV and job requirements
    
    This endpoint generates relevant interview questions by analyzing:
    - Candidate's CV text and experience level
    - Job description and requirements
    - Specified skill focus and category
    
    Returns a list of tailored interview questions with metadata.
    """
    try:
        start_time = time.time()
        
        logger.info(f"Generating {request.num_questions} questions for {request.position} ({request.level})")
        
        # Generate questions using the model service
        questions = await model_service.generate_questions(
            cv_text=request.cv_text,
            job_description=request.job_description,
            position=request.position,
            level=request.level.value,
            skill_focus=request.skill_focus,
            category=request.category.value if request.category else "technical",
            num_questions=request.num_questions
        )
        
        generation_time = time.time() - start_time
        
        # Create response
        response = InterviewQuestionResponse(
            questions=questions,
            metadata={
                "position": request.position,
                "level": request.level.value,
                "skill_focus": request.skill_focus,
                "category": request.category.value if request.category else "technical",
                "model_version": "qwen2.5-coder-7b-instruct-finetuned"
            },
            generation_time=generation_time
        )
        
        logger.info(f"Successfully generated {len(questions)} questions in {generation_time:.2f}s")
        return response
        
    except Exception as e:
        logger.error(f"Failed to generate questions: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Question generation failed: {str(e)}")

@router.post("/session/start", response_model=InterviewSessionResponse)
async def start_interview_session(
    request: InterviewSessionRequest,
    session_service: SessionService = Depends(get_session_service),
    model_service: ModelService = Depends(get_model_service)
):
    """
    Start a new interview session
    
    Creates a new interview session and generates the first question.
    The session tracks progress and maintains context throughout the interview.
    """
    try:
        logger.info(f"Starting interview session for {request.candidate_name} - {request.position}")
        
        # Create new session
        session = await session_service.create_session(
            candidate_name=request.candidate_name,
            cv_text=request.cv_text,
            job_description=request.job_description,
            position=request.position,
            level=request.level.value,
            duration_minutes=request.session_duration
        )
        
        # Generate first question
        questions = await model_service.generate_questions(
            cv_text=request.cv_text,
            job_description=request.job_description,
            position=request.position,
            level=request.level.value,
            skill_focus="general",  # Start with general questions
            category="technical",
            num_questions=1
        )
        
        first_question = questions[0] if questions else None
        if not first_question:
            raise HTTPException(status_code=500, detail="Failed to generate first question")
        
        # Store first question in session
        await session_service.add_question_to_session(session.session_id, first_question)
        
        response = InterviewSessionResponse(
            session=session,
            first_question=first_question
        )
        
        logger.info(f"Started session {session.session_id} for {request.candidate_name}")
        return response
        
    except Exception as e:
        logger.error(f"Failed to start session: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Session creation failed: {str(e)}")

@router.post("/session/progress", response_model=SessionProgressResponse)
async def submit_answer_and_continue(
    request: SessionProgressRequest,
    session_service: SessionService = Depends(get_session_service),
    model_service: ModelService = Depends(get_model_service)
):
    """
    Submit answer and get next question
    
    Evaluates the candidate's answer and generates the next question
    based on their performance and the session context.
    """
    try:
        logger.info(f"Processing answer for session {request.session_id}")
        
        # Get session
        session = await session_service.get_session(request.session_id)
        if not session:
            raise HTTPException(status_code=404, detail="Session not found")
        
        if session.status != "active":
            raise HTTPException(status_code=400, detail="Session is not active")
        
        # Get question details
        question_data = await session_service.get_question(request.session_id, request.question_id)
        if not question_data:
            raise HTTPException(status_code=404, detail="Question not found")
        
        # Evaluate answer
        evaluation = await model_service.evaluate_answer(
            question=question_data.question,
            answer=request.answer,
            expected_keywords=question_data.expected_keywords,
            skill_focus=question_data.skill_focus,
            difficulty=question_data.difficulty
        )
        
        # Store answer and evaluation
        await session_service.store_answer(
            session_id=request.session_id,
            question_id=request.question_id,
            answer=request.answer,
            evaluation=evaluation
        )
        
        # Check if session should continue
        session_progress = await session_service.get_session_progress(request.session_id)
        session_complete = session_progress["questions_answered"] >= 5  # Max 5 questions per session
        
        next_question = None
        if not session_complete:
            # Generate next question based on performance
            next_skill_focus = await session_service.get_next_skill_focus(
                session_id=request.session_id,
                current_performance=evaluation.scores.overall_score
            )
            
            questions = await model_service.generate_questions(
                cv_text=session.cv_text,
                job_description=session.job_description,
                position=session.position,
                level=session.level,
                skill_focus=next_skill_focus,
                category="technical",
                num_questions=1
            )
            
            if questions:
                next_question = questions[0]
                await session_service.add_question_to_session(session.session_id, next_question)
        else:
            # Mark session as complete
            await session_service.complete_session(request.session_id)
        
        response = SessionProgressResponse(
            evaluation=evaluation,
            next_question=next_question,
            session_complete=session_complete,
            overall_progress=session_progress
        )
        
        logger.info(f"Processed answer for session {request.session_id}. Complete: {session_complete}")
        return response
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to process session progress: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Session progress failed: {str(e)}")

@router.get("/session/{session_id}")
async def get_session_details(
    session_id: str,
    session_service: SessionService = Depends(get_session_service)
):
    """
    Get session details and progress
    """
    try:
        session = await session_service.get_session(session_id)
        if not session:
            raise HTTPException(status_code=404, detail="Session not found")
        
        progress = await session_service.get_session_progress(session_id)
        questions_history = await session_service.get_session_questions(session_id)
        
        return {
            "session": session,
            "progress": progress,
            "questions_history": questions_history
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to get session details: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get session: {str(e)}")

@router.delete("/session/{session_id}")
async def end_session(
    session_id: str,
    session_service: SessionService = Depends(get_session_service)
):
    """
    End an interview session
    """
    try:
        await session_service.end_session(session_id)
        return {"message": "Session ended successfully"}
        
    except Exception as e:
        logger.error(f"Failed to end session: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to end session: {str(e)}")

@router.get("/categories")
async def get_question_categories():
    """
    Get available question categories
    """
    from ..models.schemas import QuestionCategory
    
    categories = [
        {"value": cat.value, "label": cat.value.replace("_", " ").title()}
        for cat in QuestionCategory
    ]
    
    return {"categories": categories}

@router.get("/levels")
async def get_difficulty_levels():
    """
    Get available difficulty levels
    """
    from ..models.schemas import DifficultyLevel
    
    levels = [
        {"value": level.value, "label": level.value.title()}
        for level in DifficultyLevel
    ]
    
    return {"levels": levels}