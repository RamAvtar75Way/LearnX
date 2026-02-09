import 'package:flutter/material.dart';
import 'dart:io' as dart_io;
import 'package:provider/provider.dart';
import '../../widgets/course_card.dart';
import '../../services/course_service.dart';
import '../../services/auth_service.dart';
import '../../models/course_model.dart';
import 'course_detail_screen.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final courseService = Provider.of<CourseService>(context);
    final user = authService.userModel;

    if (user == null) return const Center(child: Text("Not logged in"));

    return Scaffold(
      appBar: AppBar(title: const Text("My Courses")),
      body: Consumer<CourseService>(
        builder: (context, courseService, child) {
          final enrolledIds = courseService.getEnrolledCourseIds(user.uid);

          if (enrolledIds.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                   const SizedBox(height: 16),
                   const Text("You haven't enrolled in any courses yet."),
                   TextButton(onPressed: (){ 
                      // Navigate to Home tab?
                   }, child: const Text("Browse Courses"))
                 ],
               ),
             );
          }

          final allCourses = courseService.courses;
          final myCourses = allCourses.where((c) => enrolledIds.contains(c.id)).toList();
           
           return ListView.builder(
             padding: const EdgeInsets.all(16),
             itemCount: myCourses.length,
             itemBuilder: (context, index) {
               final course = myCourses[index];
               return CourseCard(
                 course: course,
                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course))),
               );
             },
           );
        },
      ),
    );
  }
}
