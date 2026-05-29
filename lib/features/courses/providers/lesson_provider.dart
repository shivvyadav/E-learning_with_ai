import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../models/lesson_model.dart';
import '../repositories/course_repository.dart';

class LessonProvider extends ChangeNotifier {
  static const _durationPrefKey = 'lesson_duration_';

  final CourseRepository _repository = CourseRepository();

  List<LessonModel> _lessons = [];
  final Map<String, Duration> _lessonDurations = {};

  List<LessonModel> get lessons => _lessons;

  Duration? getLessonDuration(String lessonId) => _lessonDurations[lessonId];
  Future<void> setLessonDuration(String lessonId, Duration duration) async {
    if (duration == Duration.zero) return;

    _lessonDurations[lessonId] = duration;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_durationPrefKey$lessonId', duration.inSeconds);
  }

  Future<void> _loadCachedDurations() async {
    final prefs = await SharedPreferences.getInstance();

    for (final lesson in _lessons) {
      final key = '$_durationPrefKey${lesson.id}';
      if (prefs.containsKey(key)) {
        final seconds = prefs.getInt(key);
        if (seconds != null && seconds > 0) {
          _lessonDurations[lesson.id] = Duration(seconds: seconds);
        }
      }
    }

    notifyListeners();
  }

  Future<void> loadLessons(String courseId) async {
    _lessons = await _repository.getLessons(courseId);
    notifyListeners();

    await _loadCachedDurations();

    final futures = <Future<void>>[];

    for (final lesson in _lessons) {
      // Skip if we already have a duration that seems valid.
      if (_lessonDurations[lesson.id] != null &&
          _lessonDurations[lesson.id]! > Duration.zero) {
        continue;
      }

      futures.add(_fetchAndStoreDuration(lesson));
    }

    await Future.wait(futures);
  }

  Future<void> _fetchAndStoreDuration(LessonModel lesson) async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(lesson.videoUrl),
      );
      await controller.initialize();
      final duration = controller.value.duration;
      await setLessonDuration(lesson.id, duration);
      controller.dispose();
    } catch (_) {
    }
  }

  int getLessonCount(String courseId) {
    return _lessons.length;
  }
}
