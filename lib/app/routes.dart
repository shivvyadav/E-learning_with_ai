import 'package:e_learning_v1/features/recommendation/screens/recommendation_screen.dart';
import 'package:flutter/material.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/courses/screens/course_list_screen.dart';
import '../features/courses/screens/my_courses_screen.dart';
import '../features/profile/screens/profile_screen.dart';

import '../features/recommendation/screens/domain_screen.dart';
import '../features/recommendation/screens/intensity_screen.dart';
import '../features/recommendation/screens/outcome_screen.dart';
import '../features/recommendation/screens/pedagogy_screen.dart';
import '../features/recommendation/screens/role_screen.dart';
import '../features/recommendation/screens/timeframe_screen.dart';
import '../features/recommendation/screens/recommendation_results_screen.dart';

class AppRoutes {
  // Main routes
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const courses = '/courses';
  static const myCourses = '/my_courses';
  static const profile = '/profile';
    static const recommendation = '/recommendation';

  // New Recommendation routes (6 questions)
  static const domain = '/domain';
  static const intensity = '/intensity';
  static const outcome = '/outcome';
  static const pedagogy = '/pedagogy';
  static const role = '/role';
  static const timeframe = '/timeframe';
  static const recommendationResults = '/recommendation-results';

  static final routes = {
    // Main routes
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    courses: (context) => const CourseListScreen(),
    myCourses: (context) => const MyCoursesScreen(),
    profile: (context) => const ProfileScreen(),
    recommendation: (context) => const RecommendationScreen(),

    // New Recommendation routes (6 questions)
    domain: (context) => const DomainScreen(),
    intensity: (context) => const IntensityScreen(),
    outcome: (context) => const OutcomeScreen(),
    pedagogy: (context) => const PedagogyScreen(),
    role: (context) => const RoleScreen(),
    timeframe: (context) => const TimeframeScreen(),
    recommendationResults: (context) => const RecommendationResultsScreen(),
  };
}