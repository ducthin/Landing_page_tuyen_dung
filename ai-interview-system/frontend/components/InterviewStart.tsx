/**
 * Interview Start Component
 * Form for entering candidate information and starting an interview
 */

import React, { useState } from 'react';
import { ErrorMessage } from '../utils/ErrorMessage';

interface CandidateInfo {
  name: string;
  cvText: string;
  jobDescription: string;
  position: string;
  level: string;
}

interface InterviewStartProps {
  onStart: (candidateInfo: CandidateInfo) => void;
  error: string | null;
}

const EXPERIENCE_LEVELS = [
  { value: 'junior', label: 'Junior (0-2 years)' },
  { value: 'mid', label: 'Mid-level (2-5 years)' },
  { value: 'senior', label: 'Senior (5+ years)' }
];

const COMMON_POSITIONS = [
  'Backend Developer',
  'Frontend Developer',
  'Full Stack Developer',
  'DevOps Engineer',
  'Machine Learning Engineer',
  'Data Scientist',
  'Mobile Developer',
  'QA Engineer',
  'System Administrator',
  'Cloud Architect',
  'Cybersecurity Specialist',
  'Product Manager',
  'Technical Lead',
  'Database Administrator'
];

export const InterviewStart: React.FC<InterviewStartProps> = ({ onStart, error }) => {
  const [formData, setFormData] = useState<CandidateInfo>({
    name: '',
    cvText: '',
    jobDescription: '',
    position: '',
    level: 'mid'
  });

  const [validationErrors, setValidationErrors] = useState<Record<string, string>>({});

  const handleInputChange = (field: keyof CandidateInfo, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
    
    // Clear validation error when user starts typing
    if (validationErrors[field]) {
      setValidationErrors(prev => ({ ...prev, [field]: '' }));
    }
  };

  const validateForm = (): boolean => {
    const errors: Record<string, string> = {};

    if (!formData.name.trim()) {
      errors.name = 'Name is required';
    } else if (formData.name.trim().length < 2) {
      errors.name = 'Name must be at least 2 characters';
    }

    if (!formData.cvText.trim()) {
      errors.cvText = 'CV text is required';
    } else if (formData.cvText.trim().length < 50) {
      errors.cvText = 'CV text must be at least 50 characters';
    }

    if (!formData.jobDescription.trim()) {
      errors.jobDescription = 'Job description is required';
    } else if (formData.jobDescription.trim().length < 30) {
      errors.jobDescription = 'Job description must be at least 30 characters';
    }

    if (!formData.position.trim()) {
      errors.position = 'Position is required';
    }

    setValidationErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (validateForm()) {
      onStart(formData);
    }
  };

  const fillSampleData = () => {
    setFormData({
      name: 'John Doe',
      cvText: 'Senior Python Developer with 5 years of experience in building scalable web applications. Proficient in Django, FastAPI, PostgreSQL, Redis, and Docker. Experience with microservices architecture, RESTful APIs, and cloud deployment on AWS. Strong background in database optimization and system performance tuning.',
      jobDescription: 'Senior Backend Developer. Requirements: Python, Django/FastAPI, PostgreSQL, Redis, Docker, AWS, microservices, API design, 5+ years experience. Responsibilities include designing scalable APIs, optimizing database performance, and mentoring junior developers.',
      position: 'Senior Backend Developer',
      level: 'senior'
    });
    setValidationErrors({});
  };

  return (
    <div className="interview-start">
      <div className="start-header">
        <h2>Start Your AI Interview</h2>
        <p>Enter your information to begin a personalized technical interview</p>
        
        <button 
          type="button" 
          onClick={fillSampleData}
          className="btn btn-secondary btn-sm"
        >
          Fill Sample Data
        </button>
      </div>

      {error && <ErrorMessage message={error} />}

      <form onSubmit={handleSubmit} className="start-form">
        <div className="form-group">
          <label htmlFor="name">Full Name *</label>
          <input
            id="name"
            type="text"
            value={formData.name}
            onChange={(e) => handleInputChange('name', e.target.value)}
            className={`form-control ${validationErrors.name ? 'error' : ''}`}
            placeholder="Enter your full name"
          />
          {validationErrors.name && (
            <span className="error-text">{validationErrors.name}</span>
          )}
        </div>

        <div className="form-group">
          <label htmlFor="position">Position *</label>
          <input
            id="position"
            type="text"
            value={formData.position}
            onChange={(e) => handleInputChange('position', e.target.value)}
            className={`form-control ${validationErrors.position ? 'error' : ''}`}
            placeholder="e.g., Senior Backend Developer"
            list="positions"
          />
          <datalist id="positions">
            {COMMON_POSITIONS.map(position => (
              <option key={position} value={position} />
            ))}
          </datalist>
          {validationErrors.position && (
            <span className="error-text">{validationErrors.position}</span>
          )}
        </div>

        <div className="form-group">
          <label htmlFor="level">Experience Level *</label>
          <select
            id="level"
            value={formData.level}
            onChange={(e) => handleInputChange('level', e.target.value)}
            className="form-control"
          >
            {EXPERIENCE_LEVELS.map(level => (
              <option key={level.value} value={level.value}>
                {level.label}
              </option>
            ))}
          </select>
        </div>

        <div className="form-group">
          <label htmlFor="cvText">Your CV/Resume *</label>
          <textarea
            id="cvText"
            value={formData.cvText}
            onChange={(e) => handleInputChange('cvText', e.target.value)}
            className={`form-control ${validationErrors.cvText ? 'error' : ''}`}
            rows={6}
            placeholder="Paste your CV or resume text here. Include your experience, skills, and technologies you've worked with..."
          />
          <div className="character-count">
            {formData.cvText.length} characters (minimum 50)
          </div>
          {validationErrors.cvText && (
            <span className="error-text">{validationErrors.cvText}</span>
          )}
        </div>

        <div className="form-group">
          <label htmlFor="jobDescription">Job Description *</label>
          <textarea
            id="jobDescription"
            value={formData.jobDescription}
            onChange={(e) => handleInputChange('jobDescription', e.target.value)}
            className={`form-control ${validationErrors.jobDescription ? 'error' : ''}`}
            rows={4}
            placeholder="Paste the job description you're applying for. Include requirements, responsibilities, and preferred technologies..."
          />
          <div className="character-count">
            {formData.jobDescription.length} characters (minimum 30)
          </div>
          {validationErrors.jobDescription && (
            <span className="error-text">{validationErrors.jobDescription}</span>
          )}
        </div>

        <div className="form-actions">
          <button type="submit" className="btn btn-primary">
            Start Interview
          </button>
        </div>
      </form>

      <div className="start-info">
        <h3>What to Expect</h3>
        <ul>
          <li>🤖 AI-generated questions based on your CV and job requirements</li>
          <li>⏱️ 30-minute session with 3-5 technical questions</li>
          <li>📊 Real-time evaluation and feedback on your answers</li>
          <li>🎯 Questions tailored to your experience level</li>
          <li>📈 Detailed performance analysis at the end</li>
        </ul>
      </div>
    </div>
  );
};

export default InterviewStart;