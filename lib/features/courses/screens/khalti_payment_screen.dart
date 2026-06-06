import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import '../models/course_model.dart';
import '../services/khalti_payment_service.dart';
import '../../../core/services/pending_payment_service.dart';
import '../models/pending_payment.dart';
import '../providers/course_provider.dart';


///  `/api/enroll` logic.
class KhaltiPaymentScreen extends StatefulWidget {
  final CourseModel course;

  const KhaltiPaymentScreen({super.key, required this.course});

  @override
  State<KhaltiPaymentScreen> createState() => _KhaltiPaymentScreenState();
}

class _KhaltiPaymentScreenState extends State<KhaltiPaymentScreen> with WidgetsBindingObserver {
  final _phoneController = TextEditingController();
  final _service = KhaltiPaymentService();

  // loading state for starting payment (separate from verify)
  bool _isStarting = false;
  // loading state while verifying a completed payment
  bool _isVerifying = false;
  // store the URL returned by backend to open in browser
  String? _paymentUrl;
  String? _courseSelectId;
  // payment identifier used for verification
  String? _pidx;
  
  // Timer for verification timeout
  Timer? _verificationTimer;
  int _verificationAttempts = 0;
  static const int maxVerificationAttempts = 10; // 20 seconds max (2 sec * 10)
  bool _isPaymentCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _verificationTimer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }


  // Show error dialog with proper message

  void _showErrorDialog(String message, {bool popScreen = true}) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              if (popScreen) {
                Navigator.pop(context); // Close payment screen
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  // Show success dialog and enroll

  void _showSuccessAndEnroll() async {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: const Text('You have been successfully enrolled in the course!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Close payment screen with success
            },
            child: const Text('Go to My Courses'),
          ),
        ],
      ),
    );
  }


  // Start payment process

  Future<void> _startPayment() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    setState(() {
      _isStarting = true;
      _paymentUrl = null;
      _courseSelectId = null;
      _pidx = null;
      _verificationAttempts = 0;
      _isPaymentCompleted = false;
    });

    try {
      // 1) Create a course selection (required by backend payment flow).
      final selection = await _service.createCourseSelection(
        courseId: widget.course.id,
        amount: widget.course.price,
        phoneNumber: phone,
      );

      final courseSelectId = selection?['_id']?.toString();
      if (courseSelectId == null) {
        throw Exception('Failed to create course selection');
      }
      setState(() => _courseSelectId = courseSelectId);
      
      // Save pending payment to local storage
      // This helps recover if app is closed
      final pendingPayment = PendingPayment(
        courseSelectId: courseSelectId,
        courseId: widget.course.id,
        courseTitle: widget.course.title,
        amount: widget.course.price,
        phoneNumber: phone,
        pidx: null,
        timestamp: DateTime.now(),
        status: 'pending',
      );
      await PendingPaymentService.savePendingPayment(pendingPayment);

      // 2) Initiate payment via backend. Backend returns the Khalti redirect URL.
      final paymentUrl = await _service.initiatePayment(
        courseSelectId: courseSelectId,
        amount: widget.course.price,
      );

      if (paymentUrl == null) {
        throw Exception('Payment URL was not returned by the backend');
      }

      if (!mounted) return;
      setState(() => _paymentUrl = paymentUrl);

      // Try to open the payment URL automatically.
      await _launchPaymentUrl(paymentUrl);

      // Attempt to retrieve the payment identifier (pidx) for later verification.
      if (!mounted) return;
      await _refreshPidx(courseSelectId);
    } catch (error) {
      if (!mounted) return;
      _showErrorDialog('Failed to start payment: $error');
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  // Refresh pidx from backend

  Future<void> _refreshPidx(String courseSelectId) async {
    try {
      final selections = await _service.getMyCourseSelections();
      final mySelection = selections.firstWhere(
        (c) => c['_id']?.toString() == courseSelectId,
        orElse: () => {},
      );

      final paymentDetail = mySelection['paymentdetail'] as Map<String, dynamic>?;
      final newPidx = paymentDetail?['pidx']?.toString();

      if (!mounted) return;
      setState(() => _pidx = newPidx);
      
      // Update pending payment with pidx
      if (newPidx != null) {
        await PendingPaymentService.updatePidx(courseSelectId, newPidx);
      }
    } catch (error) {
      debugPrint('Could not refresh pidx: $error');
    }
  }


  // Verify payment with timeout and retry

  Future<void> _verifyPayment() async {
    if (_pidx == null) {
      _showErrorDialog('Payment identifier not available yet. Please wait or refresh.');
      return;
    }

    if (!mounted) return;
    setState(() => _isVerifying = true);
    
    // Cancel any existing timer
    _verificationTimer?.cancel();
    
    // Start verification with retry logic
    _verificationAttempts = 0;
    _startVerificationLoop();
  }
  
  void _startVerificationLoop() {
    if (_verificationAttempts >= maxVerificationAttempts) {
      // Timeout reached - assume payment failed or user cancelled
      setState(() => _isVerifying = false);
      
      // Remove pending payment after timeout
      if (_courseSelectId != null) {
        PendingPaymentService.removePendingPayment(_courseSelectId!);
      }
      
      _showErrorDialog(
        'Payment verification timed out. If you completed the payment, please check your enrolled courses later.\n'
        'If you cancelled the payment, you can try again.',
        popScreen: false,
      );
      return;
    }
    
    _verificationAttempts++;
    _verifyOnce();
    
    // Schedule next check if not completed
    if (!_isPaymentCompleted && _verificationAttempts < maxVerificationAttempts) {
      _verificationTimer = Timer(const Duration(seconds: 2), _startVerificationLoop);
    }
  }
  

  // Single verification attempt
  Future<void> _verifyOnce() async {
    if (_isPaymentCompleted) return;
    
    try {
      // Use the new method that returns detailed status
      final result = await _service.verifyPaymentWithStatus(pidx: _pidx!);
      if (!mounted) return;
      
      print("🔍 Verification result: $result");
      
      if (result['success'] == true && result['status'] == 'completed') {
        // Payment completed successfully
        _isPaymentCompleted = true;
        _verificationTimer?.cancel();
        setState(() => _isVerifying = false);
        
        // Enroll the user after successful payment
        try {
          final courseProvider = Provider.of<CourseProvider>(context, listen: false);
          await courseProvider.enrollCourse(widget.course.id);
          
          // Remove pending payment
          if (_courseSelectId != null) {
            await PendingPaymentService.removePendingPayment(_courseSelectId!);
          }
          
          _showSuccessAndEnroll();
        } catch (enrollError) {
          _showErrorDialog('Payment verified but enrollment failed: $enrollError');
        }
      } else if (result['status'] == 'pending') {
        // Payment still pending, continue retrying
        debugPrint('⏳ Payment still pending, retrying...');
      } else if (result['status'] == 'failed' || result['status'] == 'not_found') {
        // Payment failed or was cancelled
        _verificationTimer?.cancel();
        setState(() => _isVerifying = false);
        
        // Remove pending payment since it failed
        if (_courseSelectId != null) {
          await PendingPaymentService.removePendingPayment(_courseSelectId!);
        }
        
        _showErrorDialog(
          result['message'] ?? 'Payment was cancelled or failed. Please try again.',
          popScreen: true,
        );
      } else {
        // Unknown status, continue retrying
        debugPrint('⚠️ Unknown verification status: ${result['status']}');
      }
    } catch (e) {
      debugPrint('Verification attempt $_verificationAttempts failed: $e');
      // Don't show error on each attempt, just continue retrying
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Auto verify payment when user returns from Khalti browser
    // Only start verification if not already verifying
    if (state == AppLifecycleState.resumed && !_isVerifying && !_isPaymentCompleted && _pidx != null) {
      _verifyPayment();
    }
  }


  // Launch Khalti payment page in external browser

  Future<void> _launchPaymentUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (mounted) {
        _showErrorDialog('Invalid payment URL');
      }
      return;
    }

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Unable to open payment URL');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khalti Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Course: ${widget.course.title}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Amount: Rs.${widget.course.price.toStringAsFixed(2)}'),
            const SizedBox(height: 16),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: 'Enter phone number for payment',
              ),
            ),
            const SizedBox(height: 16),

            // Start Payment Button
            ElevatedButton(
              onPressed: (_isStarting || _isVerifying) ? null : _startPayment,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: _isStarting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Start Real Payment (Khalti)'),
            ),

            const SizedBox(height: 12),

            if (_paymentUrl != null) ...[
              const Text(
                'Payment initiated. Click below to open Khalti.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: (_isStarting || _isVerifying) ? null : () => _launchPaymentUrl(_paymentUrl!),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: const Text('Open Khalti'),
              ),
              const SizedBox(height: 12),
              
              // Show verification status
              if (_pidx != null) ...[
                Text('Payment ID: $_pidx', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                if (_isVerifying)
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Verifying payment...'),
                      ],
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _verifyPayment,
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    child: const Text('Verify Payment'),
                  ),
              ] else if (_paymentUrl != null) ...[
                const Text(
                  'Waiting for payment identifier...',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: (_isStarting || _isVerifying || _courseSelectId == null)
                      ? null
                      : () => _refreshPidx(_courseSelectId!),
                  child: const Text('Refresh Status'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}