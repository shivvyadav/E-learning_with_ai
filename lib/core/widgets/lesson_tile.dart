import 'package:flutter/material.dart';

class LessonTile extends StatelessWidget {
  final String title;
  final String duration;
  final VoidCallback? onTap; // Add this parameter

  const LessonTile({
    super.key,
    required this.title,
    required this.duration,
    this.onTap, // Accept it in constructor
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.play_circle_outline),
      title: Text(title),
      subtitle: Text(duration),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap ?? () { // Use external onTap if provided, otherwise default
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lesson \"$title\" clicked"),
          ),
        );
      },
    );
  }
}
