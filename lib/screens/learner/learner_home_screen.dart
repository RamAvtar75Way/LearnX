import 'package:flutter/material.dart';
import 'dart:io' as dart_io;
import 'package:provider/provider.dart';
import '../../widgets/course_card.dart';
import '../../services/course_service.dart';
import '../../models/course_model.dart';
import 'course_detail_screen.dart';
import 'search_screen.dart';
import 'category_course_list_screen.dart';

class LearnerHomeScreen extends StatelessWidget {
  const LearnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courseService = Provider.of<CourseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LearnX'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar Mockup (Visual only, leads to SearchScreen)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                readOnly: true,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                decoration: InputDecoration(
                  hintText: "Search for courses...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),
            
            // Categories
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("Categories", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: ["Development", "Business", "Design", "Marketing", "Music"]
                    .map((cat) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ActionChip(
                            label: Text(cat),
                            onPressed: () {
                               Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryCourseListScreen(category: cat)));
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Featured Courses (Mocked as all courses for now, or filtered)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("Featured Courses", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: Consumer<CourseService>(
                builder: (context, courseService, child) {
                  final courses = courseService.courses;
                  if (courses.isEmpty) return const Center(child: Text("No courses available"));

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return CourseCard(
                        course: course,
                        isHorizontal: true,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course))),
                      );
                    },
                  );
                },
              ),
            ),
             const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
