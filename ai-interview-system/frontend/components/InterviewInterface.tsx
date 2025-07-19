/**
 * Interview Interface Component
 * Main component for conducting AI-powered interviews
 */

import React, { useState, useEffect, useCallback } from 'react';
import { InterviewSession } from './InterviewSession';
import { InterviewStart } from './InterviewStart';
import { InterviewResults } from './InterviewResults';
import { LoadingSpinner } from '../utils/LoadingSpinner';
import { ErrorMessage } from '../utils/ErrorMessage';
import { interviewAPI } from '../utils/api';

// Types
interface InterviewState {
  stage: 'start' | 'interview' | 'results' | 'loading';
  session: any | null;
  currentQuestion: any | null;
  answers: any[];
  error: string | null;
}

interface CandidateInfo {
  name: string;
  cvText: string;
  jobDescription: string;
  position: string;
  level: string;
}

export const InterviewInterface: React.FC = () => {
  const [state, setState] = useState<InterviewState>({
    stage: 'start',
    session: null,
    currentQuestion: null,
    answers: [],
    error: null
  });

  // Start new interview session
  const startInterview = useCallback(async (candidateInfo: CandidateInfo) => {
    setState(prev => ({ ...prev, stage: 'loading', error: null }));

    try {
      const response = await interviewAPI.startSession({
        candidate_name: candidateInfo.name,
        cv_text: candidateInfo.cvText,
        job_description: candidateInfo.jobDescription,
        position: candidateInfo.position,
        level: candidateInfo.level,
        session_duration: 30
      });

      setState(prev => ({
        ...prev,
        stage: 'interview',
        session: response.session,
        currentQuestion: response.first_question,
        answers: []
      }));
    } catch (error) {
      setState(prev => ({
        ...prev,
        stage: 'start',
        error: `Failed to start interview: ${error.message}`
      }));
    }
  }, []);

  // Submit answer and get next question
  const submitAnswer = useCallback(async (answer: string, questionId: string) => {
    if (!state.session) return;

    setState(prev => ({ ...prev, stage: 'loading' }));

    try {
      const response = await interviewAPI.submitAnswer({
        session_id: state.session.session_id,
        question_id: questionId,
        answer: answer
      });

      const newAnswers = [...state.answers, {
        question: state.currentQuestion,
        answer: answer,
        evaluation: response.evaluation
      }];

      if (response.session_complete) {
        setState(prev => ({
          ...prev,
          stage: 'results',
          answers: newAnswers,
          currentQuestion: null
        }));
      } else {
        setState(prev => ({
          ...prev,
          stage: 'interview',
          currentQuestion: response.next_question,
          answers: newAnswers
        }));
      }
    } catch (error) {
      setState(prev => ({
        ...prev,
        stage: 'interview',
        error: `Failed to submit answer: ${error.message}`
      }));
    }
  }, [state.session, state.currentQuestion, state.answers]);

  // End interview session
  const endInterview = useCallback(async () => {
    if (!state.session) return;

    try {
      await interviewAPI.endSession(state.session.session_id);
      setState({
        stage: 'start',
        session: null,
        currentQuestion: null,
        answers: [],
        error: null
      });
    } catch (error) {
      console.error('Failed to end session:', error);
      // Still reset state even if API call fails
      setState({
        stage: 'start',
        session: null,
        currentQuestion: null,
        answers: [],
        error: null
      });
    }
  }, [state.session]);

  // Start new interview (reset)
  const startNewInterview = useCallback(() => {
    setState({
      stage: 'start',
      session: null,
      currentQuestion: null,
      answers: [],
      error: null
    });
  }, []);

  // Render based on current stage
  const renderContent = () => {
    switch (state.stage) {
      case 'start':
        return (
          <InterviewStart
            onStart={startInterview}
            error={state.error}
          />
        );

      case 'loading':
        return (
          <div className="interview-loading">
            <LoadingSpinner />
            <p>Processing...</p>
          </div>
        );

      case 'interview':
        return (
          <InterviewSession
            session={state.session}
            currentQuestion={state.currentQuestion}
            onSubmitAnswer={submitAnswer}
            onEndInterview={endInterview}
            questionNumber={state.answers.length + 1}
            error={state.error}
          />
        );

      case 'results':
        return (
          <InterviewResults
            session={state.session}
            answers={state.answers}
            onStartNew={startNewInterview}
          />
        );

      default:
        return <ErrorMessage message="Unknown interview stage" />;
    }
  };

  return (
    <div className="interview-interface">
      <div className="interview-header">
        <h1>AI Interview Training System</h1>
        <p>Practice technical interviews with AI-powered questions</p>
      </div>

      <div className="interview-content">
        {renderContent()}
      </div>

      {/* Global error handler */}
      {state.error && state.stage !== 'start' && (
        <ErrorMessage 
          message={state.error}
          onDismiss={() => setState(prev => ({ ...prev, error: null }))}
        />
      )}
    </div>
  );
};

export default InterviewInterface;