import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../storage/secure_storage_service.dart';
import '../config/network_config.dart';

class ApiService {
  // Get backend URL dynamically based on device
  String get baseUrl => NetworkConfig.baseUrl;

  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      await SecureStorageService.clearAll();
      throw Exception("Unauthorized");
    }

    return jsonDecode(response.body);
  }

// receiving data from backend
  Future<dynamic> get(String endpoint) async {
    final token = await SecureStorageService.getAccessToken(); // getting saved token

    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"), // making request
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token", // send token in header
      },
    );

    return _handleResponse(response);
  }


// sending data after converting dart map to json
  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    final token = await SecureStorageService.getAccessToken();

    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    return Map<String, dynamic>.from(await _handleResponse(response));
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    final token = await SecureStorageService.getAccessToken();

    final response = await http.patch(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    return Map<String, dynamic>.from(await _handleResponse(response));
  }
  
  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    final token = await SecureStorageService.getAccessToken();

    final response = await http.put(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    return Map<String, dynamic>.from(await _handleResponse(response));
  }
}