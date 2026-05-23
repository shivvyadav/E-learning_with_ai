import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/questionnaire_provider.dart';

class PedagogyScreen extends StatelessWidget {
  const PedagogyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestionnaireProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Step 4 of 6"),
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
                "How do you prefer to learn?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                "Choose the learning style that works best for you.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              _buildOptionCard(
                context: context,
                emoji: "🗺️",
                title: "Structured Learning",
                subtitle: "Step-by-step guidance, clear milestones, deadlines",
                value: "structured",
                selectedValue: provider.pedagogy,
                onTap: () => provider.setPedagogy("structured"),
              ),
              
              _buildOptionCard(
                context: context,
                emoji: "🔧",
                title: "Exploratory Learning",
                subtitle: "Learn by doing, projects, hands-on experimentation",
                value: "exploratory",
                selectedValue: provider.pedagogy,
                onTap: () => provider.setPedagogy("exploratory"),
              ),
              
              _buildOptionCard(
                context: context,
                emoji: "⚖️",
                title: "Hybrid Approach",
                subtitle: "Structured modules with hands-on projects",
                value: "hybrid",
                selectedValue: provider.pedagogy,
                onTap: () => provider.setPedagogy("hybrid"),
              ),
              
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.pedagogy.isNotEmpty
                      ? () => Navigator.pushNamed(context, '/role')
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