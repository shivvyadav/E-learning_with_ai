import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../repositories/course_repository.dart';
class CourseProvider extends ChangeNotifier {
  final CourseRepository _repository = CourseRepository();

  List<CourseModel> _courses = [];

  List<CourseModel> get courses => _courses;

  List<CourseModel> get enrolledCourses =>
      _courses.where((c) => c.isEnrolled).toList();

  bool _initialized = false;

  final Map<String, int> _lessonCountCache = {};

  Future<void> loadCourses() async {
    if (_initialized) return;

    final courses = await _repository.getCourses();
    final enrolledIds = await _repository.getEnrolledCourseIds();

    _courses = courses.map((c) {
      return CourseModel(
        id: c.id,
        title: c.title,
        description: c.description,
        imageUrl: c.imageUrl,
        isFree: c.isFree,
        price: c.price,
        isEnrolled: enrolledIds.contains(c.id),
      );
    }).toList();

    await Future.wait(
      enrolledIds.map((id) => getLessonCountAsync(id)),
    );

    _initialized = true;
    notifyListeners();
  }

  Future<void> enrollCourse(String courseId) async {
    await _repository.enrollCourse(courseId);

    final index = _courses.indexWhere((c) => c.id == courseId);
    if (index == -1) return;

    _courses[index].isEnrolled = true;
    notifyListeners();
  }

  Future<int> getLessonCountAsync(String courseId) async {
    if (_lessonCountCache.containsKey(courseId)) { // use cached data
      return _lessonCountCache[courseId]!;
    }

    try {
      final count = await _repository.getLessonCount(courseId);
      _lessonCountCache[courseId] = count;
      notifyListeners();
      return count;
    } catch (_) {
      _lessonCountCache[courseId] = 0;
      notifyListeners();
      return 0;
    }
  }

  int getLessonCount(String courseId) {
    return _lessonCountCache[courseId] ?? 0;
  }

  CourseModel? getCourseById(String id) {
    try {
      return _courses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearAllData() {
    _courses = [];
    _initialized = false;
    _lessonCountCache.clear();
    courses.clear();
    enrolledCourses.clear();
    notifyListeners();    
  }

  Future<void> refreshCourses() async {
    _initialized = false;  // Reset cache flag
    _lessonCountCache.clear();  // Clear cached lesson counts
    await loadCourses();  // Reload fresh data
  }
  

}