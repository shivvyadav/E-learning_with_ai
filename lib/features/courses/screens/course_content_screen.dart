import 'package:e_learning_v1/features/courses/models/lesson_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lesson_provider.dart';
import '../models/course_model.dart';
import '../../../state/progress_provider.dart';
import 'video_player_screen.dart';

class CourseContentScreen extends StatefulWidget {
  final CourseModel course;

  const CourseContentScreen({super.key, required this.course});

  @override
  State<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<LessonProvider>(context, listen: false)
          .loadLessons(widget.course.id);
    });
  }

  String _formatDuration(Duration? duration) {
    if (duration == null || duration == Duration.zero) return '';

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutesPart = (duration.inMinutes % 60).toString().padLeft(2, '0');
      final secondsPart = seconds.toString().padLeft(2, '0');
      return '$hours:$minutesPart:$secondsPart';
    }

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  @override
  Widget build(BuildContext context) {
    final lessonProvider = Provider.of<LessonProvider>(context);
    final progressProvider = Provider.of<ProgressProvider>(context);
    final lessons = lessonProvider.lessons;
    final totalLessons = lessons.length;
    int completedCount = 0;
    for (final lesson in lessons) {
      if (progressProvider.isLessonCompleted(widget.course.id, lesson.id)) {
        completedCount++;
      }
    }
    final progressPercent = totalLessons > 0 ? (completedCount / totalLessons) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.course.title,
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Course Progress",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "${(progressPercent * 100).toInt()}% Complete",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progressPercent,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
                const SizedBox(height: 8),
                Text(
                  "$completedCount of $totalLessons lessons completed",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: lessons.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "No lessons available yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Course content will be updated soon",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                final isCompleted = progressProvider.isLessonCompleted(
                  widget.course.id,
                  lesson.id,
                );
                final savedPosition = progressProvider.getSavedPosition(
                  widget.course.id,
                  lesson.id,
                );
                final duration = lessonProvider.getLessonDuration(lesson.id);
                final durationText = _formatDuration(duration);
                final displayDuration = durationText.isNotEmpty
                    ? durationText
                    : (lesson.duration.isNotEmpty ? lesson.duration : "Coming soon");

                return _buildLessonCard(
                  lesson: lesson,
                  index: index + 1,
                  isCompleted: isCompleted,
                  savedPosition: savedPosition,
                  durationText: displayDuration,
                );
              },
            ),
    );
  }

  Widget _buildLessonCard({
    required LessonModel lesson,
    required int index,
    required bool isCompleted,
    required int savedPosition,
    required String durationText,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted ? Colors.green.withOpacity(0.3) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(
                videoUrl: lesson.videoUrl,
                title: lesson.title,
                courseId: widget.course.id,
                lessonId: lesson.id,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        )
                      : Text(
                          "$index",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
                            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? Colors.green.shade700 : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          durationText,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (savedPosition > 0 && !isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.play_arrow,
                                  size: 10,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  _formatResumeTime(savedPosition),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
                            Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.2)
                      : Colors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.replay : Icons.play_arrow,
                  size: 18,
                  color: isCompleted ? Colors.green : Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  String _formatResumeTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return "$minutes:${remainingSeconds.toString().padLeft(2, '0')}";
    }
    return "0:$remainingSeconds";
  }
}