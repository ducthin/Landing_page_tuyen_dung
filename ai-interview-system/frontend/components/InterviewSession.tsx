/**
 * Interview Session Component
 * Handles the active interview session with question display and answer submission
 */

import React, { useState, useEffect, useRef } from 'react';
import { ErrorMessage } from '../utils/ErrorMessage';
import { Timer } from '../utils/Timer';

interface InterviewSessionProps {
  session: any;
  currentQuestion: any;
  onSubmitAnswer: (answer: string, questionId: string) => void;
  onEndInterview: () => void;
  questionNumber: number;
  error: string | null;
}

export const InterviewSession: React.FC<InterviewSessionProps> = ({
  session,
  currentQuestion,
  onSubmitAnswer,
  onEndInterview,
  questionNumber,
  error
}) => {
  const [answer, setAnswer] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [timeRemaining, setTimeRemaining] = useState(30 * 60); // 30 minutes in seconds
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  // Focus on textarea when component mounts or question changes
  useEffect(() => {
    if (textareaRef.current) {
      textareaRef.current.focus();
    }
  }, [currentQuestion]);

  // Timer countdown
  useEffect(() => {
    const timer = setInterval(() => {
      setTimeRemaining(prev => {
        if (prev <= 1) {
          clearInterval(timer);
          // Auto-end interview when time runs out
          onEndInterview();
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [onEndInterview]);

  const handleSubmit = async () => {
    if (!answer.trim()) {
      alert('Please provide an answer before submitting.');
      return;
    }

    if (answer.trim().length < 10) {
      alert('Please provide a more detailed answer (at least 10 characters).');
      return;
    }

    setIsSubmitting(true);
    try {
      await onSubmitAnswer(answer.trim(), currentQuestion.id || `q${questionNumber}`);
      setAnswer(''); // Clear answer for next question
    } catch (error) {
      console.error('Failed to submit answer:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    // Submit on Ctrl+Enter
    if (e.ctrlKey && e.key === 'Enter') {
      e.preventDefault();
      handleSubmit();
    }
  };

  const formatTime = (seconds: number): string => {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
  };

  const getTimeColor = (): string => {
    if (timeRemaining <= 300) return 'red'; // Last 5 minutes
    if (timeRemaining <= 600) return 'orange'; // Last 10 minutes
    return 'green';
  };

  if (!currentQuestion) {
    return (
      <div className="interview-session">
        <div className="no-question">
          <h3>Loading next question...</h3>
          <div className="spinner"></div>
        </div>
      </div>
    );
  }

  return (
    <div className="interview-session">
      {/* Session Header */}
      <div className="session-header">
        <div className="session-info">
          <h2>Interview in Progress</h2>
          <div className="session-details">
            <span className="candidate">👤 {session.candidate_name}</span>
            <span className="position">💼 {session.position}</span>
            <span className="level">📊 {session.level.charAt(0).toUpperCase() + session.level.slice(1)}</span>
          </div>
        </div>
        
        <div className="session-controls">
          <div className="timer" style={{ color: getTimeColor() }}>
            ⏱️ {formatTime(timeRemaining)}
          </div>
          <button 
            onClick={onEndInterview}
            className="btn btn-secondary btn-sm"
          >
            End Interview
          </button>
        </div>
      </div>

      {/* Progress Indicator */}
      <div className="progress-indicator">
        <div className="progress-info">
          <span>Question {questionNumber} of 5</span>
        </div>
        <div className="progress-bar">
          <div 
            className="progress-fill"
            style={{ width: `${(questionNumber / 5) * 100}%` }}
          />
        </div>
      </div>

      {error && <ErrorMessage message={error} />}

      {/* Current Question */}
      <div className="question-section">
        <div className="question-header">
          <h3>Question {questionNumber}</h3>
          <div className="question-meta">
            <span className="category">{currentQuestion.category}</span>
            <span className="difficulty">{currentQuestion.difficulty}</span>
            <span className="skill-focus">Focus: {currentQuestion.skill_focus}</span>
          </div>
        </div>

        <div className="question-content">
          <p>{currentQuestion.question}</p>
        </div>

        {currentQuestion.expected_keywords && currentQuestion.expected_keywords.length > 0 && (
          <div className="question-hints">
            <p><strong>Consider covering:</strong></p>
            <div className="keywords">
              {currentQuestion.expected_keywords.map((keyword: string, index: number) => (
                <span key={index} className="keyword-tag">
                  {keyword}
                </span>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Answer Section */}
      <div className="answer-section">
        <div className="answer-header">
          <label htmlFor="answer">Your Answer</label>
          <div className="answer-tips">
            <span>💡 Tip: Press Ctrl+Enter to submit quickly</span>
          </div>
        </div>

        <textarea
          ref={textareaRef}
          id="answer"
          value={answer}
          onChange={(e) => setAnswer(e.target.value)}
          onKeyDown={handleKeyPress}
          placeholder="Type your answer here. Be detailed and provide examples when possible..."
          className="answer-textarea"
          rows={8}
          disabled={isSubmitting}
        />

        <div className="answer-info">
          <span className="character-count">
            {answer.length} characters (minimum 10)
          </span>
          <div className="answer-actions">
            <button
              onClick={handleSubmit}
              disabled={!answer.trim() || answer.trim().length < 10 || isSubmitting}
              className="btn btn-primary"
            >
              {isSubmitting ? (
                <>
                  <span className="spinner-small"></span>
                  Submitting...
                </>
              ) : (
                'Submit Answer'
              )}
            </button>
          </div>
        </div>
      </div>

      {/* Help Section */}
      <div className="help-section">
        <details>
          <summary>💡 Tips for Better Answers</summary>
          <ul>
            <li>Provide specific examples from your experience</li>
            <li>Explain your thought process and reasoning</li>
            <li>Cover the technical concepts mentioned in the hints</li>
            <li>Structure your answer with clear points</li>
            <li>Don't be afraid to mention trade-offs and alternatives</li>
          </ul>
        </details>
      </div>
    </div>
  );
};

export default InterviewSession;