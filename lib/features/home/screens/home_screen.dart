import 'package:e_learning_v1/app/routes.dart';
import 'package:e_learning_v1/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/custom_network_image.dart';
import '../../../state/app_state.dart';
import '../../../state/progress_provider.dart';

import '../../courses/providers/course_provider.dart';
import '../../courses/screens/course_list_screen.dart';
import '../../courses/screens/my_courses_screen.dart';
import '../../courses/screens/course_content_screen.dart';
import '../../courses/screens/course_detail_screen.dart';

import '../../profile/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, String>? _lastWatched;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final courseProvider =
          Provider.of<CourseProvider>(context, listen: false);
      final progressProvider =
          Provider.of<ProgressProvider>(context, listen: false);

      await courseProvider.loadCourses();

      final enrolledIds =
          courseProvider.enrolledCourses.map((e) => e.id).toList();
      await progressProvider.syncProgressFromBackend(enrolledIds);
    });

    _loadLastWatched();
  }

 
  // Pull to refresh functionality

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    try {
      final courseProvider = Provider.of<CourseProvider>(context, listen: false);
      final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
      
      await courseProvider.refreshCourses();
      
      final enrolledIds = courseProvider.enrolledCourses.map((e) => e.id).toList();
      await progressProvider.syncProgressFromBackend(enrolledIds);
      
      // Reload last watched
      await _loadLastWatched();
      
    } catch (e) {
      print("Error refreshing: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  String get displayName {
    final auth = context.read<AuthProvider>();
    final email = auth.currentUserEmail ?? "";
    final fallbackName = email.contains("@") ? email.split("@").first : email;
    return auth.currentUserName?.trim().isNotEmpty == true
        ? auth.currentUserName!
        : fallbackName;
  }

  Future<void> _loadLastWatched() async {
    final progress =
        Provider.of<ProgressProvider>(context, listen: false);

    final last = await progress.getLastWatched();

    if (mounted) {
      setState(() {
        _lastWatched = last;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final pages = [
      _buildHomeContent(),
      const CourseListScreen(),
      const MyCoursesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
  
      // NO AppBar - status bar still visible automatically

      body: pages[appState.currentIndex],
      floatingActionButton: appState.currentIndex == 0 ? FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/domain'),
        tooltip: 'Get AI Recommendations',
        child: const Icon(Icons.lightbulb),
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: appState.currentIndex,
        onTap: appState.changeIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.school), label: "Courses"),
          BottomNavigationBarItem(
              icon: Icon(Icons.play_circle),
              label: "My Learning"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    final courseProvider =
        Provider.of<CourseProvider>(context);

    final progressProvider =
        Provider.of<ProgressProvider>(context);

    final enrolledCourses =
        courseProvider.enrolledCourses;

    if (courseProvider.courses.isEmpty) {
      return const Center(
          child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: 48, // Add padding to avoid content touching status bar
          left: 16,
          right: 16,
          bottom: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getGreeting(),
                        style: const TextStyle(
                            color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      "$displayName 👋",
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    context
                        .read<AppState>()
                        .changeIndex(3);
                  },
                  child: const CircleAvatar(
                    radius: 22,
                    child: Icon(Icons.person),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            if (_lastWatched != null &&
                enrolledCourses.isNotEmpty)
              _buildPremiumContinueWatching(
                  courseProvider,
                  progressProvider),

            const SizedBox(height: 16),

            _buildAIRecommendationCard(),

            const SizedBox(height: 24),

            const Text(
              "Popular Courses",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:
                    courseProvider.courses.length,
                itemBuilder: (context, index) {
                  final course =
                      courseProvider.courses[index];

                  return Container(
                    width: 190,
                    margin:
                        const EdgeInsets.only(right: 14),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CourseDetailScreen(course: course),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    18)),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius
                                          .vertical(
                                      top:
                                          Radius.circular(
                                              18)),
                              child: CustomNetworkImage(
                                imageUrl: course.imageUrl,
                                height: 110,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                fallbackText: "No Image",
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.all(
                                      10),
                              child: Text(
                                course.title,
                                maxLines: 2,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const CourseListScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Explore All Courses →",
                  style: TextStyle(
                      fontWeight:
                          FontWeight.w600),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumContinueWatching(
      CourseProvider courseProvider,
      ProgressProvider progressProvider) {
    final courseId = _lastWatched!["courseId"];
    final lessonId = _lastWatched!["lessonId"];

    final course =
        courseProvider.getCourseById(courseId!);

    if (course == null) return const SizedBox();

    final totalLessons =
        courseProvider.getLessonCount(courseId);

    final progress =
        progressProvider.getCourseProgress(
            courseId, totalLessons);

    return Container(
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF141E30), Color(0xFF243B55)],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text("Continue Watching",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold)),
          const SizedBox(height: 6),
          Text(course.title,
              style: const TextStyle(
                  color: Colors.white)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
              value: progress),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CourseContentScreen(
                          course: course),
                ),
              );
            },
            child: const Text(
                "Continue Watching"),
          )
        ],
      ),
    );
  }

  Widget _buildAIRecommendationCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB),
            Color(0xFF2575FC)],
        ),
        borderRadius:
            BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Not sure what to learn next?",
            style: TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Get personalized course suggestions based on your learning progress.",
            style:
                TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/domain');
            },
            child: const Text(
              "Get AI Recommendation",
              style: TextStyle(
                  color: Colors.black),
            ),
          )
        ],
      ),
    );
  }
}