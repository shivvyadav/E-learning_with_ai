import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course_model.dart';
import '../providers/course_provider.dart';
import 'my_courses_screen.dart'; // ADD THIS IMPORT

class MockPaymentScreen extends StatefulWidget {
  final CourseModel course;

  const MockPaymentScreen({super.key, required this.course});

  @override
  State<MockPaymentScreen> createState() => _MockPaymentScreenState();
}

class _MockPaymentScreenState extends State<MockPaymentScreen> {
  bool _isLoading = false;

  Future<void> _pay() async {
    setState(() => _isLoading = true);
    try {
      await context.read<CourseProvider>().enrollCourse(widget.course.id);

      if (!mounted) return;


      // Navigate to My Courses instead of popping to first screen

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Payment Successful"),
          content: const Text("You successfully purchased the course."),
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
        SnackBar(content: Text('Payment failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                child: Text("Pay Rs.${widget.course.price}"),
                onPressed: _pay,
              ),
      ),
    );
  }
}