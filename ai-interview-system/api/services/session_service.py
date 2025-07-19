"""
Session management service for interview sessions
Handles session creation, progress tracking, and data persistence
"""

import asyncio
import logging
import uuid
import json
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
import aioredis
from dataclasses import dataclass, asdict

from ..models.schemas import InterviewSession, InterviewQuestion, AnswerEvaluationResponse

logger = logging.getLogger(__name__)

@dataclass
class SessionData:
    """Internal session data structure"""
    session_id: str
    candidate_name: str
    cv_text: str
    job_description: str
    position: str
    level: str
    status: str
    created_at: str
    expires_at: str
    questions_asked: int = 0
    questions_answered: int = 0
    questions: List[Dict] = None
    answers: List[Dict] = None
    
    def __post_init__(self):
        if self.questions is None:
            self.questions = []
        if self.answers is None:
            self.answers = []

class SessionService:
    """Service for managing interview sessions"""
    
    def __init__(self, redis_url: str = "redis://localhost:6379"):
        self.redis_url = redis_url
        self.redis = None
        self.sessions: Dict[str, SessionData] = {}  # In-memory fallback
        self.use_redis = True
        
    async def _get_redis(self):
        """Get Redis connection"""
        if not self.redis:
            try:
                self.redis = aioredis.from_url(self.redis_url, decode_responses=True)
                # Test connection
                await self.redis.ping()
                logger.info("✅ Connected to Redis")
            except Exception as e:
                logger.warning(f"Failed to connect to Redis: {str(e)}. Using in-memory storage.")
                self.use_redis = False
        return self.redis
    
    async def create_session(
        self,
        candidate_name: str,
        cv_text: str,
        job_description: str,
        position: str,
        level: str,
        duration_minutes: int = 30
    ) -> InterviewSession:
        """Create a new interview session"""
        
        session_id = str(uuid.uuid4())
        created_at = datetime.now()
        expires_at = created_at + timedelta(minutes=duration_minutes)
        
        session_data = SessionData(
            session_id=session_id,
            candidate_name=candidate_name,
            cv_text=cv_text,
            job_description=job_description,
            position=position,
            level=level,
            status="active",
            created_at=created_at.isoformat(),
            expires_at=expires_at.isoformat()
        )
        
        # Store session
        await self._store_session(session_data)
        
        # Return session model
        return InterviewSession(
            session_id=session_id,
            candidate_name=candidate_name,
            position=position,
            level=level,
            status="active",
            created_at=created_at.isoformat(),
            expires_at=expires_at.isoformat(),
            questions_asked=0,
            questions_answered=0
        )
    
    async def get_session(self, session_id: str) -> Optional[InterviewSession]:
        """Get session by ID"""
        session_data = await self._get_session_data(session_id)
        if not session_data:
            return None
        
        # Check if session expired
        expires_at = datetime.fromisoformat(session_data.expires_at)
        if datetime.now() > expires_at and session_data.status == "active":
            session_data.status = "expired"
            await self._store_session(session_data)
        
        return InterviewSession(
            session_id=session_data.session_id,
            candidate_name=session_data.candidate_name,
            position=session_data.position,
            level=session_data.level,
            status=session_data.status,
            created_at=session_data.created_at,
            expires_at=session_data.expires_at,
            questions_asked=session_data.questions_asked,
            questions_answered=session_data.questions_answered
        )
    
    async def add_question_to_session(self, session_id: str, question: InterviewQuestion) -> bool:
        """Add a question to the session"""
        session_data = await self._get_session_data(session_id)
        if not session_data:
            return False
        
        question_id = str(uuid.uuid4())
        question_data = {
            "question_id": question_id,
            "question": question.question,
            "category": question.category,
            "difficulty": question.difficulty,
            "skill_focus": question.skill_focus,
            "expected_keywords": question.expected_keywords,
            "evaluation_criteria": question.evaluation_criteria,
            "asked_at": datetime.now().isoformat()
        }
        
        session_data.questions.append(question_data)
        session_data.questions_asked += 1
        
        await self._store_session(session_data)
        return True
    
    async def get_question(self, session_id: str, question_id: str) -> Optional[InterviewQuestion]:
        """Get a specific question from session"""
        session_data = await self._get_session_data(session_id)
        if not session_data:
            return None
        
        for q in session_data.questions:
            if q["question_id"] == question_id:
                return InterviewQuestion(
                    question=q["question"],
                    category=q["category"],
                    difficulty=q["difficulty"],
                    skill_focus=q["skill_focus"],
                    expected_keywords=q["expected_keywords"],
                    evaluation_criteria=q["evaluation_criteria"]
                )
        
        return None
    
    async def store_answer(
        self,
        session_id: str,
        question_id: str,
        answer: str,
        evaluation: AnswerEvaluationResponse
    ) -> bool:
        """Store answer and evaluation for a question"""
        session_data = await self._get_session_data(session_id)
        if not session_data:
            return False
        
        answer_data = {
            "question_id": question_id,
            "answer": answer,
            "evaluation": {
                "scores": {
                    "technical_accuracy": evaluation.scores.technical_accuracy,
                    "completeness": evaluation.scores.completeness,
                    "clarity": evaluation.scores.clarity,
                    "keyword_coverage": evaluation.scores.keyword_coverage,
                    "overall_score": evaluation.scores.overall_score
                },
                "feedback": evaluation.feedback,
                "strengths": evaluation.strengths,
                "improvements": evaluation.improvements,
                "keyword_analysis": evaluation.keyword_analysis
            },
            "answered_at": datetime.now().isoformat()
        }
        
        session_data.answers.append(answer_data)
        session_data.questions_answered += 1
        
        await self._store_session(session_data)
        return True
    
    async def get_session_progress(self, session_id: str) -> Dict[str, Any]:
        """Get session progress summary"""
        session_data = await self._get_session_data(session_id)
        if not session_data:
            return {}
        
        # Calculate average scores
        total_scores = {
            "technical_accuracy": 0,
            "completeness": 0,
            "clarity": 0,
            "keyword_coverage": 0,
            "overall_score": 0
        }
        
        if session_data.answers:
            for answer in session_data.answers:
                eval_scores = answer["evaluation"]["scores"]
                for key in total_scores.keys():
                    total_scores[key] += eval_scores[key]
            
            # Calculate averages
            num_answers = len(session_data.answers)
            avg_scores = {key: score / num_answers for key, score in total_scores.items()}
        else:
            avg_scores = total_scores
        
        return {
            "questions_asked": session_data.questions_asked,
            "questions_answered": session_data.questions_answered,
            "average_scores": avg_scores,
            "session_status": session_data.status,
            "completion_percentage": (session_data.questions_answered / max(session_data.questions_asked, 1)) * 100
        }
    
    async def get_next_skill_focus(self, session_id: str, current_performance: float) -> str:
        """Determine next skill focus based on current performance"""
        session_data = await self._get_session_data(session_id)
        if not session_data:
            return "general"
        
        # Simple adaptive logic
        if current_performance >= 80:
            # Good performance - can ask harder questions
            skill_focuses = ["advanced concepts", "system design", "best practices"]
        elif current_performance >= 60:
            # Average performance - stay at similar level
            skill_focuses = ["core concepts", "practical application"]
        else:
            # Poor performance - ask easier questions
            skill_focuses = ["fundamentals", "basic concepts"]
        
        # Rotate through different focuses
        focus_index = session_data.questions_answered % len(skill_focuses)
        return skill_focuses[focus_index]
    
    async def complete_session(self, session_id: str) -> bool:
        """Mark session as complete"""
        session_data = await self._get_session_data(session_id)
        if not session_data:
            return False
        
        session_data.status = "completed"
        await self._store_session(session_data)
        return True
    
    async def end_session(self, session_id: str) -> bool:
        """End session (mark as ended)"""
        session_data = await self._get_session_data(session_id)
        if not session_data:
            return False
        
        session_data.status = "ended"
        await self._store_session(session_data)
        return True
    
    async def get_session_questions(self, session_id: str) -> List[Dict[str, Any]]:
        """Get all questions and answers for a session"""
        session_data = await self._get_session_data(session_id)
        if not session_data:
            return []
        
        # Combine questions with their answers
        questions_with_answers = []
        
        for question in session_data.questions:
            question_id = question["question_id"]
            
            # Find corresponding answer
            answer_data = None
            for answer in session_data.answers:
                if answer["question_id"] == question_id:
                    answer_data = answer
                    break
            
            questions_with_answers.append({
                "question": question,
                "answer": answer_data
            })
        
        return questions_with_answers
    
    async def _store_session(self, session_data: SessionData):
        """Store session data"""
        if self.use_redis:
            try:
                redis = await self._get_redis()
                if redis:
                    # Convert to JSON
                    session_json = json.dumps(asdict(session_data))
                    
                    # Store with expiration (24 hours)
                    await redis.setex(
                        f"session:{session_data.session_id}",
                        86400,  # 24 hours
                        session_json
                    )
                    return
            except Exception as e:
                logger.error(f"Failed to store session in Redis: {str(e)}")
                self.use_redis = False
        
        # Fallback to in-memory storage
        self.sessions[session_data.session_id] = session_data
    
    async def _get_session_data(self, session_id: str) -> Optional[SessionData]:
        """Get session data"""
        if self.use_redis:
            try:
                redis = await self._get_redis()
                if redis:
                    session_json = await redis.get(f"session:{session_id}")
                    if session_json:
                        session_dict = json.loads(session_json)
                        return SessionData(**session_dict)
            except Exception as e:
                logger.error(f"Failed to get session from Redis: {str(e)}")
                self.use_redis = False
        
        # Fallback to in-memory storage
        return self.sessions.get(session_id)
    
    async def cleanup_expired_sessions(self):
        """Cleanup expired sessions (background task)"""
        if self.use_redis:
            # Redis automatically expires keys, so nothing to do
            return
        
        # Clean up in-memory sessions
        now = datetime.now()
        expired_sessions = []
        
        for session_id, session_data in self.sessions.items():
            expires_at = datetime.fromisoformat(session_data.expires_at)
            if now > expires_at:
                expired_sessions.append(session_id)
        
        for session_id in expired_sessions:
            del self.sessions[session_id]
        
        if expired_sessions:
            logger.info(f"Cleaned up {len(expired_sessions)} expired sessions")