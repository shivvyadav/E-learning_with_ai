import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

class KhaltiPaymentService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>?> createCourseSelection({
    required String courseId,
    required double amount,
    required String phoneNumber,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.courseSelect,
      data: {
        'course': courseId,
        'totalamount': amount,
        'phonenumber': phoneNumber,
        'paymentdetail': {
          'method': 'khalti',
          'status': 'pending',
        },
      },
    );

    return response['data'] as Map<String, dynamic>?;
  }

  Future<String?> initiatePayment({
    required String courseSelectId,
    required double amount,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.payment,
      data: {
        'courseselectId': courseSelectId,
        'amount': amount,
      },
    );

    return response['paymentUrl']?.toString();
  }

  Future<Map<String, dynamic>> verifyPaymentWithStatus({required String pidx}) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.verify,
        data: {'pidx': pidx},
      );
      
      print("🔍 Verify response: $response");
      if (response['success'] == true && response['status'] == 'completed') {
        return {
          'success': true, 
          'status': 'completed', 
          'message': response['message'] ?? 'Payment verified successfully'
        };
      }
            else if (response['status'] == 'pending') {
        return {
          'success': false, 
          'status': 'pending', 
          'message': response['message'] ?? 'Payment is still pending'
        };
      }
      
      else if (response['status'] == 'failed') {
        return {
          'success': false, 
          'status': 'failed', 
          'message': response['message'] ?? 'Payment failed'
        };
      }
      
      else if (response['status'] == 'not_found') {
        return {
          'success': false, 
          'status': 'failed', 
          'message': response['message'] ?? 'Payment not found'
        };
      }
      
      else if (response['status'] == 'error') {
        return {
          'success': false, 
          'status': 'failed', 
          'message': response['message'] ?? 'Verification error'
        };
      }
            else {
        return {
          'success': false, 
          'status': 'failed', 
          'message': 'Unknown payment status'
        };
      }
      
    } catch (e) {
      print("Verification error: $e");
      return {
        'success': false, 
        'status': 'failed', 
        'message': 'Verification error: ${e.toString()}'
      };
    }
  }

  Future<bool> verifyPayment({required String pidx}) async {
    final result = await verifyPaymentWithStatus(pidx: pidx);
    return result['success'] == true;
  }

  Future<List<Map<String, dynamic>>> getMyCourseSelections() async {
    final response = await _apiService.get(ApiEndpoints.courseSelect);
    final data = response['data'] as List<dynamic>? ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .toList();
  }
}