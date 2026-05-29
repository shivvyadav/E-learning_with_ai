import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

class ProgressRepository {
  final ApiService _apiService = ApiService();

  /// Notify backend that a video/pdf has been completed.
  ///
  /// Returns the completion percentage (0-100) if available.
  Future<double?> updateProgress({
    required String courseId,
    String? videoId,
    String? pdfId,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.updateProgress,
      data: {
        "courseId": courseId,
        if (videoId != null) "videoId": videoId,
        if (pdfId != null) "pdfId": pdfId,
      },
    );

    if (response["data"] is num) {
      return (response["data"] as num).toDouble();
    }

    return null;
  }

  /// Fetch progress object for a course.
  Future<Map<String, dynamic>?> getProgress(String courseId) async {
    final response = await _apiService.get(ApiEndpoints.getProgress(courseId));
    return response["data"] as Map<String, dynamic>?;
  }
}
