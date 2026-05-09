from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import os
import requests
import re

app = Flask(__name__)
CORS(app)


# Backend API URL of node.js

BACKEND_URL = "http://localhost:3000/api"

# Load Course Data from CSV

current_dir = os.path.dirname(os.path.abspath(__file__))
csv_path = os.path.join(current_dir, 'course_catalog.csv')
courses_df = pd.read_csv(csv_path)
courses_df['course_id'] = courses_df['course_id'].astype(str)

# Clean CSV course titles (remove leading/trailing spaces)
courses_df['course_name'] = courses_df['course_name'].str.strip()

print(f"✅ Loaded {len(courses_df)} courses from CSV")


# Helper Function: Normalize Title

def normalize_title(title):
    """
    Normalize course title for matching:
    - Convert to lowercase
    - Remove leading/trailing spaces
    - Remove extra spaces between words
    """
    if not title:
        return ""
    # Strip leading/trailing spaces and convert to lowercase
    normalized = title.strip().lower()
    # Replace multiple spaces with single space
    normalized = re.sub(r'\s+', ' ', normalized)
    return normalized


# Create combined text for TF-IDF Vectorization

def create_course_text(course):
    """Convert course attributes into a single text string for TF-IDF"""
    text_parts = [
        course['domain'],
        course['intensity'],
        course['outcome'],
        course['pedagogy'],
        course['role'],
        course['timeframe']
    ]
    return " ".join(text_parts)

def user_preferences_to_text(user_data):
    """Convert user preferences into a text string for TF-IDF"""
    text_parts = [
        user_data['domain'],
        user_data['intensity'],
        user_data['outcome'],
        user_data['pedagogy'],
        user_data['role'],
        user_data['timeframe']
    ]
    return " ".join(text_parts)

# Create text features for all courses
courses_df['combined_text'] = courses_df.apply(create_course_text, axis=1)

# Initialize and fit TF-IDF Vectorizer
vectorizer = TfidfVectorizer()
course_vectors = vectorizer.fit_transform(courses_df['combined_text'])

print(f"Created {course_vectors.shape[1]} dimensional vectors for {len(courses_df)} courses")
print(f"Sample course text: {courses_df['combined_text'].iloc[0]}")


# Fetch Real Courses from Backend

def fetch_real_courses():
    """Fetch actual courses from Node.js backend"""
    try:
        print("Fetching real courses from backend...")
        response = requests.get(f"{BACKEND_URL}/courses", timeout=5)
        
        if response.status_code == 200:
            data = response.json()
            courses = data.get("data", [])
            print(f"Found {len(courses)} real courses in backend")
            
            # Create a dictionary for quick lookup by normalized title
            course_lookup = {}
            for course in courses:
                # Get course title (handle different field names)
                title = course.get("title") or course.get("Coursename", "")
                
                # Clean the title (strip spaces, normalize)
                clean_title = normalize_title(title)
                
                if clean_title:
                    # Store course details with normalized title as key
                    course_lookup[clean_title] = {
                        "id": str(course.get("id") or course.get("_id", "")),
                        "title": title,  # Keep original title
                        "description": course.get("description") or course.get("Coursedescription", ""),
                        "imageUrl": course.get("imageUrl") or course.get("coursethumbnail", ""),
                        "isFree": course.get("isFree", False) or (course.get("CoursePrice", 0) == 0),
                        "price": float(course.get("price") or course.get("CoursePrice", 0))
                    }
                    
                    print(f"Indexed: '{clean_title}'")
            
            print(f"reated lookup for {len(course_lookup)} courses")
            return course_lookup
        else:
            print(f"Backend returned status: {response.status_code}")
            return {}
            
    except Exception as e:
        print(f"❌ Error fetching real courses: {e}")
        return {}


# UPDATED: Calculate Cosine Similarity

def calculate_similarity(user_prefs, course_index):
    """
    Calculate cosine similarity between user preferences and a course
    """
    try:
        # Convert user preferences to text and vectorize
        user_text = user_preferences_to_text(user_prefs)
        user_vector = vectorizer.transform([user_text])
        
        # Get course vector
        course_vector = course_vectors[course_index]
        
        # Calculate cosine similarity
        similarity = cosine_similarity(user_vector, course_vector)[0][0]
        
        return similarity
        
    except Exception as e:
        print(f"Error calculating cosine similarity: {e}")
        return 0.3


# API Endpoints

@app.route('/', methods=['GET'])
def home():
    return jsonify({
        'status': 'running',
        'courses_loaded': len(courses_df),
        'algorithm': 'TF-IDF + Cosine Similarity'
    })

@app.route('/recommend', methods=['POST'])
def recommend():
    try:
        # Step 1: Get user preferences, this contains 6 answers
        user_data = request.get_json()
        print(f"\nReceived user preferences: {user_data}")
        
        # Step 2: Validate input
        required = ['domain', 'intensity', 'outcome', 'pedagogy', 'role', 'timeframe']
        for field in required:
            if field not in user_data:
                return jsonify({'success': False, 'message': f'Missing {field}'}), 400
        
        # Step 3: Fetch real courses from backend
        real_courses = fetch_real_courses()
        
        # Step 4: Calculate cosine similarity for all CSV courses
        results = []
        for idx, (_, course) in enumerate(courses_df.iterrows()):
            # Calculate cosine similarity score
            score = calculate_similarity(user_data, idx)
            
            # Get course title from CSV (already cleaned)
            course_title = course['course_name']
            
            # Normalize CSV title for matching
            normalized_csv_title = normalize_title(course_title)
            
            # Step 5: Check if this course exists in backend using normalized title
            real_course = real_courses.get(normalized_csv_title)
            
            if real_course:
                # Course found in backend - use real data
                results.append({
                    'id': real_course['id'],
                    'title': real_course['title'],
                    'description': real_course['description'],
                    'imageUrl': real_course['imageUrl'],
                    'isFree': real_course['isFree'],
                    'price': real_course['price'],
                    'similarity': score,
                    'matchPercentage': round(score * 100, 1)
                })
                print(f"Matched: '{course_title}' → Found in backend | Score: {score:.3f}")
            else:
                # Course not in backend - use CSV data as fallback
                print(f"Not found: '{course_title}' → Using CSV fallback | Score: {score:.3f}")
                results.append({
                    'id': course['course_id'],
                    'title': course_title,
                    'description': f"A {course['domain']} course for {course['outcome']}",
                    'imageUrl': '',
                    'isFree': True,
                    'price': 0,
                    'similarity': score,
                    'matchPercentage': round(score * 100, 1)
                })
        
        # Step 6: Sort and get top 3
        results.sort(key=lambda x: x['similarity'], reverse=True)
        top_3 = results[:3]
        
        print(f"\nTop 3 Recommendations (Cosine Similarity):")
        for i, rec in enumerate(top_3, 1):
            print(f"   {i}. {rec['title']} - {rec['matchPercentage']}%")
        
        return jsonify({
            'success': True,
            'recommendations': top_3,
            'algorithm': 'Cosine Similarity'
        })
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({'success': False, 'message': str(e)}), 500

if __name__ == '__main__':
    print("\n" + "="*60)
    print("AI RECOMMENDATION MICROSERVICE")
    print("="*60)
    print(f"Loaded {len(courses_df)} courses from CSV")
    print(f"Algorithm: TF-IDF Vectorization + Cosine Similarity")
    print("Backend URL: " + BACKEND_URL)
    print("Server: http://127.0.0.1:5000")
    print("="*60 + "\n")
    app.run(host='0.0.0.0', port=5000, debug=True)