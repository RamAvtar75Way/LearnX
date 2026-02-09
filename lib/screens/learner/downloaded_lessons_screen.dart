import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/course_service.dart';
import 'lesson_player_screen.dart';

class DownloadedLessonsScreen extends StatelessWidget {
  const DownloadedLessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Downloads")),
      body: Consumer<CourseService>(
        builder: (context, courseService, child) {
          final downloadedIds = courseService.downloadedLessonIds;
          
          if (downloadedIds.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_done, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No downloads yet", style: TextStyle(color: Colors.grey, fontSize: 18)),
                  SizedBox(height: 8),
                  Text("Download lessons to watch offline.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // We need to find the lessons corresponding to IDs. 
          // In a real app with local DB, we'd query by ID. 
          // Here we have to search our mock data.
          // This is inefficient but fine for mock.
          
          final allCourses = courseService.courses;
          List<Map<String, dynamic>> downloadedLessons = [];

          for (var course in allCourses) {
             final modules = courseService.getModules(course.id);
             for (var module in modules) {
               final lessons = courseService.getLessons(course.id, module.id);
               for (var lesson in lessons) {
                 if (downloadedIds.contains(lesson.id)) {
                   downloadedLessons.add({
                     'lesson': lesson,
                     'courseTitle': course.title,
                     'moduleTitle': module.title
                   });
                 }
               }
             }
          }

          return ListView.builder(
            itemCount: downloadedLessons.length,
            itemBuilder: (context, index) {
              final item = downloadedLessons[index];
              final lesson = item['lesson'];
              
              return ListTile(
                leading: const Icon(Icons.video_library, color: Colors.blueAccent),
                title: Text(lesson.title),
                subtitle: Text("${item['courseTitle']} • ${item['moduleTitle']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    courseService.toggleLessonDownload(lesson.id);
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LessonPlayerScreen(lesson: lesson)),
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
