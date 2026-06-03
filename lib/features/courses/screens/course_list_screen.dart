import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/custom_network_image.dart';
import '../providers/course_provider.dart';
import '../models/course_model.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  late Future _loadFuture;
  String _searchQuery = "";
  bool _isRefreshing = false;

  // NEW: flag to refresh only once
  bool _hasRefreshed = false;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadCourses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasRefreshed) {
      _hasRefreshed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onRefresh();
      });
    }
  }

  Future<void> _loadCourses() async {
    await Provider.of<CourseProvider>(context, listen: false).loadCourses();
  }

 
  // Pull to refresh functionality

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await Provider.of<CourseProvider>(context, listen: false).refreshCourses();
    } catch (e) {
      print("Error refreshing: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore Courses"),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder(
          future: _loadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allCourses = provider.courses;

            final filteredCourses = _searchQuery.isEmpty
                ? allCourses
                : allCourses
                    .where((c) => c.title
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList();

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// SEARCH BAR
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search courses",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),

                  const SizedBox(height: 20),

                  /// EMPTY STATE
                  if (filteredCourses.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_off,
                                size: 48,
                                color: Colors.grey),
                            const SizedBox(height: 12),
                            const Text("No courses found",
                                style: TextStyle(
                                    fontSize: 16)),
                            const SizedBox(height: 4),
                            const Text("Try another keyword",
                                style: TextStyle(
                                    color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  else
                    /// GRID VIEW
                    Expanded(
                      child: GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filteredCourses.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.72,
                        ),
                        itemBuilder: (context, index) {
                          final course = filteredCourses[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CourseDetailScreen(
                                          course: course),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(18),
                              ),
                              clipBehavior:
                                  Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  /// IMAGE
                                  Expanded(
                                    child: CustomNetworkImage(
                                      imageUrl: course.imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      fallbackText: "No Image",
                                      showText: false,
                                    ),
                                  ),

                                  Padding(
                                    padding:
                                        const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course.title,
                                          maxLines: 2,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.bold),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4),
                                          decoration: BoxDecoration(
                                            color: course.isFree
                                                ? Colors.green
                                                    .withOpacity(0.15)
                                                : Colors.orange
                                                    .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                          ),
                                          child: Text(
                                            course.isFree
                                                ? "FREE"
                                                : "PAID",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: course.isFree
                                                  ? Colors.green
                                                  : Colors.orange,
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}