import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/course_service.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class StudentListScreen extends StatelessWidget {
  final String courseId;

  const StudentListScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enrolled Students")),
      body: Consumer<CourseService>(
        builder: (context, courseService, child) {
          final students = courseService.getEnrolledStudents(courseId);

          if (students.isEmpty) {
            return const Center(child: Text("No students enrolled yet."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            separatorBuilder: (c, i) => const Divider(),
            itemBuilder: (context, index) {
              final student = students[index];
              // Fallback to AuthService lookup if name is missing (for legacy data)
              final String? storedName = student['userName'];
              final String? storedEmail = student['userEmail'];
              final String userId = student['userId'];
              final enrolledAt = DateTime.tryParse(student['enrolledAt'] ?? '');

              if (storedName != null && storedName.isNotEmpty) {
                 return _buildStudentTile(storedName, storedEmail ?? "No Email", enrolledAt);
              }

              // Legacy data lookup
              return FutureBuilder<UserModel?>(
                future: Provider.of<AuthService>(context, listen: false).getUserById(userId),
                builder: (context, snapshot) {
                  final name = snapshot.data?.name ?? "Unknown User";
                  final email = snapshot.data?.email ?? "No Email";
                  return _buildStudentTile(name, email, enrolledAt);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStudentTile(String name, String email, DateTime? enrolledAt) {
    return ListTile(
        leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?')),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(email),
        trailing: enrolledAt != null 
            ? Text("Enrolled: ${enrolledAt.day}/${enrolledAt.month}/${enrolledAt.year}", style: const TextStyle(fontSize: 12, color: Colors.grey))
            : null,
    );
  }
}
