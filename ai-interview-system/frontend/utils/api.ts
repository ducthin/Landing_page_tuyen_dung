/**
 * API utility functions for the AI Interview System
 */

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000';

// API response types
interface ApiResponse<T> {
  data?: T;
  error?: string;
}

// Request/Response interfaces
interface StartSessionRequest {
  candidate_name: string;
  cv_text: string;
  job_description: string;
  position: string;
  level: string;
  session_duration?: number;
}

interface StartSessionResponse {
  session: any;
  first_question: any;
}

interface SubmitAnswerRequest {
  session_id: string;
  question_id: string;
  answer: string;
}

interface SubmitAnswerResponse {
  evaluation: any;
  next_question?: any;
  session_complete: boolean;
  overall_progress: any;
}

interface GenerateQuestionsRequest {
  cv_text: string;
  job_description: string;
  position: string;
  level: string;
  skill_focus: string;
  category?: string;
  num_questions?: number;
}

interface GenerateQuestionsResponse {
  questions: any[];
  metadata: any;
  generation_time: number;
}

interface EvaluateAnswerRequest {
  question: string;
  answer: string;
  expected_keywords?: string[];
  skill_focus: string;
  difficulty: string;
}

interface EvaluateAnswerResponse {
  scores: any;
  feedback: string;
  strengths: string[];
  improvements: string[];
  keyword_analysis: Record<string, boolean>;
  evaluation_time: number;
}

class InterviewAPI {
  private baseUrl: string;

  constructor(baseUrl: string = API_BASE_URL) {
    this.baseUrl = baseUrl;
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const url = `${this.baseUrl}${endpoint}`;
    
    const defaultOptions: RequestInit = {
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
    };

    const config = { ...defaultOptions, ...options };

    try {
      const response = await fetch(url, config);
      
      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.detail || `HTTP ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      return data;
    } catch (error) {
      if (error instanceof Error) {
        throw error;
      }
      throw new Error('Network error occurred');
    }
  }

  // Interview Session APIs
  async startSession(request: StartSessionRequest): Promise<StartSessionResponse> {
    return this.request<StartSessionResponse>('/api/v1/interview/session/start', {
      method: 'POST',
      body: JSON.stringify(request),
    });
  }

  async submitAnswer(request: SubmitAnswerRequest): Promise<SubmitAnswerResponse> {
    return this.request<SubmitAnswerResponse>('/api/v1/interview/session/progress', {
      method: 'POST',
      body: JSON.stringify(request),
    });
  }

  async getSession(sessionId: string): Promise<any> {
    return this.request<any>(`/api/v1/interview/session/${sessionId}`);
  }

  async endSession(sessionId: string): Promise<{ message: string }> {
    return this.request<{ message: string }>(`/api/v1/interview/session/${sessionId}`, {
      method: 'DELETE',
    });
  }

  // Question Generation APIs
  async generateQuestions(request: GenerateQuestionsRequest): Promise<GenerateQuestionsResponse> {
    return this.request<GenerateQuestionsResponse>('/api/v1/interview/generate', {
      method: 'POST',
      body: JSON.stringify(request),
    });
  }

  async getCategories(): Promise<{ categories: Array<{ value: string; label: string }> }> {
    return this.request<{ categories: Array<{ value: string; label: string }> }>('/api/v1/interview/categories');
  }

  async getLevels(): Promise<{ levels: Array<{ value: string; label: string }> }> {
    return this.request<{ levels: Array<{ value: string; label: string }> }>('/api/v1/interview/levels');
  }

  // Evaluation APIs
  async evaluateAnswer(request: EvaluateAnswerRequest): Promise<EvaluateAnswerResponse> {
    return this.request<EvaluateAnswerResponse>('/api/v1/evaluation/evaluate', {
      method: 'POST',
      body: JSON.stringify(request),
    });
  }

  async bulkEvaluateAnswers(requests: EvaluateAnswerRequest[]): Promise<any> {
    return this.request<any>('/api/v1/evaluation/bulk-evaluate', {
      method: 'POST',
      body: JSON.stringify(requests),
    });
  }

  async getEvaluationCriteria(level: string): Promise<any> {
    return this.request<any>(`/api/v1/evaluation/evaluation-criteria/${level}`);
  }

  async getKeywordSuggestions(skillFocus: string): Promise<any> {
    return this.request<any>(`/api/v1/evaluation/keyword-suggestions/${skillFocus}`);
  }

  // System APIs
  async getHealth(): Promise<{ status: string; model_status: string; version: string }> {
    return this.request<{ status: string; model_status: string; version: string }>('/health');
  }

  async getSystemStatus(): Promise<any> {
    return this.request<any>('/');
  }

  // Admin APIs (require authentication)
  async getAdminStatus(token: string): Promise<any> {
    return this.request<any>('/api/v1/admin/status', {
      headers: {
        'Authorization': `Bearer ${token}`,
      },
    });
  }

  async reloadModel(token: string): Promise<any> {
    return this.request<any>('/api/v1/admin/model/reload', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
      },
    });
  }

  async getActiveSessionsAdmin(token: string): Promise<any> {
    return this.request<any>('/api/v1/admin/sessions/active', {
      headers: {
        'Authorization': `Bearer ${token}`,
      },
    });
  }
}

// Create singleton instance
export const interviewAPI = new InterviewAPI();

// Error handling utilities
export class APIError extends Error {
  constructor(message: string, public status?: number, public code?: string) {
    super(message);
    this.name = 'APIError';
  }
}

// Request retry utility
export async function withRetry<T>(
  fn: () => Promise<T>,
  maxRetries: number = 3,
  delay: number = 1000
): Promise<T> {
  let lastError: Error;

  for (let i = 0; i <= maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error as Error;
      
      if (i === maxRetries) {
        break;
      }

      // Don't retry on client errors (4xx)
      if (error instanceof APIError && error.status && error.status >= 400 && error.status < 500) {
        break;
      }

      // Wait before retrying
      await new Promise(resolve => setTimeout(resolve, delay * Math.pow(2, i)));
    }
  }

  throw lastError!;
}

// Response caching utility
class ResponseCache {
  private cache = new Map<string, { data: any; expiry: number }>();
  private defaultTTL = 5 * 60 * 1000; // 5 minutes

  set(key: string, data: any, ttl: number = this.defaultTTL): void {
    this.cache.set(key, {
      data,
      expiry: Date.now() + ttl
    });
  }

  get(key: string): any | null {
    const item = this.cache.get(key);
    
    if (!item) {
      return null;
    }

    if (Date.now() > item.expiry) {
      this.cache.delete(key);
      return null;
    }

    return item.data;
  }

  clear(): void {
    this.cache.clear();
  }

  delete(key: string): void {
    this.cache.delete(key);
  }
}

export const responseCache = new ResponseCache();

// Cached API wrapper
export function withCache<T extends any[], R>(
  fn: (...args: T) => Promise<R>,
  getCacheKey: (...args: T) => string,
  ttl?: number
) {
  return async (...args: T): Promise<R> => {
    const cacheKey = getCacheKey(...args);
    const cached = responseCache.get(cacheKey);
    
    if (cached) {
      return cached;
    }

    const result = await fn(...args);
    responseCache.set(cacheKey, result, ttl);
    return result;
  };
}

// Export default instance
export default interviewAPI;