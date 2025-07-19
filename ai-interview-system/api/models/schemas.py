"""
Pydantic models for API request/response schemas
"""

from pydantic import BaseModel, Field, validator
from typing import List, Optional, Dict, Any
from enum import Enum

class DifficultyLevel(str, Enum):
    """Difficulty levels for interview questions"""
    JUNIOR = "junior"
    MID = "mid"
    SENIOR = "senior"

class QuestionCategory(str, Enum):
    """Categories for interview questions"""
    TECHNICAL = "technical"
    SYSTEM_DESIGN = "system_design"
    PERFORMANCE = "performance"
    SECURITY = "security"
    BEST_PRACTICES = "best_practices"
    PROBLEM_SOLVING = "problem_solving"
    ML_THEORY = "ml_theory"
    MLOPS = "mlops"
    STATISTICS = "statistics"
    EXPERIMENTATION = "experimentation"
    TESTING_STRATEGY = "testing_strategy"
    TROUBLESHOOTING = "troubleshooting"
    PRODUCT_STRATEGY = "product_strategy"
    LEADERSHIP = "leadership"
    ML_ENGINEERING = "ml_engineering"
    MONITORING = "monitoring"

class InterviewQuestionRequest(BaseModel):
    """Request model for generating interview questions"""
    cv_text: str = Field(..., description="Candidate's CV text", min_length=50, max_length=5000)
    job_description: str = Field(..., description="Job description and requirements", min_length=30, max_length=2000)
    position: str = Field(..., description="Job position title", min_length=5, max_length=100)
    level: DifficultyLevel = Field(..., description="Experience level")
    skill_focus: str = Field(..., description="Primary skill/technology focus", min_length=2, max_length=50)
    category: Optional[QuestionCategory] = Field(default=QuestionCategory.TECHNICAL, description="Question category")
    num_questions: int = Field(default=1, description="Number of questions to generate", ge=1, le=5)
    
    @validator('cv_text')
    def validate_cv_text(cls, v):
        if not v.strip():
            raise ValueError('CV text cannot be empty')
        return v.strip()
    
    @validator('job_description')
    def validate_job_description(cls, v):
        if not v.strip():
            raise ValueError('Job description cannot be empty')
        return v.strip()

class InterviewQuestion(BaseModel):
    """Generated interview question"""
    question: str = Field(..., description="The generated interview question")
    category: QuestionCategory = Field(..., description="Question category")
    difficulty: DifficultyLevel = Field(..., description="Question difficulty level")
    skill_focus: str = Field(..., description="Primary skill focus")
    expected_keywords: List[str] = Field(default=[], description="Expected keywords in answer")
    evaluation_criteria: List[str] = Field(default=[], description="Evaluation criteria")

class InterviewQuestionResponse(BaseModel):
    """Response model for generated interview questions"""
    questions: List[InterviewQuestion] = Field(..., description="Generated interview questions")
    metadata: Dict[str, Any] = Field(default={}, description="Generation metadata")
    generation_time: float = Field(..., description="Time taken to generate questions (seconds)")

class AnswerEvaluationRequest(BaseModel):
    """Request model for evaluating interview answers"""
    question: str = Field(..., description="Interview question", min_length=10, max_length=1000)
    answer: str = Field(..., description="Candidate's answer", min_length=10, max_length=5000)
    expected_keywords: List[str] = Field(default=[], description="Expected keywords")
    skill_focus: str = Field(..., description="Primary skill focus", min_length=2, max_length=50)
    difficulty: DifficultyLevel = Field(..., description="Question difficulty level")
    
    @validator('answer')
    def validate_answer(cls, v):
        if not v.strip():
            raise ValueError('Answer cannot be empty')
        return v.strip()

class EvaluationScore(BaseModel):
    """Evaluation score for different aspects"""
    technical_accuracy: float = Field(..., description="Technical accuracy score (0-100)", ge=0, le=100)
    completeness: float = Field(..., description="Answer completeness score (0-100)", ge=0, le=100)
    clarity: float = Field(..., description="Answer clarity score (0-100)", ge=0, le=100)
    keyword_coverage: float = Field(..., description="Expected keyword coverage (0-100)", ge=0, le=100)
    overall_score: float = Field(..., description="Overall score (0-100)", ge=0, le=100)

class AnswerEvaluationResponse(BaseModel):
    """Response model for answer evaluation"""
    scores: EvaluationScore = Field(..., description="Evaluation scores")
    feedback: str = Field(..., description="Detailed feedback")
    strengths: List[str] = Field(default=[], description="Answer strengths")
    improvements: List[str] = Field(default=[], description="Areas for improvement")
    keyword_analysis: Dict[str, bool] = Field(default={}, description="Keyword coverage analysis")
    evaluation_time: float = Field(..., description="Time taken for evaluation (seconds)")

class InterviewSessionRequest(BaseModel):
    """Request model for starting an interview session"""
    candidate_name: str = Field(..., description="Candidate's name", min_length=2, max_length=100)
    cv_text: str = Field(..., description="Candidate's CV text", min_length=50, max_length=5000)
    job_description: str = Field(..., description="Job description", min_length=30, max_length=2000)
    position: str = Field(..., description="Job position", min_length=5, max_length=100)
    level: DifficultyLevel = Field(..., description="Experience level")
    session_duration: int = Field(default=30, description="Session duration in minutes", ge=10, le=120)

class InterviewSession(BaseModel):
    """Interview session model"""
    session_id: str = Field(..., description="Unique session identifier")
    candidate_name: str = Field(..., description="Candidate's name")
    position: str = Field(..., description="Job position")
    level: DifficultyLevel = Field(..., description="Experience level")
    status: str = Field(..., description="Session status (active, completed, expired)")
    created_at: str = Field(..., description="Session creation timestamp")
    expires_at: str = Field(..., description="Session expiration timestamp")
    questions_asked: int = Field(default=0, description="Number of questions asked")
    questions_answered: int = Field(default=0, description="Number of questions answered")

class InterviewSessionResponse(BaseModel):
    """Response model for interview session creation"""
    session: InterviewSession = Field(..., description="Created interview session")
    first_question: InterviewQuestion = Field(..., description="First interview question")

class SessionProgressRequest(BaseModel):
    """Request model for session progress"""
    session_id: str = Field(..., description="Session identifier")
    question_id: str = Field(..., description="Question identifier")
    answer: str = Field(..., description="Candidate's answer", min_length=10, max_length=5000)

class SessionProgressResponse(BaseModel):
    """Response model for session progress"""
    evaluation: AnswerEvaluationResponse = Field(..., description="Answer evaluation")
    next_question: Optional[InterviewQuestion] = Field(None, description="Next question (if session continues)")
    session_complete: bool = Field(..., description="Whether session is complete")
    overall_progress: Dict[str, Any] = Field(default={}, description="Overall session progress")

class ErrorResponse(BaseModel):
    """Error response model"""
    error: str = Field(..., description="Error type")
    message: str = Field(..., description="Error message")
    details: Optional[Dict[str, Any]] = Field(None, description="Additional error details")