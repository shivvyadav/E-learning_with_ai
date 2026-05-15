import 'package:shared_preferences/shared_preferences.dart';

import '../../storage/secure_storage_service.dart';
import 'api_service.dart';
import '../constants/api_endpoints.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    print("[AuthService] login() start: $email");
    try {
      final response = await _apiService.post(
        ApiEndpoints.login,
        data: {
          "email": email,
          "password": password,
        },
      );

      print("[AuthService] login() response: $response");

      final token = response["token"];
      final userId = response["data"] != null && response["data"].isNotEmpty
          ? response["data"][0]["_id"]
          : null;

      if (token != null) {
        await SecureStorageService.saveAccessToken(token);
        if (userId != null) {
          await SecureStorageService.saveUserId(userId);
        }

        // Persist user name for display in the profile screen.
        final userName = response["data"] != null && response["data"].isNotEmpty
            ? (response["data"][0]["username"] ?? response["data"][0]["useremail"])
            : null;
        if (userName != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_name', userName.toString());
        }

        return {
          'success': true,
          'name': userName,
        };
      }
      
      // If no token but response has message
      final message = response["message"] ?? "Login failed";
      return {'success': false, 'message': message};
      
    } catch (e, st) {
      print("[AuthService] login() error: $e\n$st");
      return {'success': false, 'message': 'Connection error. Please check your internet.'};
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String phoneNumber,
  ) async {
    print("[AuthService] register() start: $email");
    try {
      final response = await _apiService.post(
        ApiEndpoints.register,
        data: {
          "username": name,
          "email": email,
          "password": password,
          "phonenumber": phoneNumber,
        },
      );

      print("[AuthService] register() response: $response");

      // Check if registration was successful
      if (response.containsKey("message") && 
          (response["message"]?.toString().contains("successfully") ?? false)) {
        // Auto login after successful registration
        return await login(email, password);
      }
      
      // If registration failed, return error message
      final message = response["message"] ?? "Registration failed";
      return {'success': false, 'message': message};
      
    } catch (e, st) {
      print("[AuthService] register() error: $e\n$st");
      return {'success': false, 'message': 'Connection error. Please check your internet.'};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.forgotPassword,
        data: {"email": email},
      );
      print("[AuthService] forgotPassword() response: $response");
      return {'success': true, 'message': response["message"] ?? "OTP sent"};
    } catch (e, st) {
      print("[AuthService] forgotPassword() error: $e\n$st");
      return {'success': false, 'message': 'Failed to send OTP'};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.verifyOtp,
        data: {"email": email, "otp": otp},
      );
      print("[AuthService] verifyOtp() response: $response");
      return {'success': true, 'message': response["message"] ?? "OTP verified"};
    } catch (e, st) {
      print("[AuthService] verifyOtp() error: $e\n$st");
      return {'success': false, 'message': 'Invalid OTP'};
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.resetPassword,
        data: {
          "email": email,
          "newpassword": newPassword,
          "confirmpassword": confirmPassword,
        },
      );
      print("[AuthService] resetPassword() response: $response");
      return {'success': true, 'message': response["message"] ?? "Password reset successfully"};
    } catch (e, st) {
      print("[AuthService] resetPassword() error: $e\n$st");
      return {'success': false, 'message': 'Failed to reset password'};
    }
  }

  Future<void> logout() async {
    await SecureStorageService.clearAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await SecureStorageService.getAccessToken();
    return token != null;
  }
}