import 'package:flutter/material.dart';
import '../models/user_preferences.dart';

class QuestionnaireProvider extends ChangeNotifier {
  // Step 1: Domain
  String _domain = '';
  String get domain => _domain;
  void setDomain(String value) {
    _domain = value;
    notifyListeners();
  }

  // Step 2: Intensity (Time Commitment)
  String _intensity = '';
  String get intensity => _intensity;
  void setIntensity(String value) {
    _intensity = value;
    notifyListeners();
  }

  // Step 3: Outcome (Motivation)
  String _outcome = '';
  String get outcome => _outcome;
  void setOutcome(String value) {
    _outcome = value;
    notifyListeners();
  }

  // Step 4: Pedagogy (Learning Style)
  String _pedagogy = '';
  String get pedagogy => _pedagogy;
  void setPedagogy(String value) {
    _pedagogy = value;
    notifyListeners();
  }

  // Step 5: Role (Work Preference)
  String _role = '';
  String get role => _role;
  void setRole(String value) {
    _role = value;
    notifyListeners();
  }

  // Step 6: Timeframe (Goal)
  String _timeframe = '';
  String get timeframe => _timeframe;
  void setTimeframe(String value) {
    _timeframe = value;
    notifyListeners();
  }

  /// Check if all questions are answered
  bool get isComplete {
    return _domain.isNotEmpty &&
        _intensity.isNotEmpty &&
        _outcome.isNotEmpty &&
        _pedagogy.isNotEmpty &&
        _role.isNotEmpty &&
        _timeframe.isNotEmpty;
  }

  // Build UserPreferences from current state
  UserPreferences buildPreferences() {
    return UserPreferences(
      domain: _domain,
      intensity: _intensity,
      outcome: _outcome,
      pedagogy: _pedagogy,
      role: _role,
      timeframe: _timeframe,
    );
  }

  // Reset all answers
  void reset() {
    _domain = '';
    _intensity = '';
    _outcome = '';
    _pedagogy = '';
    _role = '';
    _timeframe = '';
    notifyListeners();
  }
}