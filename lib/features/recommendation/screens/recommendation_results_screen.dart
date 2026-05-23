import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/custom_network_image.dart'; 
import '../providers/recommendation_provider.dart';
import '../models/recommended_course.dart';
import '../../courses/providers/course_provider.dart';
import '../../courses/models/course_model.dart';
import '../../courses/screens/course_detail_screen.dart';

class RecommendationResultsScreen extends StatelessWidget {
  const RecommendationResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recommendation = context.watch<RecommendationProvider>();

    if (recommendation.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Getting Recommendations...")),
        body: const LoadingWidget(),
      );
    }

    if (recommendation.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Recommendations")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Error: ${recommendation.error}",
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: "Try Again",
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Top 3 Recommendations"),
        backgroundColor: Colors.blue,
        actions: [
          TextButton(
            onPressed: () {
              recommendation.clearRecommendations();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/domain',
                (route) => route.isFirst,
              );
            },
            child: const Text("Retake Quiz", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: recommendation.recommendations.isEmpty
          ? const Center(
              child: Text("No recommendations found. Try adjusting your preferences."),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recommendation.recommendations.length,
              itemBuilder: (context, index) {
                final recCourse = recommendation.recommendations[index];
                return _buildCourseCard(context, recCourse, index + 1);
              },
            ),
    );
  }

  Widget _buildCourseCard(BuildContext context, RecommendedCourse recCourse, int rank) {
    final courseProvider = context.read<CourseProvider>();

    // Check if course is already enrolled
    final isEnrolled = courseProvider.enrolledCourses
        .any((c) => c.id == recCourse.id);

    final course = CourseModel(
      id: recCourse.id,
      title: recCourse.title,
      description: recCourse.description,
      imageUrl: recCourse.imageUrl,
      isFree: recCourse.isFree,
      price: recCourse.price,
      isEnrolled: isEnrolled,
    );

    String medal = '';
    Color medalColor = Colors.amber;
    if (rank == 1) {
      medal = '🥇';
      medalColor = Colors.amber.shade700;
    } else if (rank == 2) {
      medal = '🥈';
      medalColor = Colors.grey.shade600;
    } else if (rank == 3) {
      medal = '🥉';
      medalColor = Colors.brown.shade400;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseDetailScreen(course: course),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: rank == 1 ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: rank == 1 ? BorderSide(color: Colors.amber, width: 2) : BorderSide.none,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CustomNetworkImage(
                imageUrl: recCourse.imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                fallbackText: "No Image Available",
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "$medal ",
                        style: TextStyle(fontSize: 28, color: medalColor),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${recCourse.matchPercentage.toInt()}% Match",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
              
                  Text(
                    recCourse.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
               
                  Text(
                    recCourse.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  
                 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: course.isFree ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      course.isFree ? "FREE" : "PAID",
                      style: TextStyle(
                        fontSize: 12,
                        color: course.isFree ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
           
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: isEnrolled
                          ? "Continue Learning"
                          : (course.isFree ? "Enroll Now" : "View Details"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CourseDetailScreen(course: course),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}