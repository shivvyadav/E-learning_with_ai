import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/questionnaire_provider.dart';

class DomainScreen extends StatelessWidget {
  const DomainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestionnaireProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Step 1 of 6"),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(  // ADDED: Makes the screen scrollable
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What area interests you most?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                "This helps us find courses that match your interests.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              // Domain options (keeping emojis)
              _buildOptionCard(
                context: context,
                emoji: "💻",
                title: "Technical",
                subtitle: "Coding, programming, data science",
                value: "technical",
                selectedValue: provider.domain,
                onTap: () => provider.setDomain("technical"),
              ),
              
              _buildOptionCard(
                context: context,
                emoji: "🎨",
                title: "Creative",
                subtitle: "Design, art, writing, photography",
                value: "creative",
                selectedValue: provider.domain,
                onTap: () => provider.setDomain("creative"),
              ),
              
              _buildOptionCard(
                context: context,
                emoji: "📊",
                title: "Business",
                subtitle: "Marketing, management, entrepreneurship",
                value: "business",
                selectedValue: provider.domain,
                onTap: () => provider.setDomain("business"),
              ),
              
              _buildOptionCard(
                context: context,
                emoji: "🧘",
                title: "Wellness",
                subtitle: "Fitness, mindfulness, personal growth",
                value: "wellness",
                selectedValue: provider.domain,
                onTap: () => provider.setDomain("wellness"),
              ),
              
              _buildOptionCard(
                context: context,
                emoji: "🛠️",
                title: "Hands-on",
                subtitle: "Cooking, crafts, practical skills",
                value: "hands_on",
                selectedValue: provider.domain,
                onTap: () => provider.setDomain("hands_on"),
              ),
              
              _buildOptionCard(
                context: context,
                emoji: "📚",
                title: "Academic",
                subtitle: "Research, languages, humanities",
                value: "academic",
                selectedValue: provider.domain,
                onTap: () => provider.setDomain("academic"),
              ),
              
              _buildOptionCard(
                context: context,
                emoji: "🌱",
                title: "Exploring",
                subtitle: "Just curious, no specific direction",
                value: "exploring",
                selectedValue: provider.domain,
                onTap: () => provider.setDomain("exploring"),
              ),
              
              const SizedBox(height: 30),
              
              // Next button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.domain.isNotEmpty
                      ? () => Navigator.pushNamed(context, '/intensity')
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Extra bottom padding
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