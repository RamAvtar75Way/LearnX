import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/course_service.dart';
import '../../models/course_model.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courseService = Provider.of<CourseService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Browse Courses')),
      body: StreamBuilder<List<Course>>(
        stream: courseService.getCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text("Error: ${snapshot.error}"));
          }

          final courses = snapshot.data ?? [];

          if (courses.isEmpty) {
            return const Center(child: Text("No courses available"));
          }

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.book, size: 40), // Placeholder for thumbnail
                  title: Text(course.title),
                  subtitle: Text("${course.instructorName} • \$${course.price}"),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseDetailScreen(course: course),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
