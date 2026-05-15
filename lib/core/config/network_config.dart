import 'dart:io';
import 'package:flutter/foundation.dart';

// NETWORK CONFIGURATION
 

class NetworkConfig {


  static const String computerIp = "192.168.40.98"; // CHANGE THIS TO IP HERE
  
  // Ports
  static const int backendPort = 3000;   // Node.js backend port
  static const int aiServicePort = 5000; // Python AI service port
  

  // Get Backend API Base URL

  static String get baseUrl {
    // Web platform
    if (kIsWeb) {
      print("Web - using localhost");
      return "http://localhost:$backendPort/api";
    }
    
    // Android or iOS (real device or emulator)
    if (Platform.isAndroid || Platform.isIOS) {
      print("Mobile device - using computer IP: $computerIp:$backendPort");
      return "http://$computerIp:$backendPort/api";
    }
    
    // Desktop fallback
    return "http://localhost:$backendPort/api";
  }

  // Get AI Recommendation Service URL

  static String get aiServiceUrl {
    if (kIsWeb) {
      return "http://localhost:$aiServicePort";
    }
    
    if (Platform.isAndroid || Platform.isIOS) {
      return "http://$computerIp:$aiServicePort";
    }
    
    return "http://localhost:$aiServicePort";
  }

  // Get Correct Video URL
  // This properly replaces localhost with computer IP

  static String getVideoUrl(String videoPath) {
    print("Original URL: $videoPath");
    
    // If already has http/https
    if (videoPath.startsWith('http://') || videoPath.startsWith('https://')) {
      // Replace localhost/127.0.0.1 with computer IP for mobile devices
      if (Platform.isAndroid || Platform.isIOS) {
        var correctedUrl = videoPath;
        // Replace localhost with computer IP
        correctedUrl = correctedUrl.replaceAll('localhost', computerIp);
        correctedUrl = correctedUrl.replaceAll('127.0.0.1', computerIp);
        print("orrected URL: $correctedUrl");
        return correctedUrl;
      }
      print("Corrected URL: $videoPath");
      return videoPath;
    }
    
    // Handle relative paths (starting with /)
    if (videoPath.startsWith('/')) {
      if (Platform.isAndroid || Platform.isIOS) {
        final correctedUrl = "http://$computerIp:$backendPort$videoPath";
        print("Corrected URL: $correctedUrl");
        return correctedUrl;
      }
      final correctedUrl = "http://localhost:$backendPort$videoPath";
      print("Corrected URL: $correctedUrl");
      return correctedUrl;
    }
    
    // Fallback
    print("Corrected URL: $videoPath");
    return videoPath;
  }
  
  // Get Correct Image URL
  // This properly replaces localhost with computer IP

  static String getImageUrl(String imagePath) {
    print("Original Image URL: $imagePath");
    
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // Replace localhost with computer IP for mobile devices
      if (Platform.isAndroid || Platform.isIOS) {
        var correctedUrl = imagePath;
        correctedUrl = correctedUrl.replaceAll('localhost', computerIp);
        correctedUrl = correctedUrl.replaceAll('127.0.0.1', computerIp);
        print("Corrected Image URL: $correctedUrl");
        return correctedUrl;
      }
      return imagePath;
    }
    
    if (imagePath.startsWith('/')) {
      if (Platform.isAndroid || Platform.isIOS) {
        final correctedUrl = "http://$computerIp:$backendPort$imagePath";
        print("Corrected Image URL: $correctedUrl");
        return correctedUrl;
      }
      return "http://localhost:$backendPort$imagePath";
    }
    
    return imagePath;
  }

  // Get Device Info (for debugging)
  static String get deviceInfo {
    if (kIsWeb) return "Web";
    if (Platform.isAndroid) return "Android";
    if (Platform.isIOS) return "iOS";
    return "Desktop";
  }
}