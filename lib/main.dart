import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/widgets/app_wrapper.dart'; // ADDED
import 'state/app_state.dart';
import 'state/progress_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/courses/providers/course_provider.dart';
import 'features/courses/providers/lesson_provider.dart';
import 'features/recommendation/providers/questionnaire_provider.dart';
import 'features/recommendation/providers/recommendation_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //to ensure flutter is ready before running init

  final progressProvider = ProgressProvider();
  await progressProvider.init();

  runApp(AppRoot(progressProvider: progressProvider));
}

class AppRoot extends StatelessWidget {
  final ProgressProvider progressProvider;

  const AppRoot({super.key, required this.progressProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => LessonProvider()),
        ChangeNotifierProvider(create: (_) => progressProvider),
        ChangeNotifierProvider(create: (_) => QuestionnaireProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
      ],
      child: const AppWrapper(), // Clean and simple!
    );
  }
}