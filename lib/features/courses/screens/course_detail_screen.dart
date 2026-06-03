import 'package:e_learning_v1/features/courses/models/lesson_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../models/course_model.dart';
import '../providers/lesson_provider.dart';
import '../providers/course_provider.dart';
import 'enrollment_screen.dart';
import 'course_content_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseModel course;
  const CourseDetailScreen({super.key, required this.course});
  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _isPreviewExpanded = false;
  List<LessonModel> _previewLessons = [];
  bool _isLoadingPreview = false;
  bool _hasLoadedPreview = false;

  @override
  void initState() {
    super.initState();
    if (!widget.course.isEnrolled) {
      _loadPreviewLessons();
    }
  }
  Future<void> _loadPreviewLessons() async {
    if (_hasLoadedPreview) return;
    
    setState(() {
      _isLoadingPreview = true;
    });

    try {
      final lessonProvider = Provider.of<LessonProvider>(context, listen: false);
      await lessonProvider.loadLessons(widget.course.id);
      
      setState(() {
        _previewLessons = List.from(lessonProvider.lessons);
        _hasLoadedPreview = true;
        _isLoadingPreview = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPreview = false;
      });
      print("Error loading preview lessons: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnrolled = widget.course.isEnrolled;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.course.title,
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade700,
                    Colors.blue.shade900,
                  ],
                ),
              ),
              child: widget.course.imageUrl.isNotEmpty
                  ? CustomNetworkImage(
                      imageUrl: widget.course.imageUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      fallbackText: "Course Thumbnail",
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school,
                            size: 60,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.course.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.course.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                                    Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.course.isFree
                              ? Colors.green.withOpacity(0.15)
                              : Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.course.isFree ? "FREE" : "PAID",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: widget.course.isFree
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (!widget.course.isFree)
                        Text(
                          "Rs. ${widget.course.price}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isEnrolled
                              ? Colors.green.withOpacity(0.15)
                              : Colors.blue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isEnrolled ? Icons.check_circle : Icons.lock_open,
                              size: 14,
                              color: isEnrolled ? Colors.green : Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isEnrolled ? "Enrolled" : "Not Enrolled",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isEnrolled ? Colors.green : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
      
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isEnrolled) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseContentScreen(
                                course: widget.course,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EnrollmentScreen(
                                course: widget.course,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: isEnrolled ? Colors.green : Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEnrolled ? "Continue Learning" : "Enroll Now",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
          
                  if (!isEnrolled) ...[
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Text(
                      widget.course.description,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isEnrolled) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseContentScreen(
                                course: widget.course,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EnrollmentScreen(
                                course: widget.course,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: isEnrolled ? Colors.green : Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEnrolled ? "Continue Learning" : "Enroll Now",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                
                  if (!isEnrolled) ...[
                    const Divider(height: 32),
                                        InkWell(
                      onTap: () {
                        setState(() {
                          _isPreviewExpanded = !_isPreviewExpanded;
                          if (!_hasLoadedPreview && _isPreviewExpanded) {
                            _loadPreviewLessons();
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              _isPreviewExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Preview Course Content",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _previewLessons.isNotEmpty
                                  ? "${_previewLessons.length} lessons"
                                  : "Click to load",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    if (_isPreviewExpanded)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.05),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Enroll to access all lessons and start learning",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            if (_isLoadingPreview)
                              const Padding(
                                padding: EdgeInsets.all(32),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (_previewLessons.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(32),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.hourglass_empty,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        "Course content will be updated soon",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _previewLessons.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 0,
                                  color: Colors.grey.shade200,
                                ),
                                itemBuilder: (context, index) {
                                  final lesson = _previewLessons[index];
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.play_arrow,
                                            size: 18,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                lesson.title,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                lesson.duration.isNotEmpty
                                                    ? lesson.duration
                                                    : "Coming soon",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            "Preview",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                  ],
                  
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "What You'll Get",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureItem(
                          icon: Icons.video_library,
                          text: "Video Lessons",
                        ),
                        _buildFeatureItem(
                          icon: Icons.verified,
                          text: "Certificate of Completion\nWe will contact you to give certificate",
                        ),
                        _buildFeatureItem(
                          icon: Icons.access_time,
                          text: "Lifetime Access",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
    Widget _buildFeatureItem({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}