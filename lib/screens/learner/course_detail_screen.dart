import 'package:flutter/material.dart';
import 'dart:io' as dart_io;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/course_model.dart';
import '../../models/module_model.dart';
import '../../models/lesson_model.dart';
import '../../models/review_model.dart';
import '../../services/course_service.dart';
import '../reviews/reviews_screen.dart';
import '../payments/purchase_screen.dart';
import '../../services/auth_service.dart';
import 'lesson_player_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _isEnrolled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkEnrollment();
  }

  Future<void> _checkEnrollment() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final courseService = Provider.of<CourseService>(context, listen: false);
    final user = authService.userModel;

    if (user != null) {
      bool enrolled = await courseService.isEnrolled(user.uid, widget.course.id);
      if (mounted) {
        setState(() {
          _isEnrolled = enrolled;
          _isLoading = false;
        });
      }
    } else {
        if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _enroll() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.userModel;

    if (user != null) {
      // Navigate to Purchase Screen
      await Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => PurchaseScreen(course: widget.course))
      );
      // Calls checkEnrollment again when returning
      _checkEnrollment();
    } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please login to enroll")));
    }
  }

  void _openLesson(Lesson lesson) {
    if (_isEnrolled) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LessonPlayerScreen(lesson: lesson)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enroll to view content")));
    }
  }

  void _addReview() {
    final commentController = TextEditingController();
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Write a Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: 'Comment',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  const Text("Rating", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  Center(
                    child: Text(
                      "${rating.toInt()} Stars", 
                      style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text('Cancel')
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (commentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please write a comment")));
                      return;
                    }
                    
                    final authService = Provider.of<AuthService>(context, listen: false);
                    final courseService = Provider.of<CourseService>(context, listen: false);
                    final user = authService.userModel!;

                    final review = Review(
                      id: const Uuid().v4(),
                      userId: user.uid,
                      userName: user.name,
                      courseId: widget.course.id,
                      rating: rating,
                      comment: commentController.text,
                      timestamp: DateTime.now(),
                    );

                    await courseService.addReview(widget.course.id, review);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseService = Provider.of<CourseService>(context);

    return Scaffold(
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(widget.course.title, style: const TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 2, color: Colors.black)])),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.course.thumbnailUrl.isNotEmpty
                          ? (widget.course.thumbnailUrl.startsWith('http')
                              ? Image.network(
                                  widget.course.thumbnailUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                                )
                              : Image.file(
                                  dart_io.File(widget.course.thumbnailUrl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                                ))
                          : _buildPlaceholder(),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meta Row
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(widget.course.ratingAvg.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(width: 4),
                          Text("(${_generateReviewCount()})", style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(width: 16),
                          Icon(Icons.people, color: Colors.grey[600], size: 20),
                          const SizedBox(width: 4),
                          Text("${widget.course.totalStudents} students", style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text("Created by ${widget.course.instructorName}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text("\$${widget.course.price}", style: const TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      const Text("Description", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(widget.course.description, style: TextStyle(color: Colors.grey[800], height: 1.5)),
                      const SizedBox(height: 24),
                      
                      // Curriculum Section
                      const Text("Curriculum", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Consumer<CourseService>(
                        builder: (context, courseService, child) {
                          final modules = courseService.getModules(widget.course.id);
                          if (modules.isEmpty) return const Text("No modules yet.");
                          
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: modules.length,
                            itemBuilder: (context, index) {
                              final module = modules[index];
                              final lessons = courseService.getLessons(widget.course.id, module.id);
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade300)),
                                child: ExpansionTile(
                                  title: Text(module.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text("${lessons.length} lessons"),
                                  children: [
                                    Column(
                                      children: lessons.map((lesson) => ListTile(
                                        title: Text(lesson.title),
                                        leading: Icon(_isEnrolled ? Icons.play_circle_fill : Icons.lock, color: _isEnrolled ? Colors.blue : Colors.grey),
                                        onTap: () => _openLesson(lesson),
                                        dense: true,
                                      )).toList(),
                                    )
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      ),
                      
                      const SizedBox(height: 24),
                      const Text("Reviews", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (_isEnrolled)
                        ElevatedButton.icon(
                          onPressed: _addReview,
                          icon: const Icon(Icons.rate_review),
                          label: const Text("Write a Review"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0, side: const BorderSide(color: Colors.grey)),
                        ),
                      
                      Consumer<CourseService>(
                        builder: (context, courseService, child) {
                          final reviews = courseService.getReviews(widget.course.id);
                          if (reviews.isEmpty) return const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("No reviews yet."));

                          return Column(
                            children: [
                              ...reviews.take(3).map((r) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(child: Text(r.userName[0])),
                                title: Text(r.userName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < r.rating ? Colors.amber : Colors.grey[300]))),
                                    const SizedBox(height: 4),
                                    Text(r.comment),
                                  ],
                                ),
                              )).toList(),
                              if (reviews.length > 3)
                                TextButton(
                                  onPressed: () {
                                     Navigator.push(context, MaterialPageRoute(builder: (_) => CourseReviewsScreen(reviews: reviews)));
                                  },
                                  child: const Text("See All Reviews"),
                                ),
                            ],
                          );
                        }
                      ),
                      const SizedBox(height: 100), // Space for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
      bottomNavigationBar: _isEnrolled 
          ? null 
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _enroll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Enroll Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
    );
  }
  
  // Helper for mock review count since it's not in model
  int _generateReviewCount() {
    return (widget.course.ratingAvg * 10 + widget.course.title.length).toInt();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF69F0AE), Color(0xFF00E676)], // Light Green to Green Accent
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.white, size: 50),
      ),
    );
  }
}
