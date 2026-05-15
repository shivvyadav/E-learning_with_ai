import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/courses/services/khalti_payment_service.dart';
import '../../features/courses/providers/course_provider.dart';
import 'pending_payment_service.dart';


// Handles checking pending payments when app starts

class PaymentRecoveryService {
  
  /// Check for pending payments from previous sessions
  /// This ensures users get enrolled even if they closed the app during payment
  static Future<void> checkPendingPayments(BuildContext context) async {
    final pendingPayments = await PendingPaymentService.getPendingPayments();
    
    if (pendingPayments.isEmpty) return;
    
    print("Found ${pendingPayments.length} pending payments to verify");
    
    for (final payment in pendingPayments) {
      if (payment.pidx != null) {
        // Try to verify the payment with Khalti backend
        try {
          final khaltiService = KhaltiPaymentService();
          final success = await khaltiService.verifyPayment(pidx: payment.pidx!);
          
          if (success) {
            // Payment successful - enroll the user
            final courseProvider = Provider.of<CourseProvider>(context, listen: false);
            await courseProvider.enrollCourse(payment.courseId);
            await PendingPaymentService.removePendingPayment(payment.courseSelectId);
            
            // Show notification to user
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment completed! You are now enrolled in the course.'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 4),
                ),
              );
            }
            print("Pending payment verified and enrolled: ${payment.courseTitle}");
          } else {
            // Payment failed - remove after 24 hours
            final age = DateTime.now().difference(payment.timestamp);
            if (age.inHours > 24) {
              await PendingPaymentService.removePendingPayment(payment.courseSelectId);
              print("Old pending payment removed (${age.inHours} hours old)");
            } else {
              print("Payment still pending: ${payment.courseTitle}");
            }
          }
        } catch (e) {
          print("Failed to verify pending payment: $e");
        }
      }
    }
  }
}