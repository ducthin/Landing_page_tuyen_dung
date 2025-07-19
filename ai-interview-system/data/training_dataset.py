"""
Comprehensive AI Interview Training Dataset
Supporting 13+ technical positions with realistic CV-Job matching scenarios
"""

import json
import random
from typing import List, Dict, Any

class InterviewTrainingDataset:
    """Comprehensive training dataset for AI interview system"""
    
    def __init__(self):
        self.positions = [
            "Senior Backend Developer",
            "Senior Frontend Developer", 
            "Full Stack Developer",
            "DevOps Engineer",
            "Machine Learning Engineer",
            "Data Scientist",
            "Mobile Developer (React Native)",
            "QA Automation Engineer",
            "System Administrator",
            "Cloud Architect",
            "Cybersecurity Specialist",
            "Product Manager (Technical)",
            "Technical Lead",
            "Database Administrator",
            "AI/ML Research Engineer"
        ]
        
    def generate_comprehensive_dataset(self) -> List[Dict[str, Any]]:
        """Generate complete training dataset with all positions"""
        training_data = []
        
        # Senior Backend Developer
        training_data.extend(self._generate_backend_developer_data())
        
        # Senior Frontend Developer
        training_data.extend(self._generate_frontend_developer_data())
        
        # Full Stack Developer
        training_data.extend(self._generate_fullstack_developer_data())
        
        # DevOps Engineer
        training_data.extend(self._generate_devops_engineer_data())
        
        # Machine Learning Engineer
        training_data.extend(self._generate_ml_engineer_data())
        
        # Data Scientist
        training_data.extend(self._generate_data_scientist_data())
        
        # Mobile Developer
        training_data.extend(self._generate_mobile_developer_data())
        
        # QA Automation Engineer
        training_data.extend(self._generate_qa_engineer_data())
        
        # System Administrator
        training_data.extend(self._generate_sysadmin_data())
        
        # Cloud Architect
        training_data.extend(self._generate_cloud_architect_data())
        
        # Cybersecurity Specialist
        training_data.extend(self._generate_cybersecurity_data())
        
        # Product Manager (Technical)
        training_data.extend(self._generate_product_manager_data())
        
        # Technical Lead
        training_data.extend(self._generate_technical_lead_data())
        
        # Database Administrator
        training_data.extend(self._generate_dba_data())
        
        # AI/ML Research Engineer
        training_data.extend(self._generate_ai_research_data())
        
        # Junior level positions
        training_data.extend(self._generate_junior_level_data())
        
        return training_data
    
    def _generate_backend_developer_data(self) -> List[Dict[str, Any]]:
        """Generate backend developer interview data"""
        return [
            {
                "cv_text": """Senior Python Developer with 6 years of experience in building scalable web applications. 
                Proficient in Django, FastAPI, PostgreSQL, Redis, and Docker. Experience with microservices 
                architecture, RESTful APIs, and cloud deployment on AWS. Strong background in database optimization 
                and system performance tuning.""",
                "job_description": """Senior Backend Developer. Requirements: Python, Django/FastAPI, PostgreSQL, 
                Redis, Docker, AWS, microservices, API design, 5+ years experience.""",
                "position": "Senior Backend Developer",
                "level": "senior",
                "questions": [
                    {
                        "question": "Explain Django ORM lazy loading and how to optimize N+1 query problems?",
                        "category": "technical",
                        "difficulty": "senior",
                        "skill_focus": "Django ORM",
                        "expected_keywords": ["select_related", "prefetch_related", "lazy loading", "N+1 problem", "query optimization"]
                    },
                    {
                        "question": "How would you design a scalable microservices architecture for an e-commerce platform?",
                        "category": "system_design", 
                        "difficulty": "senior",
                        "skill_focus": "System Architecture",
                        "expected_keywords": ["microservices", "service discovery", "load balancing", "database per service", "API gateway"]
                    },
                    {
                        "question": "Describe your approach to handling database transactions in distributed systems.",
                        "category": "technical",
                        "difficulty": "senior", 
                        "skill_focus": "Database Design",
                        "expected_keywords": ["ACID properties", "distributed transactions", "2PC", "saga pattern", "eventual consistency"]
                    },
                    {
                        "question": "How do you implement caching strategies in a high-traffic web application?",
                        "category": "technical",
                        "difficulty": "senior",
                        "skill_focus": "Performance Optimization",
                        "expected_keywords": ["Redis", "cache invalidation", "cache aside", "write through", "TTL"]
                    },
                    {
                        "question": "Walk me through your process for debugging a memory leak in a Python application?",
                        "category": "problem_solving",
                        "difficulty": "senior",
                        "skill_focus": "Debugging",
                        "expected_keywords": ["memory profiling", "gc module", "tracemalloc", "heap dump", "reference cycles"]
                    }
                ]
            }
        ]
    
    def _generate_frontend_developer_data(self) -> List[Dict[str, Any]]:
        """Generate frontend developer interview data"""
        return [
            {
                "cv_text": """Senior Frontend Developer with 5+ years of experience in React, TypeScript, and Next.js. 
                Expert in modern CSS frameworks (Tailwind, Styled Components), state management (Redux, Zustand), 
                and performance optimization. Experience with testing frameworks (Jest, Cypress) and build tools 
                (Webpack, Vite). Strong focus on user experience and accessibility.""",
                "job_description": """Senior Frontend Developer. Requirements: React, TypeScript, Next.js, modern CSS, 
                state management, testing, performance optimization, 4+ years experience.""",
                "position": "Senior Frontend Developer", 
                "level": "senior",
                "questions": [
                    {
                        "question": "Explain React's reconciliation algorithm and how Virtual DOM works.",
                        "category": "technical",
                        "difficulty": "senior",
                        "skill_focus": "React Internals",
                        "expected_keywords": ["virtual DOM", "reconciliation", "diffing", "fiber", "component lifecycle"]
                    },
                    {
                        "question": "How would you optimize a React application for better performance?",
                        "category": "performance",
                        "difficulty": "senior", 
                        "skill_focus": "Performance Optimization",
                        "expected_keywords": ["memoization", "code splitting", "lazy loading", "bundle optimization", "React.memo"]
                    },
                    {
                        "question": "Describe different state management patterns in React and when to use each.",
                        "category": "technical",
                        "difficulty": "senior",
                        "skill_focus": "State Management", 
                        "expected_keywords": ["useState", "useContext", "Redux", "Zustand", "server state", "local state"]
                    },
                    {
                        "question": "How do you ensure web accessibility (a11y) in your React applications?",
                        "category": "best_practices",
                        "difficulty": "senior",
                        "skill_focus": "Accessibility",
                        "expected_keywords": ["ARIA", "semantic HTML", "screen readers", "keyboard navigation", "WCAG"]
                    },
                    {
                        "question": "Explain CSS-in-JS vs traditional CSS. What are the trade-offs?",
                        "category": "technical",
                        "difficulty": "senior",
                        "skill_focus": "CSS Architecture",
                        "expected_keywords": ["styled-components", "emotion", "CSS modules", "runtime overhead", "scoped styles"]
                    }
                ]
            }
        ]
    
    def _generate_fullstack_developer_data(self) -> List[Dict[str, Any]]:
        """Generate full stack developer interview data"""
        return [
            {
                "cv_text": """Full Stack Developer with 4 years of experience in MERN stack (MongoDB, Express.js, React, Node.js). 
                Proficient in both frontend and backend development, RESTful APIs, GraphQL, and real-time applications 
                with Socket.io. Experience with cloud platforms (AWS, Heroku), CI/CD pipelines, and agile development.""",
                "job_description": """Full Stack Developer. Requirements: MERN stack, RESTful APIs, GraphQL, real-time features, 
                cloud deployment, version control, 3+ years experience.""",
                "position": "Full Stack Developer",
                "level": "mid",
                "questions": [
                    {
                        "question": "Compare REST vs GraphQL APIs. When would you choose one over the other?",
                        "category": "technical",
                        "difficulty": "mid",
                        "skill_focus": "API Design",
                        "expected_keywords": ["REST", "GraphQL", "over-fetching", "under-fetching", "schema", "resolvers"]
                    },
                    {
                        "question": "How would you implement real-time chat functionality in a web application?",
                        "category": "system_design",
                        "difficulty": "mid",
                        "skill_focus": "Real-time Systems", 
                        "expected_keywords": ["WebSockets", "Socket.io", "polling", "message queues", "scaling"]
                    },
                    {
                        "question": "Explain the authentication flow using JWT tokens in a MERN application.",
                        "category": "security",
                        "difficulty": "mid",
                        "skill_focus": "Authentication",
                        "expected_keywords": ["JWT", "access token", "refresh token", "localStorage", "security best practices"]
                    },
                    {
                        "question": "How do you handle state synchronization between frontend and backend?",
                        "category": "technical",
                        "difficulty": "mid",
                        "skill_focus": "State Management",
                        "expected_keywords": ["optimistic updates", "cache invalidation", "real-time sync", "conflict resolution"]
                    }
                ]
            }
        ]
    
    def _generate_devops_engineer_data(self) -> List[Dict[str, Any]]:
        """Generate DevOps engineer interview data"""
        return [
            {
                "cv_text": """DevOps Engineer with 5 years of experience in cloud infrastructure management and automation. 
                Expert in AWS/Azure, Docker, Kubernetes, Terraform, Jenkins, and monitoring tools (Prometheus, Grafana). 
                Strong background in CI/CD pipelines, infrastructure as code, and site reliability engineering.""",
                "job_description": """DevOps Engineer. Requirements: AWS/Azure, Docker, Kubernetes, Terraform, CI/CD, 
                monitoring, automation, 4+ years experience.""",
                "position": "DevOps Engineer",
                "level": "senior", 
                "questions": [
                    {
                        "question": "Explain the difference between Docker containers and virtual machines.",
                        "category": "technical",
                        "difficulty": "mid",
                        "skill_focus": "Containerization",
                        "expected_keywords": ["containers", "VMs", "hypervisor", "kernel sharing", "resource isolation"]
                    },
                    {
                        "question": "How would you design a highly available Kubernetes cluster?",
                        "category": "system_design",
                        "difficulty": "senior",
                        "skill_focus": "Kubernetes",
                        "expected_keywords": ["multi-master", "etcd cluster", "load balancing", "pod disruption budget", "anti-affinity"]
                    },
                    {
                        "question": "Describe your approach to implementing infrastructure as code with Terraform.",
                        "category": "technical",
                        "difficulty": "senior",
                        "skill_focus": "Infrastructure as Code",
                        "expected_keywords": ["Terraform", "state management", "modules", "planning", "remote backend"]
                    },
                    {
                        "question": "How do you set up monitoring and alerting for a microservices architecture?",
                        "category": "monitoring",
                        "difficulty": "senior",
                        "skill_focus": "Observability",
                        "expected_keywords": ["Prometheus", "Grafana", "distributed tracing", "logs aggregation", "SLI/SLO"]
                    }
                ]
            }
        ]
    
    def _generate_ml_engineer_data(self) -> List[Dict[str, Any]]:
        """Generate ML engineer interview data"""
        return [
            {
                "cv_text": """Machine Learning Engineer with 4 years of experience in building and deploying ML models. 
                Proficient in Python, TensorFlow, PyTorch, scikit-learn, and MLOps tools. Experience with computer vision, 
                NLP, and recommendation systems. Strong background in model optimization, A/B testing, and production ML systems.""",
                "job_description": """Machine Learning Engineer. Requirements: Python, TensorFlow/PyTorch, ML algorithms, 
                model deployment, MLOps, 3+ years experience.""",
                "position": "Machine Learning Engineer",
                "level": "senior",
                "questions": [
                    {
                        "question": "Explain the bias-variance tradeoff and how it affects model performance.",
                        "category": "ml_theory",
                        "difficulty": "senior",
                        "skill_focus": "ML Fundamentals",
                        "expected_keywords": ["bias", "variance", "overfitting", "underfitting", "model complexity"]
                    },
                    {
                        "question": "How would you deploy a machine learning model to production?",
                        "category": "mlops",
                        "difficulty": "senior",
                        "skill_focus": "Model Deployment",
                        "expected_keywords": ["model serving", "containerization", "API endpoints", "monitoring", "versioning"]
                    },
                    {
                        "question": "Describe different techniques for handling imbalanced datasets.",
                        "category": "ml_theory",
                        "difficulty": "mid",
                        "skill_focus": "Data Preprocessing",
                        "expected_keywords": ["oversampling", "undersampling", "SMOTE", "class weights", "evaluation metrics"]
                    },
                    {
                        "question": "How do you evaluate and monitor ML models in production?",
                        "category": "mlops",
                        "difficulty": "senior",
                        "skill_focus": "Model Monitoring",
                        "expected_keywords": ["data drift", "model drift", "performance metrics", "A/B testing", "feature monitoring"]
                    }
                ]
            }
        ]
    
    def _generate_data_scientist_data(self) -> List[Dict[str, Any]]:
        """Generate data scientist interview data"""
        return [
            {
                "cv_text": """Data Scientist with 5 years of experience in statistical analysis and machine learning. 
                Expert in Python, R, SQL, and data visualization tools (Tableau, Power BI). Strong background in 
                statistical modeling, hypothesis testing, and business intelligence. Experience with big data 
                technologies (Spark, Hadoop) and cloud platforms.""",
                "job_description": """Data Scientist. Requirements: Python/R, SQL, statistical analysis, machine learning, 
                data visualization, business intelligence, 4+ years experience.""",
                "position": "Data Scientist",
                "level": "senior",
                "questions": [
                    {
                        "question": "Explain the difference between correlation and causation with examples.",
                        "category": "statistics",
                        "difficulty": "mid",
                        "skill_focus": "Statistical Analysis",
                        "expected_keywords": ["correlation", "causation", "confounding variables", "causality", "experiments"]
                    },
                    {
                        "question": "How would you design an A/B test for a new product feature?",
                        "category": "experimentation",
                        "difficulty": "senior",
                        "skill_focus": "Experimental Design",
                        "expected_keywords": ["A/B testing", "sample size", "statistical power", "control group", "randomization"]
                    },
                    {
                        "question": "Describe different dimensionality reduction techniques and when to use them.",
                        "category": "ml_theory",
                        "difficulty": "senior",
                        "skill_focus": "Feature Engineering",
                        "expected_keywords": ["PCA", "t-SNE", "UMAP", "curse of dimensionality", "feature selection"]
                    }
                ]
            }
        ]
    
    def _generate_mobile_developer_data(self) -> List[Dict[str, Any]]:
        """Generate mobile developer interview data"""
        return [
            {
                "cv_text": """Mobile Developer with 4 years of experience in React Native and native iOS/Android development. 
                Proficient in JavaScript, TypeScript, Swift, and Kotlin. Experience with mobile app architecture, 
                performance optimization, and app store deployment. Strong background in mobile UI/UX design patterns.""",
                "job_description": """Mobile Developer (React Native). Requirements: React Native, JavaScript/TypeScript, 
                mobile app development, performance optimization, 3+ years experience.""",
                "position": "Mobile Developer (React Native)",
                "level": "mid",
                "questions": [
                    {
                        "question": "Explain the bridge architecture in React Native and its performance implications.",
                        "category": "technical",
                        "difficulty": "senior",
                        "skill_focus": "React Native Architecture",
                        "expected_keywords": ["bridge", "JavaScript thread", "native modules", "performance bottlenecks"]
                    },
                    {
                        "question": "How do you optimize React Native app performance?",
                        "category": "performance",
                        "difficulty": "mid",
                        "skill_focus": "Mobile Optimization", 
                        "expected_keywords": ["FlatList", "image optimization", "bundle size", "native modules", "memory management"]
                    }
                ]
            }
        ]
    
    def _generate_qa_engineer_data(self) -> List[Dict[str, Any]]:
        """Generate QA automation engineer interview data"""
        return [
            {
                "cv_text": """QA Automation Engineer with 4 years of experience in test automation and quality assurance. 
                Expert in Selenium, Cypress, Jest, and API testing tools. Strong background in test strategy, 
                CI/CD integration, and performance testing. Experience with both manual and automated testing.""",
                "job_description": """QA Automation Engineer. Requirements: Test automation, Selenium/Cypress, API testing, 
                CI/CD integration, 3+ years experience.""",
                "position": "QA Automation Engineer",
                "level": "mid",
                "questions": [
                    {
                        "question": "Explain the testing pyramid and how it applies to modern web applications.",
                        "category": "testing_strategy",
                        "difficulty": "mid",
                        "skill_focus": "Test Strategy",
                        "expected_keywords": ["unit tests", "integration tests", "e2e tests", "test pyramid", "test automation"]
                    },
                    {
                        "question": "How would you design an automated testing strategy for a microservices architecture?",
                        "category": "testing_strategy", 
                        "difficulty": "senior",
                        "skill_focus": "Microservices Testing",
                        "expected_keywords": ["contract testing", "service isolation", "test data management", "environment strategy"]
                    }
                ]
            }
        ]
    
    def _generate_sysadmin_data(self) -> List[Dict[str, Any]]:
        """Generate system administrator interview data"""
        return [
            {
                "cv_text": """System Administrator with 6 years of experience in Linux server management and network administration. 
                Expert in shell scripting, system monitoring, backup strategies, and security hardening. Strong background 
                in virtualization, automation, and incident response.""",
                "job_description": """System Administrator. Requirements: Linux administration, shell scripting, 
                network management, security, automation, 5+ years experience.""",
                "position": "System Administrator",
                "level": "senior",
                "questions": [
                    {
                        "question": "How would you troubleshoot a server with high CPU usage?",
                        "category": "troubleshooting",
                        "difficulty": "mid",
                        "skill_focus": "System Troubleshooting",
                        "expected_keywords": ["top", "htop", "ps", "process analysis", "resource monitoring"]
                    },
                    {
                        "question": "Explain different backup strategies and their trade-offs.",
                        "category": "system_design",
                        "difficulty": "senior",
                        "skill_focus": "Backup Strategy",
                        "expected_keywords": ["full backup", "incremental", "differential", "RTO", "RPO"]
                    }
                ]
            }
        ]
    
    def _generate_cloud_architect_data(self) -> List[Dict[str, Any]]:
        """Generate cloud architect interview data"""
        return [
            {
                "cv_text": """Cloud Architect with 7 years of experience in designing scalable cloud solutions. 
                Expert in AWS/Azure architecture, serverless computing, and multi-cloud strategies. Strong background 
                in cost optimization, security compliance, and enterprise migration strategies.""",
                "job_description": """Cloud Architect. Requirements: AWS/Azure expertise, solution architecture, 
                serverless, security, cost optimization, 6+ years experience.""",
                "position": "Cloud Architect",
                "level": "senior",
                "questions": [
                    {
                        "question": "Design a highly available and scalable web application architecture on AWS.",
                        "category": "system_design",
                        "difficulty": "senior",
                        "skill_focus": "Cloud Architecture",
                        "expected_keywords": ["load balancer", "auto scaling", "multi-AZ", "CDN", "database clustering"]
                    },
                    {
                        "question": "How would you implement a disaster recovery strategy for critical applications?",
                        "category": "system_design",
                        "difficulty": "senior",
                        "skill_focus": "Disaster Recovery",
                        "expected_keywords": ["RTO", "RPO", "backup strategy", "failover", "data replication"]
                    }
                ]
            }
        ]
    
    def _generate_cybersecurity_data(self) -> List[Dict[str, Any]]:
        """Generate cybersecurity specialist interview data"""
        return [
            {
                "cv_text": """Cybersecurity Specialist with 5 years of experience in security assessment and incident response. 
                Expert in penetration testing, vulnerability assessment, and security compliance. Strong background 
                in network security, encryption, and security monitoring tools.""",
                "job_description": """Cybersecurity Specialist. Requirements: Security assessment, penetration testing, 
                incident response, compliance, 4+ years experience.""",
                "position": "Cybersecurity Specialist",
                "level": "senior",
                "questions": [
                    {
                        "question": "Explain the OWASP Top 10 vulnerabilities and mitigation strategies.",
                        "category": "security",
                        "difficulty": "senior",
                        "skill_focus": "Web Security",
                        "expected_keywords": ["OWASP", "SQL injection", "XSS", "CSRF", "security best practices"]
                    },
                    {
                        "question": "How would you design a security incident response plan?",
                        "category": "security",
                        "difficulty": "senior",
                        "skill_focus": "Incident Response",
                        "expected_keywords": ["incident response", "forensics", "containment", "recovery", "lessons learned"]
                    }
                ]
            }
        ]
    
    def _generate_product_manager_data(self) -> List[Dict[str, Any]]:
        """Generate technical product manager interview data"""
        return [
            {
                "cv_text": """Technical Product Manager with 5 years of experience in product strategy and development. 
                Strong technical background with ability to work closely with engineering teams. Experience in 
                agile methodologies, user research, and data-driven decision making.""",
                "job_description": """Product Manager (Technical). Requirements: Product strategy, technical understanding, 
                agile methodologies, stakeholder management, 4+ years experience.""",
                "position": "Product Manager (Technical)",
                "level": "senior",
                "questions": [
                    {
                        "question": "How would you prioritize features for a new product release?",
                        "category": "product_strategy",
                        "difficulty": "mid",
                        "skill_focus": "Product Management",
                        "expected_keywords": ["feature prioritization", "user value", "business impact", "technical complexity"]
                    },
                    {
                        "question": "Explain how you would measure the success of a new feature.",
                        "category": "product_strategy",
                        "difficulty": "mid",
                        "skill_focus": "Product Metrics",
                        "expected_keywords": ["KPIs", "user engagement", "conversion rates", "A/B testing", "metrics"]
                    }
                ]
            }
        ]
    
    def _generate_technical_lead_data(self) -> List[Dict[str, Any]]:
        """Generate technical lead interview data"""
        return [
            {
                "cv_text": """Technical Lead with 8 years of experience in software development and team leadership. 
                Expert in multiple programming languages and frameworks. Strong background in architecture design, 
                code review, and mentoring junior developers. Experience in agile methodologies and project management.""",
                "job_description": """Technical Lead. Requirements: Technical expertise, team leadership, architecture design, 
                mentoring, project management, 7+ years experience.""",
                "position": "Technical Lead",
                "level": "senior",
                "questions": [
                    {
                        "question": "How do you balance technical debt with feature development?",
                        "category": "leadership",
                        "difficulty": "senior",
                        "skill_focus": "Technical Leadership",
                        "expected_keywords": ["technical debt", "code quality", "refactoring", "business priorities"]
                    },
                    {
                        "question": "Describe your approach to conducting effective code reviews.",
                        "category": "leadership",
                        "difficulty": "mid",
                        "skill_focus": "Code Review",
                        "expected_keywords": ["code review", "best practices", "knowledge sharing", "quality assurance"]
                    }
                ]
            }
        ]
    
    def _generate_dba_data(self) -> List[Dict[str, Any]]:
        """Generate database administrator interview data"""
        return [
            {
                "cv_text": """Database Administrator with 6 years of experience in database design and optimization. 
                Expert in MySQL, PostgreSQL, and MongoDB. Strong background in performance tuning, backup strategies, 
                and database security. Experience with high-availability setups and disaster recovery.""",
                "job_description": """Database Administrator. Requirements: Database design, performance tuning, 
                backup/recovery, security, 5+ years experience.""",
                "position": "Database Administrator",
                "level": "senior",
                "questions": [
                    {
                        "question": "Explain database indexing strategies and their impact on performance.",
                        "category": "technical",
                        "difficulty": "senior",
                        "skill_focus": "Database Optimization",
                        "expected_keywords": ["indexing", "B-tree", "query optimization", "index selectivity"]
                    },
                    {
                        "question": "How would you design a database backup and recovery strategy?",
                        "category": "system_design",
                        "difficulty": "senior",
                        "skill_focus": "Backup Strategy",
                        "expected_keywords": ["backup types", "recovery time", "point-in-time recovery", "data integrity"]
                    }
                ]
            }
        ]
    
    def _generate_ai_research_data(self) -> List[Dict[str, Any]]:
        """Generate AI/ML research engineer interview data"""
        return [
            {
                "cv_text": """AI/ML Research Engineer with 4 years of experience in deep learning research and development. 
                Expert in PyTorch, TensorFlow, and research methodologies. Strong background in computer vision, 
                NLP, and model architecture design. Publications in top-tier conferences and experience with 
                large-scale model training.""",
                "job_description": """AI/ML Research Engineer. Requirements: Deep learning, research experience, 
                model development, publications, 3+ years experience.""",
                "position": "AI/ML Research Engineer",
                "level": "senior",
                "questions": [
                    {
                        "question": "Explain the transformer architecture and its key innovations.",
                        "category": "ml_theory",
                        "difficulty": "senior",
                        "skill_focus": "Deep Learning",
                        "expected_keywords": ["transformer", "attention mechanism", "self-attention", "positional encoding"]
                    },
                    {
                        "question": "How would you approach training a large language model from scratch?",
                        "category": "ml_engineering",
                        "difficulty": "senior",
                        "skill_focus": "Large Model Training",
                        "expected_keywords": ["distributed training", "gradient accumulation", "model parallelism", "data preprocessing"]
                    }
                ]
            }
        ]
    
    def _generate_junior_level_data(self) -> List[Dict[str, Any]]:
        """Generate junior level interview data across different roles"""
        return [
            {
                "cv_text": """Junior Frontend Developer with 1.5 years of experience building web applications with HTML, CSS, 
                JavaScript, and React. Familiar with responsive design, Git version control, and basic testing. 
                Recent computer science graduate with internship experience and several personal projects.""",
                "job_description": """Junior Frontend Developer. Requirements: HTML, CSS, JavaScript, React basics, 
                Git, responsive design, fresh graduate or 1-2 years experience.""",
                "position": "Junior Frontend Developer",
                "level": "junior",
                "questions": [
                    {
                        "question": "What is the difference between let, var, and const in JavaScript?",
                        "category": "technical",
                        "difficulty": "junior",
                        "skill_focus": "JavaScript Fundamentals",
                        "expected_keywords": ["var", "let", "const", "scope", "hoisting", "block scope"]
                    },
                    {
                        "question": "How do you center a div both horizontally and vertically in CSS?",
                        "category": "technical",
                        "difficulty": "junior",
                        "skill_focus": "CSS Layout",
                        "expected_keywords": ["flexbox", "grid", "center", "justify-content", "align-items"]
                    },
                    {
                        "question": "Explain what React components are and how props work?",
                        "category": "technical",
                        "difficulty": "junior",
                        "skill_focus": "React Basics",
                        "expected_keywords": ["components", "props", "JSX", "functional components", "reusable"]
                    }
                ]
            },
            {
                "cv_text": """Junior Backend Developer with 1 year of experience in Python and Django. Basic knowledge of 
                databases (PostgreSQL), RESTful APIs, and version control with Git. Computer science graduate 
                with strong foundation in algorithms and data structures.""",
                "job_description": """Junior Backend Developer. Requirements: Python, Django basics, database fundamentals, 
                REST API concepts, Git, fresh graduate or 1-2 years experience.""",
                "position": "Junior Backend Developer",
                "level": "junior",
                "questions": [
                    {
                        "question": "What is the difference between GET and POST HTTP methods?",
                        "category": "technical",
                        "difficulty": "junior",
                        "skill_focus": "HTTP Fundamentals",
                        "expected_keywords": ["GET", "POST", "HTTP methods", "idempotent", "data transmission"]
                    },
                    {
                        "question": "Explain what a database primary key is and why it's important?",
                        "category": "technical",
                        "difficulty": "junior",
                        "skill_focus": "Database Basics",
                        "expected_keywords": ["primary key", "unique", "identifier", "database design", "foreign key"]
                    },
                    {
                        "question": "How do you handle errors in Python code?",
                        "category": "technical",
                        "difficulty": "junior",
                        "skill_focus": "Error Handling",
                        "expected_keywords": ["try", "except", "finally", "exception handling", "error types"]
                    }
                ]
            },
            {
                "cv_text": """Junior QA Engineer with 8 months of experience in manual testing and basic test automation. 
                Familiar with test case design, bug reporting, and tools like Selenium. Engineering graduate 
                with ISTQB Foundation Level certification.""",
                "job_description": """Junior QA Engineer. Requirements: Manual testing, basic automation, test case design, 
                bug reporting, ISTQB certification preferred, entry level position.""",
                "position": "Junior QA Engineer",
                "level": "junior",
                "questions": [
                    {
                        "question": "What are the different types of software testing?",
                        "category": "testing_strategy",
                        "difficulty": "junior",
                        "skill_focus": "Testing Fundamentals",
                        "expected_keywords": ["unit testing", "integration testing", "system testing", "acceptance testing"]
                    },
                    {
                        "question": "Explain the difference between verification and validation in testing?",
                        "category": "testing_strategy",
                        "difficulty": "junior",
                        "skill_focus": "QA Concepts",
                        "expected_keywords": ["verification", "validation", "requirements", "testing process"]
                    }
                ]
            }
        ]
    
    def save_dataset(self, filename: str = "ai_interview_training_dataset.json"):
        """Save the complete dataset to JSON file"""
        dataset = self.generate_comprehensive_dataset()
        
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(dataset, f, indent=2, ensure_ascii=False)
        
        print(f"Dataset saved to {filename}")
        print(f"Total training examples: {len(dataset)}")
        print(f"Total positions covered: {len(self.positions)}")
        
        # Print statistics
        total_questions = sum(len(item['questions']) for item in dataset)
        print(f"Total questions: {total_questions}")
        
        return dataset

# Usage example
if __name__ == "__main__":
    dataset_generator = InterviewTrainingDataset()
    training_data = dataset_generator.save_dataset("/home/runner/work/Landing_page_tuyen_dung/Landing_page_tuyen_dung/ai-interview-system/data/ai_interview_training_dataset.json")