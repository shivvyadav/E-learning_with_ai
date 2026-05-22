// Model for recommended courses returned by AI service

import '../../../core/config/network_config.dart';

class RecommendedCourse {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final bool isFree;
  final double price;
  final double similarity;      // Raw similarity score (0-1)
  final double matchPercentage; // Percentage match (0-100)

  RecommendedCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.isFree,
    required this.price,
    required this.similarity,
    required this.matchPercentage,
  });

  // Create from JSON response from AI service
  factory RecommendedCourse.fromJson(Map<String, dynamic> json) {
  
    // Use NetworkConfig to correct image URL
    // This ensures localhost is replaced with computer IP

    var imageUrl = json['imageUrl'] ?? '';
    imageUrl = NetworkConfig.getImageUrl(imageUrl);

    return RecommendedCourse(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: imageUrl,
      isFree: json['isFree'] ?? true,
      price: (json['price'] ?? 0).toDouble(),
      similarity: (json['similarity'] ?? 0.0).toDouble(),
      matchPercentage: (json['matchPercentage'] ?? 0.0).toDouble(),
    );
  }
}