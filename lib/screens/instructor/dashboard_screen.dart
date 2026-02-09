import 'package:flutter/material.dart';
import 'dart:io' as dart_io;
import 'package:provider/provider.dart';
import '../../widgets/course_card.dart';
import '../../services/course_service.dart';
import '../../services/auth_service.dart';
import '../../models/course_model.dart';
import 'create_course_screen.dart';
import 'edit_course_screen.dart';
import 'student_list_screen.dart';
import '../reviews/reviews_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final courseService = Provider.of<CourseService>(context, listen: false); // Listen false for method calls, StreamBuilder for data
    final user = authService.userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: Consumer<CourseService>(
        builder: (context, courseService, child) {
          final courses = courseService.getInstructorCourses(user?.uid ?? '');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStats(courses),
                const SizedBox(height: 24),
                const Text("Recent Courses", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...courses.take(3).map((course) => Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          CourseCard(
                            course: course,
                            onTap: () {
                                 Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditCourseScreen(course: course),
                                      ),
                                    );
                            },
                          ),
                          Container(
                            color: Colors.grey[50],
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _ActionButton(
                                  icon: Icons.people,
                                  label: "Students",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => StudentListScreen(courseId: course.id)),
                                    );
                                  },
                                ),
                                _ActionButton(
                                  icon: Icons.star,
                                  label: "Reviews",
                                  onTap: () {
                                    // Navigate to review screen
                                    // Assuming ReviewsScreen takes a list or courseId. 
                                    // Let's check how it's used elsewhere. 
                                    // CourseDetail calls it with list. 
                                    // We should fetch list or pass courseId if it supported it.
                                    // For now fetching list here as quick fix.
                                    final reviews = courseService.getReviews(course.id);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => CourseReviewsScreen(reviews: reviews)),
                                    );
                                  },
                                ),
                                _ActionButton(
                                  icon: Icons.edit,
                                  label: "Edit",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => EditCourseScreen(course: course)),
                                    );
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
                 if (courses.isEmpty) const Text("No courses yet."),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats(List<Course> courses) {
    int totalStudents = courses.fold(0, (sum, course) => sum + course.students);
    double totalRevenue = courses.fold(0, (sum, course) => sum + (course.price * course.students));

    return Row(
      children: [
        Expanded(child: _StatCard(title: 'Revenue', value: '\$${totalRevenue.toStringAsFixed(0)}', icon: Icons.attach_money, color: Colors.green)),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(title: 'Students', value: totalStudents.toString(), icon: Icons.people, color: Colors.blue)),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(title: 'Courses', value: courses.length.toString(), icon: Icons.book, color: Colors.orange)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          children: [
            Icon(icon, size: 20, color: Colors.blueGrey),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
