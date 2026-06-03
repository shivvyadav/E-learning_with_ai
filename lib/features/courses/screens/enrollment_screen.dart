import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course_model.dart';
import '../providers/course_provider.dart';
import 'mock_payment_screen.dart';
import 'khalti_payment_screen.dart';
import 'my_courses_screen.dart'; // ADD THIS IMPORT

class EnrollmentScreen extends StatefulWidget {
  final CourseModel course;

  const EnrollmentScreen({super.key, required this.course});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  bool _isLoading = false;

  Future<void> _handleFreeEnrollment() async {
    setState(() => _isLoading = true);
    try {
      await context.read<CourseProvider>().enrollCourse(widget.course.id);

      if (!mounted) return;

      // CHANGED: Navigate to My Courses instead of popping to first screen

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Enrollment Successful"),
          content: const Text(
            "You are now enrolled in this course.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Navigate to My Courses screen and clear all previous routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyCoursesScreen(),
                  ),
                  (route) => route.isFirst,
                );
              },
              child: const Text("Go to My Learning"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enrollment failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enroll Course")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                
                  // Mock enrollment (existing demo flow)
                
                  if (widget.course.isFree)
                    ElevatedButton(
                      onPressed: _handleFreeEnrollment,
                      child: const Text("Enroll Now (Free)"),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MockPaymentScreen(
                              course: widget.course,
                            ),
                          ),
                        );
                      },
                      child: Text("Pay Rs.${widget.course.price}"),
                    ),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => KhaltiPaymentScreen(
                            course: widget.course,
                          ),
                        ),
                      );
                      if (result == true) {
                        _handleFreeEnrollment();
                      }
                    },
                    child: const Text('Real Pay (Khalti)'),
                  ),
                ],
              ),
      ),
    );
  }
}