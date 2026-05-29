import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';

class CourseRepository {
  final ApiService _apiService = ApiService();

  Future<List<CourseModel>> getCourses() async {
    final response = await _apiService.get(ApiEndpoints.courses);
    final data = response["data"] as List<dynamic>? ?? [];

    return data.map((raw) {
      final courseMap = raw as Map<String, dynamic>;
      return CourseModel.fromJson(courseMap);
    }).toList();
  }

  Future<List<String>> getEnrolledCourseIds() async {
    final response = await _apiService.get(ApiEndpoints.myEnrollments);
    final data = response["data"] as List<dynamic>? ?? [];

    return data
        .map((raw) => (raw as Map<String, dynamic>)["course"])
        .whereType<Map<String, dynamic>>()
        .map((course) => course["_id"].toString())
        .toList();
  }

  Future<void> enrollCourse(String courseId) async {
    await _apiService.post(
      ApiEndpoints.enroll,
      data: {"id": courseId},
    );
  }

  String _normalizeCourseId(String courseId) {
    final match = RegExp(r"[0-9a-fA-F]{24}").firstMatch(courseId);
    return match?.group(0) ?? courseId;
  }

  Future<List<LessonModel>> getLessons(String courseId) async {
    try {
      final normalizedId = _normalizeCourseId(courseId);
      final response =
          await _apiService.get(ApiEndpoints.courseLessons(normalizedId));
      final data = response["data"] as List<dynamic>? ?? [];
      return data.map((raw) {
        final map = raw as Map<String, dynamic>;
        return LessonModel.fromMap(map);
      }).toList();
    } catch (e) {
      try {
        final response =
            await _apiService.get(ApiEndpoints.courseDetail(courseId));

        final data = response["data"] as Map<String, dynamic>? ?? {};
        final courses = (data["courses"] as List<dynamic>?) ?? [];

        if (courses.isEmpty) return [];

        final course = courses.first as Map<String, dynamic>;
        final modules = (course["modules"] as List<dynamic>?) ?? [];

        final lessons = <LessonModel>[];
        for (final module in modules) {
          final moduleMap = module as Map<String, dynamic>;
          final videos = (moduleMap["videos"] as List<dynamic>?) ?? [];

          for (final video in videos) {
            final videoMap = video as Map<String, dynamic>;
            lessons.add(LessonModel.fromMap({
              ...videoMap,
              "lessonTitle": videoMap["title"],
            }));
          }
        }

        return lessons;
      } catch (_) {
        return [];
      }
    }
  }

  Future<int> getLessonCount(String courseId) async {
    final lessons = await getLessons(courseId);
    return lessons.length;
  }
}
