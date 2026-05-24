import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';


// AuthProvider:
//Handles login/register/logout
//saves session using SecureStorage for tokens.
//Uses SharedPreferences to save email for UI display.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  String? _currentUserEmail;
  String? get currentUserEmail => _currentUserEmail;

  String? _currentUserName;
  String? get currentUserName => _currentUserName;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

 
  //Callback to clear data from other providers when logging out

  VoidCallback? _onClearData;
  
  void setOnClearData(VoidCallback callback) {
    _onClearData = callback;
  }

  static const _emailKey = "auth_email";
  static const _nameKey = "auth_name";

// splash screen authentication status check
  Future<void> checkAuthStatus() async {
    await tryAutoLogin();
  }

  /// LOGIN
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _errorMessage = null;
    final result = await _authService.login(email, password);
    
    if (result['success'] == true) {
      _isAuthenticated = true;
      _currentUserEmail = email;
      _currentUserName = result['name'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_emailKey, email);
      await prefs.setString(_nameKey, result['name'] ?? '');

      notifyListeners();
      return {'success': true};
    } else {
      _errorMessage = result['message'] ?? 'Login failed';
      notifyListeners();
      return {'success': false, 'message': _errorMessage};
    }
  }

  /// REGISTER
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    _errorMessage = null;
    final result = await _authService.register(
      name,
      email,
      password,
      phoneNumber,
    );
    
    if (result['success'] == true) {
      _isAuthenticated = true;
      _currentUserEmail = email;
      _currentUserName = name;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_emailKey, email);
      await prefs.setString(_nameKey, name);

      notifyListeners();
      return {'success': true};
    } else {
      _errorMessage = result['message'] ?? 'Registration failed';
      notifyListeners();
      return {'success': false, 'message': _errorMessage};
    }
  }

  /// AUTO LOGIN (USED ON APP START)
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey);

    final success = await _authService.isLoggedIn();
    if (!success || email == null) return false;

    _isAuthenticated = true;
    _currentUserEmail = email;
    _currentUserName = prefs.getString(_nameKey);
    notifyListeners();
    return true;
  }

  /// UPDATE USER NAME (PERSISTS TO BACKEND)
  Future<void> updateName(String name) async {
    // Persist to backend so that the name is available across devices.
    try {
      final apiService = ApiService();
      await apiService.patch('/auth/profile', data: {'username': name});
    } catch (_) {
      // Ignore failures; still update locally so the user sees their change.
    }

    _currentUserName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    notifyListeners();
  }

  /// LOGOUT
  Future<void> logout() async {
    await _authService.logout();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);

    _isAuthenticated = false;
    _currentUserEmail = null;
    _currentUserName = null;
    _errorMessage = null;
    
    // ============================================
    // NEW: Call the callback to clear course and progress data
    // ============================================
    _onClearData?.call();
    
    notifyListeners();
  }
  
  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}