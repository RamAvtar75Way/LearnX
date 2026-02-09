import 'package:flutter/material.dart';
import 'dart:io' as dart_io;
import 'package:provider/provider.dart';
import '../../widgets/course_card.dart';
import '../../services/course_service.dart';
import '../../services/auth_service.dart';
import '../../models/course_model.dart';
import 'create_course_screen.dart';
import 'edit_course_screen.dart';

class MyCreatedCoursesScreen extends StatelessWidget {
  const MyCreatedCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final courseService = Provider.of<CourseService>(context);
    final user = authService.userModel;

    if (user == null) return const Center(child: Text("Error: No user logged in"));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateCourseScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<CourseService>(
        builder: (context, courseService, child) {
          final courses = courseService.getInstructorCourses(user.uid);

          if (courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("You haven't created any courses yet."),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateCourseScreen()),
                      );
                    },
                    child: const Text("Create First Course"),
                  )
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return CourseCard(
                course: course,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditCourseScreen(course: course)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
