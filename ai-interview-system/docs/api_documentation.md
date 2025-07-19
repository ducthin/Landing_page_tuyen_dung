# API Documentation - AI Interview Training System

## Overview

The AI Interview Training System API provides endpoints for conducting AI-powered technical interviews. The system generates relevant interview questions based on candidate CVs and job requirements, evaluates answers, and provides detailed feedback.

## Base URL

```
Production: https://your-domain.com/api/v1
Development: http://localhost:8000/api/v1
```

## Authentication

Most endpoints are public. Admin endpoints require Bearer token authentication:

```bash
Authorization: Bearer <your-admin-token>
```

## Rate Limiting

- **Public endpoints**: 100 requests per minute per IP
- **Session endpoints**: 10 concurrent sessions per IP
- **Generation endpoints**: 20 requests per minute per IP

## API Endpoints

### Health Check

#### GET /health

Check API health status.

**Response:**
```json
{
  "status": "healthy",
  "model_status": "loaded",
  "version": "1.0.0"
}
```

---

## Interview Endpoints

### Start Interview Session

#### POST /interview/session/start

Create a new interview session and get the first question.

**Request Body:**
```json
{
  "candidate_name": "John Doe",
  "cv_text": "Senior Python Developer with 5 years of experience...",
  "job_description": "Backend Developer role requiring Python, Django...",
  "position": "Senior Backend Developer",
  "level": "senior",
  "session_duration": 30
}
```

**Parameters:**
- `candidate_name` (string, required): Full name of the candidate
- `cv_text` (string, required): Candidate's CV text (50-5000 chars)
- `job_description` (string, required): Job description (30-2000 chars)
- `position` (string, required): Job position title
- `level` (enum, required): `junior`, `mid`, or `senior`
- `session_duration` (integer, optional): Session duration in minutes (default: 30)

**Response:**
```json
{
  "session": {
    "session_id": "uuid-string",
    "candidate_name": "John Doe",
    "position": "Senior Backend Developer",
    "level": "senior",
    "status": "active",
    "created_at": "2024-01-15T10:30:00Z",
    "expires_at": "2024-01-15T11:00:00Z",
    "questions_asked": 1,
    "questions_answered": 0
  },
  "first_question": {
    "question": "Explain Django ORM lazy loading and optimization strategies?",
    "category": "technical",
    "difficulty": "senior",
    "skill_focus": "Django ORM",
    "expected_keywords": ["select_related", "prefetch_related", "lazy loading"],
    "evaluation_criteria": ["Technical accuracy", "Best practices knowledge"]
  }
}
```

### Submit Answer and Get Next Question

#### POST /interview/session/progress

Submit an answer and receive the next question or session completion.

**Request Body:**
```json
{
  "session_id": "uuid-string",
  "question_id": "question-uuid",
  "answer": "Django ORM uses lazy loading by default, which means..."
}
```

**Parameters:**
- `session_id` (string, required): Session identifier
- `question_id` (string, required): Question identifier
- `answer` (string, required): Candidate's answer (10-5000 chars)

**Response:**
```json
{
  "evaluation": {
    "scores": {
      "technical_accuracy": 85.0,
      "completeness": 78.5,
      "clarity": 82.0,
      "keyword_coverage": 90.0,
      "overall_score": 83.9
    },
    "feedback": "Excellent answer! You demonstrated strong technical knowledge.",
    "strengths": ["Good technical understanding", "Clear explanation"],
    "improvements": ["Include more practical examples"],
    "keyword_analysis": {
      "select_related": true,
      "prefetch_related": true,
      "lazy loading": true
    },
    "evaluation_time": 0.45
  },
  "next_question": {
    "question": "How would you design a scalable microservices architecture?",
    "category": "system_design",
    "difficulty": "senior",
    "skill_focus": "System Architecture",
    "expected_keywords": ["microservices", "load balancing", "API gateway"],
    "evaluation_criteria": ["System design knowledge", "Scalability awareness"]
  },
  "session_complete": false,
  "overall_progress": {
    "questions_asked": 2,
    "questions_answered": 1,
    "average_scores": {
      "overall_score": 83.9
    },
    "completion_percentage": 50.0
  }
}
```

### Get Session Details

#### GET /interview/session/{session_id}

Retrieve detailed information about a session.

**Response:**
```json
{
  "session": {
    "session_id": "uuid-string",
    "candidate_name": "John Doe",
    "position": "Senior Backend Developer",
    "level": "senior",
    "status": "active",
    "created_at": "2024-01-15T10:30:00Z",
    "expires_at": "2024-01-15T11:00:00Z",
    "questions_asked": 2,
    "questions_answered": 1
  },
  "progress": {
    "questions_asked": 2,
    "questions_answered": 1,
    "average_scores": {
      "technical_accuracy": 85.0,
      "completeness": 78.5,
      "clarity": 82.0,
      "keyword_coverage": 90.0,
      "overall_score": 83.9
    },
    "completion_percentage": 50.0
  },
  "questions_history": [
    {
      "question": {
        "question_id": "q1",
        "question": "Explain Django ORM lazy loading...",
        "category": "technical",
        "asked_at": "2024-01-15T10:30:00Z"
      },
      "answer": {
        "answer": "Django ORM uses lazy loading...",
        "evaluation": {
          "scores": {
            "overall_score": 83.9
          },
          "feedback": "Excellent answer!"
        },
        "answered_at": "2024-01-15T10:32:00Z"
      }
    }
  ]
}
```

### End Session

#### DELETE /interview/session/{session_id}

Manually end an interview session.

**Response:**
```json
{
  "message": "Session ended successfully"
}
```

### Generate Questions (Standalone)

#### POST /interview/generate

Generate interview questions without creating a session.

**Request Body:**
```json
{
  "cv_text": "Senior Python Developer with 5 years of experience...",
  "job_description": "Backend Developer role requiring Python, Django...",
  "position": "Senior Backend Developer",
  "level": "senior",
  "skill_focus": "Django",
  "category": "technical",
  "num_questions": 3
}
```

**Parameters:**
- `cv_text` (string, required): Candidate's CV text
- `job_description` (string, required): Job description
- `position` (string, required): Job position
- `level` (enum, required): `junior`, `mid`, or `senior`
- `skill_focus` (string, required): Primary skill to focus on
- `category` (enum, optional): Question category (default: `technical`)
- `num_questions` (integer, optional): Number of questions (1-5, default: 1)

**Response:**
```json
{
  "questions": [
    {
      "question": "Explain Django ORM lazy loading strategies?",
      "category": "technical",
      "difficulty": "senior",
      "skill_focus": "Django",
      "expected_keywords": ["lazy loading", "select_related", "prefetch_related"],
      "evaluation_criteria": ["Technical accuracy", "Best practices"]
    }
  ],
  "metadata": {
    "position": "Senior Backend Developer",
    "level": "senior",
    "skill_focus": "Django",
    "category": "technical",
    "model_version": "qwen2.5-coder-7b-instruct-finetuned"
  },
  "generation_time": 1.23
}
```

### Get Available Categories

#### GET /interview/categories

Get list of available question categories.

**Response:**
```json
{
  "categories": [
    {"value": "technical", "label": "Technical"},
    {"value": "system_design", "label": "System Design"},
    {"value": "performance", "label": "Performance"},
    {"value": "security", "label": "Security"},
    {"value": "best_practices", "label": "Best Practices"}
  ]
}
```

### Get Available Levels

#### GET /interview/levels

Get list of available difficulty levels.

**Response:**
```json
{
  "levels": [
    {"value": "junior", "label": "Junior"},
    {"value": "mid", "label": "Mid"},
    {"value": "senior", "label": "Senior"}
  ]
}
```

---

## Evaluation Endpoints

### Evaluate Answer

#### POST /evaluation/evaluate

Evaluate a single interview answer.

**Request Body:**
```json
{
  "question": "Explain Django ORM lazy loading strategies?",
  "answer": "Django ORM uses lazy loading by default...",
  "expected_keywords": ["lazy loading", "select_related", "prefetch_related"],
  "skill_focus": "Django",
  "difficulty": "senior"
}
```

**Response:**
```json
{
  "scores": {
    "technical_accuracy": 85.0,
    "completeness": 78.5,
    "clarity": 82.0,
    "keyword_coverage": 90.0,
    "overall_score": 83.9
  },
  "feedback": "Excellent answer! You demonstrated strong technical knowledge.",
  "strengths": ["Good technical understanding", "Clear explanation"],
  "improvements": ["Include more practical examples"],
  "keyword_analysis": {
    "lazy loading": true,
    "select_related": true,
    "prefetch_related": true
  },
  "evaluation_time": 0.34
}
```

### Bulk Evaluate Answers

#### POST /evaluation/bulk-evaluate

Evaluate multiple answers in batch (max 10).

**Request Body:**
```json
[
  {
    "question": "Question 1...",
    "answer": "Answer 1...",
    "skill_focus": "Python",
    "difficulty": "senior"
  },
  {
    "question": "Question 2...",
    "answer": "Answer 2...",
    "skill_focus": "Django",
    "difficulty": "senior"
  }
]
```

**Response:**
```json
{
  "evaluations": [
    {
      "index": 0,
      "evaluation": {
        "scores": {"overall_score": 85.0},
        "feedback": "Good answer..."
      },
      "success": true
    },
    {
      "index": 1,
      "evaluation": {
        "scores": {"overall_score": 78.5},
        "feedback": "Consider adding..."
      },
      "success": true
    }
  ],
  "total_processed": 2,
  "successful": 2,
  "failed": 0
}
```

### Get Evaluation Criteria

#### GET /evaluation/evaluation-criteria/{level}

Get evaluation criteria for a specific level.

**Parameters:**
- `level` (string, required): `junior`, `mid`, or `senior`

**Response:**
```json
{
  "level": "senior",
  "criteria": [
    "Technical accuracy",
    "Best practices knowledge",
    "Real-world experience examples",
    "Problem-solving approach",
    "Completeness of answer",
    "System design considerations",
    "Performance and scalability awareness"
  ],
  "description": "Evaluation criteria for senior level candidates"
}
```

### Get Keyword Suggestions

#### GET /evaluation/keyword-suggestions/{skill_focus}

Get suggested keywords for a skill focus area.

**Parameters:**
- `skill_focus` (string, required): Technology or skill name

**Response:**
```json
{
  "skill_focus": "python",
  "suggested_keywords": [
    "python", "django", "flask", "fastapi", "pandas", 
    "numpy", "pip", "virtual environment"
  ],
  "description": "Commonly expected keywords for python related questions"
}
```

---

## Admin Endpoints

All admin endpoints require authentication.

### Get System Status

#### GET /admin/status

Get comprehensive system status.

**Headers:**
```
Authorization: Bearer <admin-token>
```

**Response:**
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "system": {
    "cpu_percent": 45.2,
    "memory": {
      "total_gb": 16.0,
      "available_gb": 8.5,
      "used_gb": 7.5,
      "percent": 46.9
    },
    "disk": {
      "total_gb": 100.0,
      "free_gb": 75.0,
      "used_gb": 25.0,
      "percent": 25.0
    },
    "gpu": {
      "available": true,
      "device_count": 1,
      "device_name": "NVIDIA Tesla V100",
      "memory_allocated": 2.5,
      "memory_total": 16.0
    }
  },
  "model": {
    "loaded": true,
    "model_path": "./models/ai-interview-model",
    "device": "cuda"
  },
  "api": {
    "status": "healthy",
    "version": "1.0.0"
  }
}
```

### Reload Model

#### POST /admin/model/reload

Force reload the AI model.

**Response:**
```json
{
  "message": "Model reloaded successfully",
  "status": "loaded",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Get Active Sessions

#### GET /admin/sessions/active

Get list of active interview sessions.

**Response:**
```json
{
  "active_sessions": [
    {
      "session_id": "uuid-1",
      "candidate_name": "John Doe",
      "position": "Senior Backend Developer",
      "level": "senior",
      "created_at": "2024-01-15T10:30:00Z",
      "expires_at": "2024-01-15T11:00:00Z",
      "questions_asked": 2,
      "questions_answered": 1
    }
  ],
  "total_active": 1,
  "timestamp": "2024-01-15T10:35:00Z"
}
```

### Cleanup Expired Sessions

#### POST /admin/sessions/cleanup

Manually trigger cleanup of expired sessions.

**Response:**
```json
{
  "message": "Session cleanup completed",
  "sessions_cleaned": 5,
  "sessions_remaining": 3,
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

## Error Handling

### Error Response Format

```json
{
  "error": "ValidationError",
  "message": "CV text must be at least 50 characters",
  "details": {
    "field": "cv_text",
    "code": "min_length"
  }
}
```

### HTTP Status Codes

- `200` - Success
- `400` - Bad Request (validation errors)
- `401` - Unauthorized (admin endpoints)
- `404` - Not Found (session/resource not found)
- `422` - Unprocessable Entity (validation errors)
- `429` - Too Many Requests (rate limiting)
- `500` - Internal Server Error
- `503` - Service Unavailable (model not loaded)

### Common Error Codes

- `model_not_loaded` - AI model is not available
- `session_not_found` - Interview session doesn't exist
- `session_expired` - Interview session has expired
- `validation_error` - Request validation failed
- `rate_limit_exceeded` - Too many requests
- `internal_error` - Server error

---

## Rate Limits

### Limits by Endpoint Type

| Endpoint Type | Limit | Window |
|---------------|-------|---------|
| Health/Info | 1000/hour | 1 hour |
| Generation | 20/minute | 1 minute |
| Evaluation | 50/minute | 1 minute |
| Session | 10 concurrent | - |
| Admin | 100/hour | 1 hour |

### Rate Limit Headers

```
X-RateLimit-Limit: 20
X-RateLimit-Remaining: 18
X-RateLimit-Reset: 1642234800
```

---

## SDKs and Examples

### Python Example

```python
import requests

# Start interview session
response = requests.post('http://localhost:8000/api/v1/interview/session/start', 
    json={
        "candidate_name": "John Doe",
        "cv_text": "Senior Python Developer...",
        "job_description": "Backend Developer role...",
        "position": "Senior Backend Developer",
        "level": "senior"
    }
)

session_data = response.json()
session_id = session_data["session"]["session_id"]
first_question = session_data["first_question"]

# Submit answer
answer_response = requests.post('http://localhost:8000/api/v1/interview/session/progress',
    json={
        "session_id": session_id,
        "question_id": "q1",
        "answer": "Django ORM uses lazy loading..."
    }
)

evaluation = answer_response.json()
```

### JavaScript Example

```javascript
// Start interview session
const sessionResponse = await fetch('/api/v1/interview/session/start', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({
        candidate_name: "John Doe",
        cv_text: "Senior Python Developer...",
        job_description: "Backend Developer role...",
        position: "Senior Backend Developer",
        level: "senior"
    })
});

const sessionData = await sessionResponse.json();

// Submit answer
const answerResponse = await fetch('/api/v1/interview/session/progress', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({
        session_id: sessionData.session.session_id,
        question_id: "q1",
        answer: "Django ORM uses lazy loading..."
    })
});

const evaluation = await answerResponse.json();
```

### cURL Examples

```bash
# Start session
curl -X POST http://localhost:8000/api/v1/interview/session/start \
  -H "Content-Type: application/json" \
  -d '{
    "candidate_name": "John Doe",
    "cv_text": "Senior Python Developer...",
    "job_description": "Backend Developer role...",
    "position": "Senior Backend Developer",
    "level": "senior"
  }'

# Submit answer
curl -X POST http://localhost:8000/api/v1/interview/session/progress \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "uuid-string",
    "question_id": "q1",
    "answer": "Django ORM uses lazy loading..."
  }'
```

---

## Changelog

### v1.0.0 (2024-01-15)
- Initial API release
- Interview session management
- Question generation with Qwen2.5-Coder-7B
- Answer evaluation system
- Admin monitoring endpoints
- Rate limiting implementation

---

## Support

For technical support:
- **Documentation**: [GitHub Repository](https://github.com/your-repo)
- **Issues**: Create GitHub issue with API logs
- **Email**: support@your-domain.com

**Response Times:**
- Critical issues: 2-4 hours
- General support: 24-48 hours