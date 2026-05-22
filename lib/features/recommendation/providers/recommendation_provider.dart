import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/config/network_config.dart';
import '../models/user_preferences.dart';
import '../models/recommended_course.dart';

class RecommendationProvider extends ChangeNotifier {

  // Get AI Service URL dynamically based on device

  String get _aiServiceUrl => NetworkConfig.aiServiceUrl;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<RecommendedCourse> _recommendations = [];
  List<RecommendedCourse> get recommendations => _recommendations;

  String? _error;
  String? get error => _error;

  // Fetch recommendations from AI microservice
  Future<bool> getRecommendations(UserPreferences preferences) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Debug: Print which URL is being used
      print("AI Service URL: $_aiServiceUrl/recommend");
      print("Device: ${NetworkConfig.deviceInfo}");
      
      // Send POST request to AI service
      final response = await http.post(
        Uri.parse("$_aiServiceUrl/recommend"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(preferences.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data["success"] == true) {
          final recs = data["recommendations"] as List<dynamic>;
          _recommendations = recs
              .map((r) => RecommendedCourse.fromJson(r))
              .toList();
          return true;
        } else {
          _error = data["message"] ?? "Failed to get recommendations";
          return false;
        }
      } else {
        _error = "Server error: ${response.statusCode}";
        return false;
      }
    } catch (e) {
      _error = "Connection error: ${e.toString()}\n\n"
               "Device: ${NetworkConfig.deviceInfo}\n"
               "URL: $_aiServiceUrl/recommend\n\n"
               "Make sure:\n"
               "1. Python AI service is running (python app.py)\n"
               "2. Computer IP in NetworkConfig is correct\n"
               "3. Firewall allows port 5000";
      print("❌ Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear recommendations (for when starting new questionnaire)
  void clearRecommendations() {
    _recommendations = [];
    _error = null;
    notifyListeners();
  }
}