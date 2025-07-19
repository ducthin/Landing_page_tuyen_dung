"""
Dataset Validation Utilities for AI Interview Training System
Ensures data quality and consistency across training examples
"""

import json
import re
from typing import List, Dict, Any, Tuple
from dataclasses import dataclass

@dataclass
class ValidationResult:
    """Result of dataset validation"""
    is_valid: bool
    errors: List[str]
    warnings: List[str]
    statistics: Dict[str, Any]

class DatasetValidator:
    """Comprehensive validator for interview training dataset"""
    
    def __init__(self):
        self.required_fields = [
            'cv_text', 'job_description', 'position', 'level', 'questions'
        ]
        self.required_question_fields = [
            'question', 'category', 'difficulty', 'skill_focus', 'expected_keywords'
        ]
        self.valid_levels = ['junior', 'mid', 'senior']
        self.valid_categories = [
            'technical', 'system_design', 'performance', 'security', 
            'best_practices', 'problem_solving', 'ml_theory', 'mlops',
            'statistics', 'experimentation', 'testing_strategy', 
            'troubleshooting', 'product_strategy', 'leadership',
            'ml_engineering', 'monitoring'
        ]
        self.valid_difficulties = ['junior', 'mid', 'senior']
        
    def validate_dataset(self, dataset_path: str) -> ValidationResult:
        """Validate complete dataset file"""
        try:
            with open(dataset_path, 'r', encoding='utf-8') as f:
                dataset = json.load(f)
        except Exception as e:
            return ValidationResult(
                is_valid=False,
                errors=[f"Failed to load dataset: {str(e)}"],
                warnings=[],
                statistics={}
            )
        
        errors = []
        warnings = []
        statistics = self._calculate_statistics(dataset)
        
        # Validate dataset structure
        if not isinstance(dataset, list):
            errors.append("Dataset must be a list of training examples")
            return ValidationResult(False, errors, warnings, statistics)
        
        if len(dataset) == 0:
            errors.append("Dataset is empty")
            return ValidationResult(False, errors, warnings, statistics)
        
        # Validate each training example
        for i, example in enumerate(dataset):
            example_errors, example_warnings = self._validate_example(example, i)
            errors.extend(example_errors)
            warnings.extend(example_warnings)
        
        # Additional dataset-level validations
        dataset_errors, dataset_warnings = self._validate_dataset_completeness(dataset)
        errors.extend(dataset_errors)
        warnings.extend(dataset_warnings)
        
        is_valid = len(errors) == 0
        
        return ValidationResult(is_valid, errors, warnings, statistics)
    
    def _validate_example(self, example: Dict[str, Any], index: int) -> Tuple[List[str], List[str]]:
        """Validate individual training example"""
        errors = []
        warnings = []
        prefix = f"Example {index}: "
        
        # Check required fields
        for field in self.required_fields:
            if field not in example:
                errors.append(f"{prefix}Missing required field '{field}'")
            elif not example[field]:
                errors.append(f"{prefix}Field '{field}' is empty")
        
        if 'level' in example and example['level'] not in self.valid_levels:
            errors.append(f"{prefix}Invalid level '{example['level']}'. Must be one of {self.valid_levels}")
        
        # Validate CV text quality
        if 'cv_text' in example:
            cv_errors, cv_warnings = self._validate_cv_text(example['cv_text'], prefix)
            errors.extend(cv_errors)
            warnings.extend(cv_warnings)
        
        # Validate job description
        if 'job_description' in example:
            jd_errors, jd_warnings = self._validate_job_description(example['job_description'], prefix)
            errors.extend(jd_errors)
            warnings.extend(jd_warnings)
        
        # Validate questions
        if 'questions' in example:
            q_errors, q_warnings = self._validate_questions(example['questions'], prefix)
            errors.extend(q_errors)
            warnings.extend(q_warnings)
        
        return errors, warnings
    
    def _validate_cv_text(self, cv_text: str, prefix: str) -> Tuple[List[str], List[str]]:
        """Validate CV text content"""
        errors = []
        warnings = []
        
        if len(cv_text) < 100:
            warnings.append(f"{prefix}CV text is quite short ({len(cv_text)} chars). Consider adding more detail.")
        
        if len(cv_text) > 2000:
            warnings.append(f"{prefix}CV text is very long ({len(cv_text)} chars). Consider condensing.")
        
        # Check for essential CV components
        experience_patterns = [
            r'\d+\s*years?\s*of\s*experience',
            r'\d+\+\s*years?',
            r'experience\s+in',
            r'background\s+in'
        ]
        
        has_experience = any(re.search(pattern, cv_text.lower()) for pattern in experience_patterns)
        if not has_experience:
            warnings.append(f"{prefix}CV text should mention years of experience")
        
        # Check for technical skills
        if not re.search(r'(python|java|javascript|react|node|aws|docker|kubernetes)', cv_text.lower()):
            warnings.append(f"{prefix}CV text should include relevant technical skills")
        
        return errors, warnings
    
    def _validate_job_description(self, job_desc: str, prefix: str) -> Tuple[List[str], List[str]]:
        """Validate job description content"""
        errors = []
        warnings = []
        
        if len(job_desc) < 50:
            warnings.append(f"{prefix}Job description is quite short. Consider adding more requirements.")
        
        if 'requirements:' not in job_desc.lower():
            warnings.append(f"{prefix}Job description should clearly state requirements")
        
        return errors, warnings
    
    def _validate_questions(self, questions: List[Dict[str, Any]], prefix: str) -> Tuple[List[str], List[str]]:
        """Validate interview questions"""
        errors = []
        warnings = []
        
        if not isinstance(questions, list):
            errors.append(f"{prefix}Questions must be a list")
            return errors, warnings
        
        if len(questions) < 2:
            warnings.append(f"{prefix}Consider adding more questions (currently {len(questions)})")
        
        if len(questions) > 10:
            warnings.append(f"{prefix}Too many questions ({len(questions)}). Consider reducing to 5-8.")
        
        for i, question in enumerate(questions):
            q_prefix = f"{prefix}Question {i+1}: "
            
            # Check required question fields
            for field in self.required_question_fields:
                if field not in question:
                    errors.append(f"{q_prefix}Missing required field '{field}'")
                elif not question[field]:
                    errors.append(f"{q_prefix}Field '{field}' is empty")
            
            # Validate question content
            if 'question' in question:
                if len(question['question']) < 20:
                    warnings.append(f"{q_prefix}Question text is quite short")
                if not question['question'].endswith('?'):
                    warnings.append(f"{q_prefix}Question should end with '?'")
            
            # Validate category
            if 'category' in question and question['category'] not in self.valid_categories:
                errors.append(f"{q_prefix}Invalid category '{question['category']}'. Must be one of {self.valid_categories}")
            
            # Validate difficulty
            if 'difficulty' in question and question['difficulty'] not in self.valid_difficulties:
                errors.append(f"{q_prefix}Invalid difficulty '{question['difficulty']}'. Must be one of {self.valid_difficulties}")
            
            # Validate expected keywords
            if 'expected_keywords' in question:
                keywords = question['expected_keywords']
                if not isinstance(keywords, list):
                    errors.append(f"{q_prefix}Expected keywords must be a list")
                elif len(keywords) < 2:
                    warnings.append(f"{q_prefix}Consider adding more expected keywords (currently {len(keywords)})")
                elif len(keywords) > 10:
                    warnings.append(f"{q_prefix}Too many expected keywords ({len(keywords)}). Consider reducing.")
        
        return errors, warnings
    
    def _validate_dataset_completeness(self, dataset: List[Dict[str, Any]]) -> Tuple[List[str], List[str]]:
        """Validate dataset completeness and coverage"""
        errors = []
        warnings = []
        
        # Check position coverage
        positions = [example.get('position', '') for example in dataset]
        unique_positions = set(positions)
        
        if len(unique_positions) < 10:
            warnings.append(f"Dataset covers only {len(unique_positions)} positions. Consider adding more variety.")
        
        # Check level distribution
        levels = [example.get('level', '') for example in dataset]
        level_counts = {level: levels.count(level) for level in self.valid_levels}
        
        for level in self.valid_levels:
            if level_counts[level] == 0:
                warnings.append(f"No examples for '{level}' level. Consider adding some.")
        
        # Check question category distribution
        all_categories = []
        for example in dataset:
            questions = example.get('questions', [])
            for question in questions:
                all_categories.append(question.get('category', ''))
        
        category_counts = {cat: all_categories.count(cat) for cat in self.valid_categories}
        missing_categories = [cat for cat, count in category_counts.items() if count == 0]
        
        if missing_categories:
            warnings.append(f"Missing question categories: {missing_categories}")
        
        return errors, warnings
    
    def _calculate_statistics(self, dataset: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Calculate dataset statistics"""
        if not dataset:
            return {}
        
        stats = {
            'total_examples': len(dataset),
            'total_questions': 0,
            'positions': {},
            'levels': {},
            'categories': {},
            'difficulties': {},
            'avg_questions_per_example': 0,
            'avg_cv_length': 0,
            'avg_jd_length': 0
        }
        
        cv_lengths = []
        jd_lengths = []
        all_questions = []
        
        for example in dataset:
            # CV and JD lengths
            if 'cv_text' in example:
                cv_lengths.append(len(example['cv_text']))
            if 'job_description' in example:
                jd_lengths.append(len(example['job_description']))
            
            # Position and level counts
            position = example.get('position', 'Unknown')
            level = example.get('level', 'Unknown')
            
            stats['positions'][position] = stats['positions'].get(position, 0) + 1
            stats['levels'][level] = stats['levels'].get(level, 0) + 1
            
            # Question statistics
            questions = example.get('questions', [])
            all_questions.extend(questions)
            
            for question in questions:
                category = question.get('category', 'Unknown')
                difficulty = question.get('difficulty', 'Unknown')
                
                stats['categories'][category] = stats['categories'].get(category, 0) + 1
                stats['difficulties'][difficulty] = stats['difficulties'].get(difficulty, 0) + 1
        
        stats['total_questions'] = len(all_questions)
        stats['avg_questions_per_example'] = len(all_questions) / len(dataset) if dataset else 0
        stats['avg_cv_length'] = sum(cv_lengths) / len(cv_lengths) if cv_lengths else 0
        stats['avg_jd_length'] = sum(jd_lengths) / len(jd_lengths) if jd_lengths else 0
        
        return stats
    
    def print_validation_report(self, result: ValidationResult):
        """Print comprehensive validation report"""
        print("=" * 80)
        print("AI INTERVIEW DATASET VALIDATION REPORT")
        print("=" * 80)
        
        print(f"\n✅ VALIDATION STATUS: {'PASSED' if result.is_valid else '❌ FAILED'}")
        
        if result.errors:
            print(f"\n❌ ERRORS ({len(result.errors)}):")
            for error in result.errors:
                print(f"  • {error}")
        
        if result.warnings:
            print(f"\n⚠️  WARNINGS ({len(result.warnings)}):")
            for warning in result.warnings:
                print(f"  • {warning}")
        
        if result.statistics:
            print(f"\n📊 DATASET STATISTICS:")
            stats = result.statistics
            print(f"  • Total Examples: {stats.get('total_examples', 0)}")
            print(f"  • Total Questions: {stats.get('total_questions', 0)}")
            print(f"  • Average Questions per Example: {stats.get('avg_questions_per_example', 0):.1f}")
            print(f"  • Average CV Length: {stats.get('avg_cv_length', 0):.0f} characters")
            print(f"  • Average Job Description Length: {stats.get('avg_jd_length', 0):.0f} characters")
            
            print(f"\n  📍 Position Coverage ({len(stats.get('positions', {}))}):")
            for position, count in stats.get('positions', {}).items():
                print(f"    • {position}: {count}")
            
            print(f"\n  📊 Level Distribution:")
            for level, count in stats.get('levels', {}).items():
                print(f"    • {level}: {count}")
            
            print(f"\n  🏷️  Category Distribution:")
            for category, count in sorted(stats.get('categories', {}).items()):
                print(f"    • {category}: {count}")
        
        print("\n" + "=" * 80)

# Usage example
if __name__ == "__main__":
    validator = DatasetValidator()
    
    # Validate the dataset
    dataset_path = "/home/runner/work/Landing_page_tuyen_dung/Landing_page_tuyen_dung/ai-interview-system/data/ai_interview_training_dataset.json"
    result = validator.validate_dataset(dataset_path)
    
    # Print validation report
    validator.print_validation_report(result)
    
    # Return exit code based on validation result
    exit(0 if result.is_valid else 1)