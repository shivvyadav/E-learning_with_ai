import 'package:flutter/material.dart';
import '../../app/app.dart';
import '../services/payment_recovery_service.dart';

/// ============================================
/// App Wrapper - Handles app startup tasks
/// Keeps main.dart clean and simple
/// ============================================
class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    // Check for pending payments after app is fully loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PaymentRecoveryService.checkPendingPayments(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MyApp();
  }
}