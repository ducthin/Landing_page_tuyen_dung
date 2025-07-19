"""
Model service for loading and serving the fine-tuned Qwen model
Handles interview question generation and answer evaluation
"""

import torch
import asyncio
import logging
import time
from typing import List, Optional, Dict, Any
from transformers import AutoTokenizer, AutoModelForCausalLM
from peft import PeftModel
import gc

from ..models.schemas import InterviewQuestion, AnswerEvaluationResponse, EvaluationScore

logger = logging.getLogger(__name__)

class ModelService:
    """Service for managing the AI interview model"""
    
    def __init__(self, model_path: str):
        self.model_path = model_path
        self.base_model_name = "Qwen/Qwen2.5-Coder-7B-Instruct"
        self.model = None
        self.tokenizer = None
        self.is_loaded = False
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        
    async def load_model(self):
        """Load the fine-tuned model asynchronously"""
        try:
            logger.info("Loading tokenizer...")
            self.tokenizer = AutoTokenizer.from_pretrained(
                self.model_path,
                trust_remote_code=True
            )
            
            if self.tokenizer.pad_token is None:
                self.tokenizer.pad_token = self.tokenizer.eos_token
            
            logger.info("Loading base model...")
            base_model = AutoModelForCausalLM.from_pretrained(
                self.base_model_name,
                torch_dtype=torch.float16,
                device_map="auto",
                trust_remote_code=True
            )
            
            logger.info("Loading LoRA adapter...")
            self.model = PeftModel.from_pretrained(base_model, self.model_path)
            
            # Set to evaluation mode
            self.model.eval()
            
            self.is_loaded = True
            logger.info("✅ Model loaded successfully")
            
        except Exception as e:
            logger.error(f"❌ Failed to load model: {str(e)}")
            raise
    
    async def generate_questions(
        self,
        cv_text: str,
        job_description: str,
        position: str,
        level: str,
        skill_focus: str,
        category: str = "technical",
        num_questions: int = 1
    ) -> List[InterviewQuestion]:
        """Generate interview questions based on CV and job requirements"""
        
        if not self.is_loaded:
            raise RuntimeError("Model not loaded")
        
        questions = []
        
        for i in range(num_questions):
            try:
                question_text = await self._generate_single_question(
                    cv_text, job_description, position, level, skill_focus, category
                )
                
                # Extract expected keywords and evaluation criteria
                expected_keywords = await self._extract_keywords(question_text, skill_focus)
                evaluation_criteria = await self._generate_evaluation_criteria(question_text, level)
                
                question = InterviewQuestion(
                    question=question_text,
                    category=category,
                    difficulty=level,
                    skill_focus=skill_focus,
                    expected_keywords=expected_keywords,
                    evaluation_criteria=evaluation_criteria
                )
                
                questions.append(question)
                
            except Exception as e:
                logger.error(f"Failed to generate question {i+1}: {str(e)}")
                # Continue with other questions
                continue
        
        return questions
    
    async def _generate_single_question(
        self,
        cv_text: str,
        job_description: str,
        position: str,
        level: str,
        skill_focus: str,
        category: str
    ) -> str:
        """Generate a single interview question"""
        
        system_prompt = f"""
You are an expert technical interviewer. Your task is to generate relevant interview questions based on the candidate's CV and the job requirements.

Position: {position}
Level: {level}

Job Requirements:
{job_description}

Candidate CV:
{cv_text}

Generate appropriate technical interview questions that match the candidate's experience level and the job requirements.
""".strip()
        
        user_prompt = f"Generate a {category} interview question focusing on {skill_focus} for this {level} level candidate."
        
        # Format conversation for Qwen
        formatted_input = f"<|im_start|>system\n{system_prompt}<|im_end|>\n<|im_start|>user\n{user_prompt}<|im_end|>\n<|im_start|>assistant\n"
        
        # Tokenize
        inputs = self.tokenizer(
            formatted_input,
            return_tensors="pt",
            truncation=True,
            max_length=1024
        )
        inputs = {k: v.to(self.device) for k, v in inputs.items()}
        
        # Generate
        with torch.no_grad():
            outputs = self.model.generate(
                **inputs,
                max_new_tokens=200,
                temperature=0.7,
                do_sample=True,
                pad_token_id=self.tokenizer.eos_token_id,
                eos_token_id=self.tokenizer.eos_token_id
            )
        
        # Decode response
        response = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
        
        # Extract assistant response
        assistant_start = response.find("<|im_start|>assistant\n") + len("<|im_start|>assistant\n")
        if assistant_start > len("<|im_start|>assistant\n") - 1:
            generated_question = response[assistant_start:].split("<|im_end|>")[0].strip()
        else:
            generated_question = "What are your key strengths in this technology area?"
        
        return generated_question
    
    async def _extract_keywords(self, question: str, skill_focus: str) -> List[str]:
        """Extract expected keywords from the question and skill focus"""
        # Simple keyword extraction based on common patterns
        keywords = []
        
        # Add skill focus
        keywords.append(skill_focus.lower())
        
        # Common technical keywords based on question content
        common_keywords = {
            "python": ["python", "django", "flask", "fastapi", "pandas", "numpy"],
            "javascript": ["javascript", "node.js", "react", "vue", "angular", "express"],
            "java": ["java", "spring", "hibernate", "maven", "junit"],
            "database": ["sql", "postgresql", "mysql", "mongodb", "redis"],
            "aws": ["aws", "ec2", "s3", "lambda", "cloudformation"],
            "docker": ["docker", "containerization", "dockerfile", "compose"],
            "kubernetes": ["kubernetes", "pods", "services", "deployments", "kubectl"]
        }
        
        for tech, tech_keywords in common_keywords.items():
            if tech in question.lower() or tech in skill_focus.lower():
                keywords.extend(tech_keywords[:3])  # Limit to 3 keywords per technology
        
        # Remove duplicates and return up to 5 keywords
        return list(set(keywords))[:5]
    
    async def _generate_evaluation_criteria(self, question: str, level: str) -> List[str]:
        """Generate evaluation criteria based on question and level"""
        base_criteria = [
            "Technical accuracy",
            "Completeness of answer",
            "Clarity of explanation"
        ]
        
        if level == "senior":
            base_criteria.extend([
                "Best practices knowledge",
                "Real-world experience examples",
                "Problem-solving approach"
            ])
        elif level == "mid":
            base_criteria.extend([
                "Understanding of concepts",
                "Practical application knowledge"
            ])
        else:  # junior
            base_criteria.extend([
                "Basic concept understanding",
                "Learning approach"
            ])
        
        return base_criteria
    
    async def evaluate_answer(
        self,
        question: str,
        answer: str,
        expected_keywords: List[str],
        skill_focus: str,
        difficulty: str
    ) -> AnswerEvaluationResponse:
        """Evaluate an interview answer"""
        
        start_time = time.time()
        
        try:
            # Keyword analysis
            keyword_analysis = {}
            keyword_coverage = 0
            
            for keyword in expected_keywords:
                found = keyword.lower() in answer.lower()
                keyword_analysis[keyword] = found
                if found:
                    keyword_coverage += 1
            
            keyword_coverage_score = (keyword_coverage / len(expected_keywords) * 100) if expected_keywords else 50
            
            # Basic scoring algorithm (in production, this could use the model)
            technical_accuracy = await self._score_technical_accuracy(answer, skill_focus, difficulty)
            completeness = await self._score_completeness(answer, question)
            clarity = await self._score_clarity(answer)
            
            overall_score = (technical_accuracy + completeness + clarity + keyword_coverage_score) / 4
            
            scores = EvaluationScore(
                technical_accuracy=technical_accuracy,
                completeness=completeness,
                clarity=clarity,
                keyword_coverage=keyword_coverage_score,
                overall_score=overall_score
            )
            
            # Generate feedback
            feedback = await self._generate_feedback(scores, answer, expected_keywords)
            strengths = await self._identify_strengths(answer, scores)
            improvements = await self._identify_improvements(answer, scores, expected_keywords)
            
            evaluation_time = time.time() - start_time
            
            return AnswerEvaluationResponse(
                scores=scores,
                feedback=feedback,
                strengths=strengths,
                improvements=improvements,
                keyword_analysis=keyword_analysis,
                evaluation_time=evaluation_time
            )
            
        except Exception as e:
            logger.error(f"Failed to evaluate answer: {str(e)}")
            raise
    
    async def _score_technical_accuracy(self, answer: str, skill_focus: str, difficulty: str) -> float:
        """Score technical accuracy of the answer"""
        # Simple heuristic scoring (in production, could use model-based evaluation)
        score = 50.0  # Base score
        
        # Length-based adjustment
        if len(answer) > 100:
            score += 20
        if len(answer) > 300:
            score += 10
        
        # Skill focus mention
        if skill_focus.lower() in answer.lower():
            score += 15
        
        # Technical terms (basic check)
        technical_terms = ["algorithm", "optimize", "performance", "scalable", "efficient", "architecture"]
        for term in technical_terms:
            if term in answer.lower():
                score += 5
                break
        
        return min(score, 100.0)
    
    async def _score_completeness(self, answer: str, question: str) -> float:
        """Score completeness of the answer"""
        # Simple length and structure-based scoring
        score = 30.0
        
        if len(answer) > 150:
            score += 30
        if len(answer) > 300:
            score += 20
        if len(answer) > 500:
            score += 20
        
        return min(score, 100.0)
    
    async def _score_clarity(self, answer: str) -> float:
        """Score clarity of the answer"""
        score = 40.0
        
        # Sentence structure
        sentences = answer.split('.')
        if len(sentences) > 2:
            score += 20
        
        # Presence of examples
        example_words = ["example", "for instance", "such as", "like"]
        for word in example_words:
            if word in answer.lower():
                score += 20
                break
        
        # Structure words
        structure_words = ["first", "second", "finally", "however", "therefore"]
        for word in structure_words:
            if word in answer.lower():
                score += 20
                break
        
        return min(score, 100.0)
    
    async def _generate_feedback(self, scores: EvaluationScore, answer: str, expected_keywords: List[str]) -> str:
        """Generate detailed feedback for the answer"""
        feedback_parts = []
        
        if scores.overall_score >= 80:
            feedback_parts.append("Excellent answer! You demonstrated strong technical knowledge.")
        elif scores.overall_score >= 60:
            feedback_parts.append("Good answer with solid understanding.")
        else:
            feedback_parts.append("Your answer shows basic understanding but could be improved.")
        
        if scores.technical_accuracy < 70:
            feedback_parts.append("Consider providing more technical details and accuracy.")
        
        if scores.completeness < 70:
            feedback_parts.append("Try to provide a more comprehensive answer covering all aspects of the question.")
        
        if scores.clarity < 70:
            feedback_parts.append("Work on making your explanations clearer with examples and better structure.")
        
        if scores.keyword_coverage < 70 and expected_keywords:
            feedback_parts.append(f"Try to include more relevant technical terms like: {', '.join(expected_keywords)}")
        
        return " ".join(feedback_parts)
    
    async def _identify_strengths(self, answer: str, scores: EvaluationScore) -> List[str]:
        """Identify strengths in the answer"""
        strengths = []
        
        if scores.technical_accuracy >= 70:
            strengths.append("Good technical understanding")
        
        if scores.completeness >= 70:
            strengths.append("Comprehensive answer")
        
        if scores.clarity >= 70:
            strengths.append("Clear explanation")
        
        if len(answer) > 200:
            strengths.append("Detailed response")
        
        if any(word in answer.lower() for word in ["example", "experience", "project"]):
            strengths.append("Provided practical examples")
        
        return strengths
    
    async def _identify_improvements(self, answer: str, scores: EvaluationScore, expected_keywords: List[str]) -> List[str]:
        """Identify areas for improvement"""
        improvements = []
        
        if scores.technical_accuracy < 70:
            improvements.append("Include more technical details and accuracy")
        
        if scores.completeness < 70:
            improvements.append("Provide more comprehensive coverage of the topic")
        
        if scores.clarity < 70:
            improvements.append("Improve explanation structure and clarity")
        
        if scores.keyword_coverage < 50:
            improvements.append("Include more relevant technical terminology")
        
        if len(answer) < 100:
            improvements.append("Provide more detailed explanations")
        
        return improvements
    
    async def cleanup(self):
        """Cleanup model resources"""
        if self.model:
            del self.model
        if self.tokenizer:
            del self.tokenizer
        
        if torch.cuda.is_available():
            torch.cuda.empty_cache()
        
        gc.collect()
        self.is_loaded = False
        logger.info("Model service cleaned up")