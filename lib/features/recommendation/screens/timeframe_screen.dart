import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/questionnaire_provider.dart';
import '../providers/recommendation_provider.dart';
import '../models/user_preferences.dart';

class TimeframeScreen extends StatelessWidget {
  const TimeframeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final questionnaireProvider = context.watch<QuestionnaireProvider>();
    final recommendationProvider = context.watch<RecommendationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Step 6 of 6"),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What's your goal?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                "This helps us recommend courses that match your timeline.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              _buildOptionCard(
                context: context,
                emoji: "🎯",
                title: "Quick Results",
                subtitle: "Learn a specific skill, solve an immediate problem",
                value: "short_term",
                selectedValue: questionnaireProvider.timeframe,
                onTap: () => questionnaireProvider.setTimeframe("short_term"),
              ),
              
              _buildOptionCard(
                context: context,
                emoji: "🔄",
                title: "Balanced",
                subtitle: "Practical skills that build toward deeper knowledge",
                value: "balanced",
                selectedValue: questionnaireProvider.timeframe,
                onTap: () => questionnaireProvider.setTimeframe("balanced"),
              ),
              
              _buildOptionCard(
                context: context,
                emoji: "🌳",
                title: "Long-term Mastery",
                subtitle: "Deep expertise, career foundation",
                value: "long_term",
                selectedValue: questionnaireProvider.timeframe,
                onTap: () => questionnaireProvider.setTimeframe("long_term"),
              ),
              
              const SizedBox(height: 30),
              
              // Get Recommendations button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: questionnaireProvider.timeframe.isNotEmpty
                      ? () async {
                          // Build user preferences
                          final preferences = questionnaireProvider.buildPreferences();
                          
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          
                          // Get recommendations
                          final success = await recommendationProvider.getRecommendations(preferences);
                          
                          // Close loading dialog
                          // Use if (context.mounted) check with BuildContext
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                          
                          if (success && context.mounted) {
                            // Navigate to results screen
                            Navigator.pushNamed(context, '/recommendation-results');
                          } else if (context.mounted) {
                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(recommendationProvider.error ?? "Failed to get recommendations"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    "Get My Recommendations",
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String emoji,
    required String title,
    required String subtitle,
    required String value,
    required String selectedValue,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedValue == value;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.blue : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}