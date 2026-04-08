# 📚 EduLearn — AI-Powered E-Learning Platform

A full-stack mobile e-learning platform with an intelligent course recommendation engine, built with **Flutter**, **Node.js**, and **Python**.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter)
![Node.js](https://img.shields.io/badge/Node.js-18.x-339933?style=flat&logo=node.js)
![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=flat&logo=python)
![MongoDB](https://img.shields.io/badge/MongoDB-6.x-47A248?style=flat&logo=mongodb)
![License](https://img.shields.io/badge/License-Academic-blue?style=flat)

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [AI Recommendation System](#-ai-recommendation-system)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [API Reference](#-api-reference)
- [Database Schema](#-database-schema)
- [Screenshots](#-screenshots)
- [Contributing](#-contributing)

---

## 🎯 Overview

EduLearn is a mobile-first e-learning platform that allows students to browse, purchase, and complete video-based courses. At its core is an AI recommendation engine that personalizes course suggestions based on a short user questionnaire — matching learners with courses most aligned to their goals, learning style, and domain of interest.

---

## ✨ Features

| Feature | Description |
|---|---|
| 📱 Mobile App | Browse courses, watch lessons, track progress (Flutter) |
| 🤖 AI Recommendations | Personalized top-3 course suggestions via TF-IDF + Cosine Similarity |
| 💳 Payment Integration | Secure course purchases via Khalti payment gateway |
| 📊 Progress Tracking | Per-lesson completion tracking and course progress |
| 🔐 Authentication | JWT-based login, registration, and OTP password reset |
| 🖥️ Admin Panel | Web dashboard for managing users, courses, and analytics (React) |

---

## 🏗️ Architecture

```
┌──────────────────────────────────────┐
│         Flutter Mobile App           │
│          (Student Interface)         │
└──────────────────┬───────────────────┘
                   │ REST API
                   ▼
┌──────────────────────────────────────┐
│       Node.js + Express Backend      │
│   (Auth, Courses, Payments, DB)      │
└────────────┬─────────────────────────┘
             │                │
             ▼                ▼
    ┌─────────────┐   ┌───────────────────────┐
    │   MongoDB   │   │  Python AI Microservice│
    │  (Primary   │   │  Flask + TF-IDF +      │
    │  Database)  │   │  Cosine Similarity     │
    └─────────────┘   │  Port 5000             │
                      └───────────────────────┘
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Mobile Frontend | Flutter, Dart |
| Web Admin Panel | React.js |
| Backend API | Node.js, Express.js |
| Database | MongoDB |
| AI / ML | Python, Flask, scikit-learn, Pandas |
| Payment | Khalti API |
| Authentication | JWT, bcrypt |

---

## 🤖 AI Recommendation System

The recommendation engine uses **Content-Based Filtering** powered by **TF-IDF vectorization** and **cosine similarity**.

### How It Works

1. **Questionnaire** — The user answers 6 short questions about their preferences:

   | Question | Options (examples) |
   |---|---|
   | Domain | Technical, Creative, Business, etc. |
   | Intensity | Light, Standard, Intensive |
   | Outcome | Career growth, Passion project, Entrepreneurship |
   | Pedagogy | Structured, Exploratory, Hybrid |
   | Role | Problem-solving, Creating, Leading, etc. |
   | Timeframe | Short-term, Balanced, Long-term |

2. **Vectorization** — User preferences and course attributes are converted to numerical vectors using TF-IDF.

3. **Similarity Scoring** — Cosine similarity is computed between the user vector and each course vector:

$$\cos(\theta) = \frac{A \cdot B}{\|A\| \times \|B\|}$$

4. **Result** — Top 3 courses with the highest match scores (0–100%) are returned.

### Example Request & Response

```bash
curl -X POST http://localhost:5000/recommend \
  -H "Content-Type: application/json" \
  -d '{
    "domain": "technical",
    "intensity": "standard",
    "outcome": "career",
    "pedagogy": "structured",
    "role": "problem_solving",
    "timeframe": "balanced"
  }'
```

```json
{
  "success": true,
  "recommendations": [
    { "title": "Python Basics", "matchPercentage": 95.2 },
    { "title": "JavaScript Fundamentals", "matchPercentage": 94.8 },
    { "title": "Data Structures & Algorithms", "matchPercentage": 87.6 }
  ]
}
```

---

## 📁 Project Structure

```
e-learning-platform/
├── e_learning_v1/           # Flutter mobile app
│   └── lib/
│       ├── features/
│       │   ├── auth/         # Login & Registration
│       │   ├── courses/      # Browsing & Enrollment
│       │   ├── home/         # Home screen
│       │   ├── profile/      # User profile
│       │   ├── recommendation/ # AI questionnaire (6 screens)
│       │   └── settings/     # App settings
│       ├── core/             # Services, widgets, utilities
│       └── state/            # App-level state management
│
├── backend/                 # Node.js REST API
│   ├── src/
│   │   ├── controllers/      # Route logic
│   │   ├── models/           # MongoDB schemas
│   │   ├── routes/           # API endpoints
│   │   └── middlewares/      # Auth, file upload
│   └── uploads/              # Course images & videos
│
├── ai_recommendation/       # Python AI microservice
│   ├── app.py                # Flask API (TF-IDF + Cosine Similarity)
│   ├── course_catalog.csv    # 50 courses with 6 attributes
│   └── requirements.txt
│
└── admin_panel/             # React web admin panel
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.x
- [Node.js](https://nodejs.org/) 18.x or higher
- [MongoDB](https://www.mongodb.com/) (local or Atlas)
- [Python](https://www.python.org/) 3.10 or higher

### 1. Clone the Repository

```bash
git clone https://github.com/prateekkoirala/e-learning-app.git
cd e-learning-app
```

### 2. Backend Setup

```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your MongoDB URI and JWT secret
npm start
# Runs on http://localhost:3000
```


**Required `.env` variables:**

```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/e-learning
JWT_SECRET=your_jwt_secret_here
KHALTI_SECRET_KEY=your_khalti_secret_key_here
```

### 3. AI Recommendation Service

```bash
cd ai_recommendation
pip install -r requirements.txt
python app.py
# Runs on http://localhost:5000
```

### 4. Flutter Mobile App

```bash
cd e_learning_v1
flutter pub get
flutter run
```

> **Real device testing:** Update your local IP in `lib/core/config/network_config.dart`:
> ```dart
> static const String computerIp = "YOUR_COMPUTER_IP"; // e.g. 192.168.1.65
> ```
> The Android emulator automatically uses `10.0.2.2`.

### 5. Admin Panel

```bash
cd frontend
npm install
npm run dev
```

---

## 📡 API Reference

### Authentication

| Endpoint | Method | Description |
|---|---|---|
| `/api/auth/register` | POST | Register new user |
| `/api/auth/login` | POST | Login and get JWT |
| `/api/auth/forgotpassword` | POST | Send OTP to email |
| `/api/auth/verifyotp` | POST | Verify OTP |
| `/api/auth/resetpassword` | POST | Reset user password |

### Courses

| Endpoint | Method | Description |
|---|---|---|
| `/api/courses` | GET | Get all courses |
| `/api/course/:id/lessons` | GET | Get lessons for a course |
| `/api/enroll` | POST | Enroll in a course |
| `/api/my-enrollments` | GET | Get enrolled courses |

### Progress

| Endpoint | Method | Description |
|---|---|---|
| `/api/updateprogress` | POST | Mark a lesson as complete |
| `/api/updateprogress/:courseId` | GET | Get progress for a course |

### Payment (Khalti)

| Endpoint | Method | Description |
|---|---|---|
| `/api/courseSelect` | POST | Create payment record |
| `/api/payment` | POST | Initiate Khalti payment |
| `/api/verify` | POST | Verify payment status |

### AI Recommendation Service

| Endpoint | Method | Description |
|---|---|---|
| `http://localhost:5000/recommend` | POST | Get top 3 course recommendations |
| `http://localhost:5000/` | GET | Health check |

---

## 🗄️ Database Schema

<details>
<summary><strong>User</strong></summary>

```js
{
  username:        String,
  useremail:       String,
  userpassword:    String,  // bcrypt hashed
  userphonenumber: Number,
  profileimage:    String,
  role:            String   // "customer" | "admin"
}
```
</details>

<details>
<summary><strong>Course</strong></summary>

```js
{
  title:       String,
  description: String,
  price:       Number,
  isFree:      Boolean,
  imageUrl:    String,
  domain:      String,
  intensity:   String,
  outcome:     String,
  pedagogy:    String,
  role:        String,
  timeframe:   String
}
```
</details>

<details>
<summary><strong>Enrollment</strong></summary>

```js
{
  user:         ObjectId,  // ref: User
  course:       ObjectId,  // ref: Course
  enrolleddate: Date,
  status:       String,    // "active" | "completed"
  progress:     Number     // 0–100
}
```
</details>

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m "Add: your feature description"`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

---

## 📄 License

This project was developed as an academic project for educational purposes.

---

## 📬 Contact

**Prateek Koirala**

GitHub: [@prateekkoirala](https://github.com/prateekkoirala)

---

> ⭐ If you found this project helpful, consider giving it a star!
