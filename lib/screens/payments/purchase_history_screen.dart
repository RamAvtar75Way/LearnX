import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io'; 
import '../../services/auth_service.dart';
import '../../services/course_service.dart';
import '../../models/course_model.dart';

class PurchaseHistoryScreen extends StatelessWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final courseService = Provider.of<CourseService>(context);
    final user = authService.userModel;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // Get enrollments (which act as purchase history)
    final enrollments = courseService.getStudentEnrollments(user.uid);

    return Scaffold(
      appBar: AppBar(title: const Text("Purchase History")),
      body: enrollments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.history, size: 80, color: Colors.grey),
                   const SizedBox(height: 16),
                   Text("No purchases yet", style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: enrollments.length,
              separatorBuilder: (c, i) => const Divider(),
              itemBuilder: (context, index) {
                // Enrollment data
                final enrollment = enrollments[index];
                final courseId = enrollment['courseId'];
                final dateStr = enrollment['enrolledAt'];
                final date = DateTime.tryParse(dateStr ?? '') ?? DateTime.now();
                
                // Find course details
                final Course? course = courseService.courses.firstWhere(
                  (c) => c.id == courseId, 
                  orElse: () => Course(
                    id: 'unknown', 
                    title: 'Unknown Course', 
                    description: '', 
                    category: '', 
                    price: 0, 
                    thumbnailUrl: '', 
                    instructorId: '', 
                    instructorName: ''
                  )
                );

                // If course not found, use a placeholder but DON'T hide the item
                if (course == null || course.id == 'unknown') {
                   return ListTile(
                     leading: const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.error, color: Colors.white)),
                     title: const Text("Course Unavailable", style: TextStyle(color: Colors.grey)),
                     subtitle: Text("ID: $courseId\nPurchased on ${DateFormat.yMMMd().format(date)}"),
                     trailing: const Text("\$-.--", style: TextStyle(color: Colors.grey)),
                   );
                }

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: course.thumbnailUrl.startsWith('http')
                          ? Image.network(course.thumbnailUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.image))
                          : Image.file(File(course.thumbnailUrl), fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.image)),
                    ),
                  ),
                  title: Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Purchased on ${DateFormat.yMMMd().format(date)}"),
                  trailing: Text(
                    "\$${course.price.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                  ),
                );
              },
            ),
    );
  }
}
