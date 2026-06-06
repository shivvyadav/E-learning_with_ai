import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/custom_network_image.dart';
import '../providers/course_provider.dart';
import '../../../state/progress_provider.dart';
import 'course_content_screen.dart';
import '../../../app/routes.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  bool _hasRefreshed = false; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasRefreshed) {
      _hasRefreshed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onRefresh(context);
      });
    }
  }

  Future<void> _onRefresh(BuildContext context) async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    
    await courseProvider.refreshCourses();
    
    final enrolledIds = courseProvider.enrolledCourses.map((e) => e.id).toList();
    await progressProvider.syncProgressFromBackend(enrolledIds);
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final progressProvider = context.watch<ProgressProvider>();

    final enrolledCourses = courseProvider.enrolledCourses;

    if (enrolledCourses.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Learning")),
        body: RefreshIndicator(
          onRefresh: () => _onRefresh(context),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school_outlined,
                      size: 60,
                      color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "You haven’t enrolled in any course yet.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, AppRoutes.courses);
                    },
                    child: const Text("Browse Courses"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final activeCourses = enrolledCourses.where((c) {
      final total = courseProvider.getLessonCount(c.id);
      final progress = progressProvider.getCourseProgress(c.id, total);
      return progress < 1;
    }).toList();

    final completedCourses = enrolledCourses.where((c) {
      final total = courseProvider.getLessonCount(c.id);
      final progress = progressProvider.getCourseProgress(c.id, total);
      return progress == 1;
    }).toList();

    final totalLessons = enrolledCourses.fold<int>(
      0,
      (sum, course) => sum + courseProvider.getLessonCount(course.id),
    );

    final completedLessons = enrolledCourses.fold<int>(
      0,
      (sum, course) => sum + progressProvider.getCompletedLessonCount(course.id),
    );

    final overallProgress = totalLessons == 0
        ? 0
        : (completedLessons / totalLessons * 100).toInt();

    return Scaffold(
      appBar: AppBar(title: const Text("My Learning")),
      body: RefreshIndicator(
        onRefresh: () => _onRefresh(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _statCard("Active", activeCourses.length.toString()),
                  const SizedBox(width: 12),
                  _statCard("Completed", completedCourses.length.toString()),
                  const SizedBox(width: 12),
                  _statCard("Progress", "$overallProgress%"),
                ],
              ),

              const SizedBox(height: 24),

              if (activeCourses.isNotEmpty) ...[
                const Text(
                  "Continue Learning",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...activeCourses.map((course) {
                  final total = courseProvider.getLessonCount(course.id);
                  final progress = progressProvider.getCourseProgress(course.id, total);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CustomNetworkImage(
                              imageUrl: course.imageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              fallbackText: "No Image",
                              showText: false,
                            ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(value: progress),
                                const SizedBox(height: 6),
                                Text("${(progress * 100).toInt()}% completed"),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CourseContentScreen(
                                            course: course,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text("Continue"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],

              if (completedCourses.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  "Completed Courses",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...completedCourses.map((course) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CustomNetworkImage(
                          imageUrl: course.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          fallbackText: "",
                          showText: false,
                        ),
                      ),
                      title: Text(
                        course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: const Text("Completed"),
                      trailing: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CourseContentScreen(course: course),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// STAT CARD
  Widget _statCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}