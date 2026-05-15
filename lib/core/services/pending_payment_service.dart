import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../features/courses/models/pending_payment.dart';

// Manages payments that were initiated but not yet completed
// This ensures payments are recovered even if app is closed

class PendingPaymentService {
  static const String _storageKey = 'pending_payments';

  // Save a pending payment to local storage
  static Future<void> savePendingPayment(PendingPayment payment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> payments = prefs.getStringList(_storageKey) ?? [];
      
      // Remove any existing payment for same course
      final updatedPayments = payments.where((p) {
        final existing = PendingPayment.fromJson(jsonDecode(p));
        return existing.courseId != payment.courseId;
      }).toList();
      
      updatedPayments.add(jsonEncode(payment.toJson()));
      await prefs.setStringList(_storageKey, updatedPayments);
      print("Pending payment saved: ${payment.courseTitle}");
    } catch (e) {
      print("Error saving pending payment: $e");
    }
  }

  // Get all pending payments
  static Future<List<PendingPayment>> getPendingPayments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> payments = prefs.getStringList(_storageKey) ?? [];
      return payments
          .map((p) => PendingPayment.fromJson(jsonDecode(p)))
          .toList();
    } catch (e) {
      print("Error getting pending payments: $e");
      return [];
    }
  }

  // Remove a pending payment by courseSelectId
  static Future<void> removePendingPayment(String courseSelectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> payments = prefs.getStringList(_storageKey) ?? [];
      final updated = payments.where((p) {
        final payment = PendingPayment.fromJson(jsonDecode(p));
        return payment.courseSelectId != courseSelectId;
      }).toList();
      await prefs.setStringList(_storageKey, updated);
      print("Pending payment removed: $courseSelectId");
    } catch (e) {
      print("Error removing pending payment: $e");
    }
  }

  // Update pidx for a pending payment
  static Future<void> updatePidx(String courseSelectId, String pidx) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> payments = prefs.getStringList(_storageKey) ?? [];
      final updated = <String>[];
      
      for (final p in payments) {
        final payment = PendingPayment.fromJson(jsonDecode(p));
        if (payment.courseSelectId == courseSelectId) {
          final updatedPayment = PendingPayment(
            courseSelectId: payment.courseSelectId,
            courseId: payment.courseId,
            courseTitle: payment.courseTitle,
            amount: payment.amount,
            phoneNumber: payment.phoneNumber,
            pidx: pidx,
            timestamp: payment.timestamp,
            status: payment.status,
          );
          updated.add(jsonEncode(updatedPayment.toJson()));
        } else {
          updated.add(p);
        }
      }
      
      await prefs.setStringList(_storageKey, updated);
      print("Pidx updated for: $courseSelectId");
    } catch (e) {
      print("Error updating pidx: $e");
    }
  }

  // Clear all pending payments
  static Future<void> clearAllPending() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      print("All pending payments cleared");
    } catch (e) {
      print("Error clearing pending payments: $e");
    }
  }
}