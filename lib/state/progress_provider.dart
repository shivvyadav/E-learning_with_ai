/*
Maintains:
- Resume playback
- Completion tracking
- Course progress
- Storage initialization (safe)
- Continue watching
- Last watched tracking
- Offline persistence
*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/courses/repositories/progress_repository.dart';

class ProgressProvider extends ChangeNotifier {
  /// STORAGE KEYS
  static const _completedKey = "completed_lessons";
  static const _positionKey = "lesson_positions";
  static const _lastLessonKey = "last_lesson";

  final ProgressRepository _progressRepository = ProgressRepository();

  final Map<String, Set<String>> _completedLessons = {};
  final Map<String, Map<String, int>> _lessonPositions = {};

  bool _initialized = false;


  // INIT (REQUIRED BY main.dart) – SAFE INITIALIZATION

  Future<void> init() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();

    // Load completed lessons
    final completedJson = prefs.getString(_completedKey);
    if (completedJson != null) {
      final decoded = jsonDecode(completedJson);
      decoded.forEach((courseId, lessons) {
        _completedLessons[courseId] =
            Set<String>.from(lessons);
      });
    }

    // Load saved positions
    final positionJson = prefs.getString(_positionKey);
    if (positionJson != null) {
      final decoded = jsonDecode(positionJson);
      decoded.forEach((courseId, lessons) {
        _lessonPositions[courseId] =
            Map<String, int>.from(lessons);
      });
    }

    _initialized = true;
    notifyListeners();
  }

 
  // INTERNAL SAVE METHOD (JSON STRUCTURED STORAGE)

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    final completedMap =
        _completedLessons.map((k, v) => MapEntry(k, v.toList()));

    await prefs.setString(_completedKey, jsonEncode(completedMap));
    await prefs.setString(_positionKey, jsonEncode(_lessonPositions));
  }

  // Fetch progress from backend and merge with local progress.
 
  // This ensures progress isn't lost after re-login or password reset.
  Future<void> syncProgressFromBackend(List<String> courseIds) async {
    if (courseIds.isEmpty) return;

    try {
      for (final courseId in courseIds) {
        final backendProgress =
            await _progressRepository.getProgress(courseId);
        if (backendProgress == null) continue;

        final completedVideos = backendProgress["completedvideos"] as List<dynamic>?;
        if (completedVideos != null) {
          for (final item in completedVideos) {
            if (item is Map<String, dynamic>) {
              final id = item['_id']?.toString() ?? item['id']?.toString();
              if (id != null) {
                _completedLessons.putIfAbsent(courseId, () => <String>{});
                _completedLessons[courseId]!.add(id);
              }
            }
          }
        }

        final completedPdfs = backendProgress["completedpdfs"] as List<dynamic>?;
        if (completedPdfs != null) {
          for (final item in completedPdfs) {
            if (item is Map<String, dynamic>) {
              final id = item['_id']?.toString() ?? item['id']?.toString();
              if (id != null) {
                _completedLessons.putIfAbsent(courseId, () => <String>{});
                _completedLessons[courseId]!.add(id);
              }
            }
          }
        }
      }

      await _save();
      notifyListeners();
    } catch (_) {
      // Ignore failures (best-effort sync)
    }
  }


  // VIDEO PLAYER – RESUME POSITION

  int getSavedPosition(String courseId, String lessonId) {
    return _lessonPositions[courseId]?[lessonId] ?? 0;
  }

  Future<void> savePosition(
      String courseId,
      String lessonId,
      int seconds) async {
    _lessonPositions.putIfAbsent(courseId, () => {});
    _lessonPositions[courseId]![lessonId] = seconds;

    await _save();

    // ALSO SAVE LAST WATCHED
    await saveLastWatched(courseId, lessonId);
  }


  // COMPLETE LESSON

  Future<void> completeLesson(
      String courseId,
      String lessonId) async {
    _completedLessons.putIfAbsent(courseId, () => {});
    _completedLessons[courseId]!.add(lessonId);

    await _save();
    notifyListeners();

    // Sync progress with backend (best-effort)
    try {
      await _progressRepository.updateProgress(
        courseId: courseId,
        videoId: lessonId,
      );
    } catch (_) {
      // Ignore backend failures (still keep local progress)
    }
  }

  bool isLessonCompleted(String courseId, String lessonId) {
    return _completedLessons[courseId]
            ?.contains(lessonId) ??
        false;
  }


  // COURSE PROGRESS

  double getCourseProgress(
      String courseId,
      int totalLessons) {
    if (totalLessons == 0) return 0;

    final completed =
        _completedLessons[courseId]?.length ?? 0;

    return completed / totalLessons;
  }

  double calculateProgress(
      String courseId,
      int totalLessons) {
    return getCourseProgress(courseId, totalLessons);
  }

  int getCompletedLessonCount(String courseId) {
    return _completedLessons[courseId]?.length ?? 0;
  }


  // CONTINUE WATCHING FEATURE

  Future<void> saveLastWatched(
      String courseId,
      String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _lastLessonKey, "$courseId|$lessonId");
  }

  Future<Map<String, String>?> getLastWatched() async {
    final prefs = await SharedPreferences.getInstance();

    final last = prefs.getString(_lastLessonKey);
    if (last == null) return null;

    final parts = last.split("|");

    if (parts.length != 2) return null;

    return {
      "courseId": parts[0],
      "lessonId": parts[1],
    };
  }

  // Optional helper: Clear all progress (future-proof)
  Future<void> clearAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedKey);
    await prefs.remove(_positionKey);
    await prefs.remove(_lastLessonKey);

    _completedLessons.clear();
    _lessonPositions.clear();

    notifyListeners();
  }

 
  // NEW: Clear all progress data (called on logout)

  void clearAllData() {
    _completedLessons.clear();
    _lessonPositions.clear();
    // Also clear shared preferences data
    clearAllProgress();
    notifyListeners();
  }
}