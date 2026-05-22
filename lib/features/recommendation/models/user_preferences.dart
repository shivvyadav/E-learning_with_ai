// Simple User Preferences Model for AI Recommendation
// Matches the 6 questions from our questionnaire

class UserPreferences {
  // Core fields for recommendation (6 questions)
  final String domain;      // creative, technical, business, wellness, hands_on, academic, exploring
  final String intensity;   // micro, standard, focused, immersive
  final String outcome;     // enrichment, career, monetization, entrepreneurship, academic
  final String pedagogy;    // structured, exploratory, hybrid
  final String role;        // problem_solving, creating, helping, leading, analyzing
  final String timeframe;   // short_term, balanced, long_term

  // Constructor
  UserPreferences({
    required this.domain,
    required this.intensity,
    required this.outcome,
    required this.pedagogy,
    required this.role,
    required this.timeframe,
  });

  /// Convert to JSON for API request.
  Map<String, dynamic> toJson() {
    return {
      'domain': domain,
      'intensity': intensity,
      'outcome': outcome,
      'pedagogy': pedagogy,
      'role': role,
      'timeframe': timeframe,
    };
  }

  /// Create from JSON (for future use)
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      domain: json['domain'] ?? 'exploring',
      intensity: json['intensity'] ?? 'standard',
      outcome: json['outcome'] ?? 'enrichment',
      pedagogy: json['pedagogy'] ?? 'hybrid',
      role: json['role'] ?? 'problem_solving',
      timeframe: json['timeframe'] ?? 'balanced',
    );
  }
}