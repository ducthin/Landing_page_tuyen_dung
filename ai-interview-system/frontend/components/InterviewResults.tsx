/**
 * Interview Results Component
 * Displays comprehensive results and analytics after interview completion
 */

import React, { useState } from 'react';

interface Answer {
  question: any;
  answer: string;
  evaluation: any;
}

interface InterviewResultsProps {
  session: any;
  answers: Answer[];
  onStartNew: () => void;
}

export const InterviewResults: React.FC<InterviewResultsProps> = ({
  session,
  answers,
  onStartNew
}) => {
  const [selectedTab, setSelectedTab] = useState<'overview' | 'detailed' | 'feedback'>('overview');

  // Calculate overall statistics
  const calculateOverallStats = () => {
    if (answers.length === 0) {
      return {
        overall_score: 0,
        technical_accuracy: 0,
        completeness: 0,
        clarity: 0,
        keyword_coverage: 0
      };
    }

    const totals = answers.reduce((acc, answer) => {
      const scores = answer.evaluation.scores;
      acc.overall_score += scores.overall_score;
      acc.technical_accuracy += scores.technical_accuracy;
      acc.completeness += scores.completeness;
      acc.clarity += scores.clarity;
      acc.keyword_coverage += scores.keyword_coverage;
      return acc;
    }, {
      overall_score: 0,
      technical_accuracy: 0,
      completeness: 0,
      clarity: 0,
      keyword_coverage: 0
    });

    const count = answers.length;
    return {
      overall_score: totals.overall_score / count,
      technical_accuracy: totals.technical_accuracy / count,
      completeness: totals.completeness / count,
      clarity: totals.clarity / count,
      keyword_coverage: totals.keyword_coverage / count
    };
  };

  const overallStats = calculateOverallStats();

  const getScoreColor = (score: number): string => {
    if (score >= 80) return '#22c55e'; // green
    if (score >= 60) return '#f59e0b'; // yellow
    return '#ef4444'; // red
  };

  const getScoreLabel = (score: number): string => {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Very Good';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Fair';
    return 'Needs Improvement';
  };

  const formatDate = (dateString: string): string => {
    return new Date(dateString).toLocaleString();
  };

  const ScoreBar: React.FC<{ label: string; score: number }> = ({ label, score }) => (
    <div className="score-bar">
      <div className="score-label">
        <span>{label}</span>
        <span className="score-value">{score.toFixed(1)}%</span>
      </div>
      <div className="score-track">
        <div 
          className="score-fill"
          style={{ 
            width: `${score}%`,
            backgroundColor: getScoreColor(score)
          }}
        />
      </div>
    </div>
  );

  const renderOverview = () => (
    <div className="results-overview">
      <div className="overall-score">
        <div className="score-circle">
          <svg width="120" height="120" viewBox="0 0 120 120">
            <circle
              cx="60"
              cy="60"
              r="50"
              fill="none"
              stroke="#e5e7eb"
              strokeWidth="10"
            />
            <circle
              cx="60"
              cy="60"
              r="50"
              fill="none"
              stroke={getScoreColor(overallStats.overall_score)}
              strokeWidth="10"
              strokeDasharray={`${(overallStats.overall_score / 100) * 314} 314`}
              strokeDashoffset="0"
              transform="rotate(-90 60 60)"
            />
          </svg>
          <div className="score-text">
            <div className="score-number">{overallStats.overall_score.toFixed(0)}%</div>
            <div className="score-status">{getScoreLabel(overallStats.overall_score)}</div>
          </div>
        </div>
      </div>

      <div className="score-breakdown">
        <h3>Performance Breakdown</h3>
        <ScoreBar label="Technical Accuracy" score={overallStats.technical_accuracy} />
        <ScoreBar label="Completeness" score={overallStats.completeness} />
        <ScoreBar label="Clarity" score={overallStats.clarity} />
        <ScoreBar label="Keyword Coverage" score={overallStats.keyword_coverage} />
      </div>

      <div className="session-summary">
        <h3>Session Summary</h3>
        <div className="summary-grid">
          <div className="summary-item">
            <span className="label">Questions Answered</span>
            <span className="value">{answers.length}</span>
          </div>
          <div className="summary-item">
            <span className="label">Position</span>
            <span className="value">{session.position}</span>
          </div>
          <div className="summary-item">
            <span className="label">Level</span>
            <span className="value">{session.level.charAt(0).toUpperCase() + session.level.slice(1)}</span>
          </div>
          <div className="summary-item">
            <span className="label">Completed At</span>
            <span className="value">{formatDate(new Date().toISOString())}</span>
          </div>
        </div>
      </div>
    </div>
  );

  const renderDetailed = () => (
    <div className="results-detailed">
      <h3>Question-by-Question Analysis</h3>
      {answers.map((answer, index) => (
        <div key={index} className="question-result">
          <div className="question-header">
            <h4>Question {index + 1}</h4>
            <div className="question-meta">
              <span className="category">{answer.question.category}</span>
              <span className="difficulty">{answer.question.difficulty}</span>
            </div>
          </div>

          <div className="question-text">
            <p><strong>Q:</strong> {answer.question.question}</p>
          </div>

          <div className="answer-text">
            <p><strong>Your Answer:</strong></p>
            <div className="answer-content">{answer.answer}</div>
          </div>

          <div className="evaluation-scores">
            <div className="scores-grid">
              <div className="score-item">
                <span>Technical Accuracy</span>
                <span style={{ color: getScoreColor(answer.evaluation.scores.technical_accuracy) }}>
                  {answer.evaluation.scores.technical_accuracy.toFixed(1)}%
                </span>
              </div>
              <div className="score-item">
                <span>Completeness</span>
                <span style={{ color: getScoreColor(answer.evaluation.scores.completeness) }}>
                  {answer.evaluation.scores.completeness.toFixed(1)}%
                </span>
              </div>
              <div className="score-item">
                <span>Clarity</span>
                <span style={{ color: getScoreColor(answer.evaluation.scores.clarity) }}>
                  {answer.evaluation.scores.clarity.toFixed(1)}%
                </span>
              </div>
              <div className="score-item">
                <span>Keyword Coverage</span>
                <span style={{ color: getScoreColor(answer.evaluation.scores.keyword_coverage) }}>
                  {answer.evaluation.scores.keyword_coverage.toFixed(1)}%
                </span>
              </div>
            </div>
          </div>

          <div className="evaluation-feedback">
            <p><strong>Feedback:</strong> {answer.evaluation.feedback}</p>
            
            {answer.evaluation.strengths.length > 0 && (
              <div className="strengths">
                <p><strong>Strengths:</strong></p>
                <ul>
                  {answer.evaluation.strengths.map((strength: string, i: number) => (
                    <li key={i}>{strength}</li>
                  ))}
                </ul>
              </div>
            )}

            {answer.evaluation.improvements.length > 0 && (
              <div className="improvements">
                <p><strong>Areas for Improvement:</strong></p>
                <ul>
                  {answer.evaluation.improvements.map((improvement: string, i: number) => (
                    <li key={i}>{improvement}</li>
                  ))}
                </ul>
              </div>
            )}
          </div>
        </div>
      ))}
    </div>
  );

  const renderFeedback = () => {
    const allStrengths = answers.flatMap(a => a.evaluation.strengths);
    const allImprovements = answers.flatMap(a => a.evaluation.improvements);
    
    // Count frequency of feedback items
    const strengthCounts = allStrengths.reduce((acc, item) => {
      acc[item] = (acc[item] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    const improvementCounts = allImprovements.reduce((acc, item) => {
      acc[item] = (acc[item] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    return (
      <div className="results-feedback">
        <div className="feedback-summary">
          <h3>Overall Performance Feedback</h3>
          
          <div className="performance-level">
            <h4>Your Performance Level: {getScoreLabel(overallStats.overall_score)}</h4>
            <p>
              {overallStats.overall_score >= 80 
                ? "Excellent work! You demonstrated strong technical knowledge and clear communication skills."
                : overallStats.overall_score >= 60
                ? "Good performance with room for improvement. Focus on the areas highlighted below."
                : "You have a foundation to build on. Consider studying the improvement areas and practicing more."
              }
            </p>
          </div>

          <div className="common-strengths">
            <h4>Key Strengths</h4>
            {Object.entries(strengthCounts).length > 0 ? (
              <ul>
                {Object.entries(strengthCounts)
                  .sort(([,a], [,b]) => b - a)
                  .slice(0, 5)
                  .map(([strength, count]) => (
                    <li key={strength}>
                      {strength} {count > 1 && <span className="count">({count} times)</span>}
                    </li>
                  ))}
              </ul>
            ) : (
              <p>Continue practicing to develop your strengths!</p>
            )}
          </div>

          <div className="improvement-areas">
            <h4>Areas for Improvement</h4>
            {Object.entries(improvementCounts).length > 0 ? (
              <ul>
                {Object.entries(improvementCounts)
                  .sort(([,a], [,b]) => b - a)
                  .slice(0, 5)
                  .map(([improvement, count]) => (
                    <li key={improvement}>
                      {improvement} {count > 1 && <span className="count">({count} times)</span>}
                    </li>
                  ))}
              </ul>
            ) : (
              <p>Great job! No major improvement areas identified.</p>
            )}
          </div>

          <div className="next-steps">
            <h4>Recommended Next Steps</h4>
            <ul>
              <li>Review the detailed question analysis above</li>
              <li>Practice explaining technical concepts with specific examples</li>
              <li>Study the technologies mentioned in the job requirements</li>
              <li>Take another practice interview to track your progress</li>
              {overallStats.overall_score < 70 && (
                <li>Consider additional studying in your weak areas before real interviews</li>
              )}
            </ul>
          </div>
        </div>
      </div>
    );
  };

  return (
    <div className="interview-results">
      <div className="results-header">
        <h2>Interview Complete! 🎉</h2>
        <p>Here's how you performed, {session.candidate_name}</p>
      </div>

      <div className="results-tabs">
        <button
          className={`tab ${selectedTab === 'overview' ? 'active' : ''}`}
          onClick={() => setSelectedTab('overview')}
        >
          Overview
        </button>
        <button
          className={`tab ${selectedTab === 'detailed' ? 'active' : ''}`}
          onClick={() => setSelectedTab('detailed')}
        >
          Detailed Analysis
        </button>
        <button
          className={`tab ${selectedTab === 'feedback' ? 'active' : ''}`}
          onClick={() => setSelectedTab('feedback')}
        >
          Feedback & Tips
        </button>
      </div>

      <div className="results-content">
        {selectedTab === 'overview' && renderOverview()}
        {selectedTab === 'detailed' && renderDetailed()}
        {selectedTab === 'feedback' && renderFeedback()}
      </div>

      <div className="results-actions">
        <button onClick={onStartNew} className="btn btn-primary">
          Start New Interview
        </button>
        
        <button 
          onClick={() => window.print()} 
          className="btn btn-secondary"
        >
          Print Results
        </button>
      </div>
    </div>
  );
};

export default InterviewResults;