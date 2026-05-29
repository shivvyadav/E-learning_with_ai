import '../../../core/config/network_config.dart';

class LessonModel {
  final String id;
  final String title;
  final String duration;
  final String videoUrl;

  LessonModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.videoUrl,
  });

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    final rawVideoUrl = (map['videoUrl'] ?? '').toString();
    
    // Use NetworkConfig to correct video URL
    // This ensures localhost is replaced with computer IP

    final correctedVideoUrl = NetworkConfig.getVideoUrl(rawVideoUrl);

    return LessonModel(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      title: map['lessonTitle'] ?? map['title'] ?? '',
      duration: map['duration'] ?? '',
      videoUrl: correctedVideoUrl,
    );
  }
}