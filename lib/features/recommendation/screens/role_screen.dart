import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/questionnaire_provider.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestionnaireProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Step 5 of 6"),
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
                "What type of work energizes you?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                "This helps us find courses that match your natural strengths.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              _buildOptionCard(
                context: context,
                emoji: "🧩",
                title: "Solving Problems",
                subtitle: "Puzzles, logic, debugging, optimization",
                value: "problem_solving",
                selectedValue: provider.role,
                onTap: () => provider.setRole("problem_solving"),
              ),
              
              _buildOptionCard(
                context: context,
                emoji: "🎨",
                title: "Creating Things",
                subtitle: "Design, building, making, expressing",
                value: "creating",
                selectedValue: provider.role,
                onTap: () => provider.setRole("creating"),
              ),
              
              _buildOptionCard(
                context: context,
                emoji: "🤝",
                title: "Helping People",
                subtitle: "Teaching, coaching, support, service",
                value: "helping",
                selectedValue: provider.role,
                onTap: () => provider.setRole("helping"),
              ),
              
              _buildOptionCard(
                context: context,
                emoji: "👑",
                title: "Leading & Organizing",
                subtitle: "Strategy, management, planning, entrepreneurship",
                value: "leading",
                selectedValue: provider.role,
                onTap: () => provider.setRole("leading"),
              ),
              
              _buildOptionCard(
                context: context,
                emoji: "📊",
                title: "Analyzing Data",
                subtitle: "Research, patterns, insights, numbers",
                value: "analyzing",
                selectedValue: provider.role,
                onTap: () => provider.setRole("analyzing"),
              ),
              
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.role.isNotEmpty
                      ? () => Navigator.pushNamed(context, '/timeframe')
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