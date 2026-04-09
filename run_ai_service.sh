#!/bin/bash
# Run the AI Recommendation Service

cd ai_recommendation

# Install dependencies if needed
pip install -r requirements.txt

# Run the Flask app
python app.py