import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../models/module_model.dart';
import '../models/lesson_model.dart';
import '../models/review_model.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CourseService with ChangeNotifier {
  SharedPreferences? _prefs;
  
  List<Course> _mockCourses = [];
  Map<String, List<Module>> _mockModules = {}; // courseId -> modules
  Map<String, List<Lesson>> _mockLessons = {}; // moduleId -> lessons
  List<Map<String, dynamic>> _mockEnrollments = [];
  List<Review> _mockReviews = [];

  CourseService() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Load Courses
    final coursesJson = _prefs?.getString('courses_db');
    if (coursesJson != null) {
      final List<dynamic> decoded = jsonDecode(coursesJson);
      _mockCourses = decoded.map((e) => Course.fromMap(e)).toList();
    } else {
      // Initialize Default Course if empty
      _mockCourses.add(Course(
        id: 'mock-1',
        title: 'Flutter for Beginners',
        description: 'Learn Flutter from scratch.',
        category: 'Development',
        price: 19.99,
        thumbnailUrl: 'https://picsum.photos/800/600',
        instructorId: 'mock-uid-123',
        instructorName: 'Test Instructor',
        ratingAvg: 4.5,
        totalStudents: 100,
      ));
      _saveToStorage();
    }

    // Load Modules
    final modulesJson = _prefs?.getString('modules_db');
    if (modulesJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(modulesJson);
      _mockModules = decoded.map((key, value) => MapEntry(
        key, 
        (value as List).map((e) => Module.fromMap(e)).toList()
      ));
    }

    // Load Lessons
    final lessonsJson = _prefs?.getString('lessons_db');
    if (lessonsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(lessonsJson);
      _mockLessons = decoded.map((key, value) => MapEntry(
        key, 
        (value as List).map((e) => Lesson.fromMap(e)).toList()
      ));
    }

    // Load Enrollments
    final enrollmentsJson = _prefs?.getString('enrollments_db');
    if (enrollmentsJson != null) {
       _mockEnrollments = List<Map<String, dynamic>>.from(jsonDecode(enrollmentsJson));
    }

    // Load Reviews
    final reviewsJson = _prefs?.getString('reviews_db');
    if (reviewsJson != null) {
      final List<dynamic> decoded = jsonDecode(reviewsJson);
      _mockReviews = decoded.map((e) => Review.fromMap(e)).toList();
    }

    // Load Downloads
    final downloadsJson = _prefs?.getString('downloads_db');
    if (downloadsJson != null) {
      _mockDownloadedLessons = List<String>.from(jsonDecode(downloadsJson));
    }

    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    if (_prefs == null) return;

    await _prefs!.setString('courses_db', jsonEncode(_mockCourses.map((e) => e.toMap()).toList()));
    
    // Convert Modules Map to JSON-friendly format
    final modulesMap = _mockModules.map((key, value) => MapEntry(key, value.map((e) => e.toMap()).toList()));
    await _prefs!.setString('modules_db', jsonEncode(modulesMap));

    // Convert Lessons Map
    final lessonsMap = _mockLessons.map((key, value) => MapEntry(key, value.map((e) => e.toMap()).toList()));
    await _prefs!.setString('lessons_db', jsonEncode(lessonsMap));

    await _prefs!.setString('enrollments_db', jsonEncode(_mockEnrollments));
    await _prefs!.setString('reviews_db', jsonEncode(_mockReviews.map((e) => e.toMap()).toList()));
    await _prefs!.setString('downloads_db', jsonEncode(_mockDownloadedLessons));
  }

  // --- Download Operations ---
  List<String> _mockDownloadedLessons = [];
  
  List<String> get downloadedLessonIds => _mockDownloadedLessons;

  bool isLessonDownloaded(String lessonId) {
    return _mockDownloadedLessons.contains(lessonId);
  }

  Future<void> toggleLessonDownload(String lessonId) async {
    if (_mockDownloadedLessons.contains(lessonId)) {
      _mockDownloadedLessons.remove(lessonId);
    } else {
      _mockDownloadedLessons.add(lessonId);
    }
    await _saveToStorage();
    notifyListeners();
  }

  // --- Course Operations ---

  // --- Course Operations ---

  List<Course> get courses => _mockCourses;

  Future<String?> createCourse(Course course) async {
    _mockCourses.add(course);
    await _saveToStorage();
    notifyListeners();
    return null;
  }

  // Stream<List<Course>> getCourses() {
  //   return Stream.value(_mockCourses);
  // }
  // Replaced with getter `courses`

  List<Course> getInstructorCourses(String instructorId) {
    return _mockCourses.where((c) => c.instructorId == instructorId).toList();
  }

  // Update Course (New)
  Future<String?> updateCourse(Course updatedCourse) async {
    final index = _mockCourses.indexWhere((c) => c.id == updatedCourse.id);
    if (index != -1) {
      _mockCourses[index] = updatedCourse;
      await _saveToStorage();
      notifyListeners();
      return null;
    }
    return "Course not found";
  }

  // Delete Course (New)
  Future<String?> deleteCourse(String courseId) async {
    _mockCourses.removeWhere((c) => c.id == courseId);
    _mockModules.remove(courseId);
    // Note: Deep cleaning lessons for modules of this course would be better but this is sufficient for mock
    await _saveToStorage();
    notifyListeners();
    return null;
  }

  // --- Module Operations ---

  List<Module> getModules(String courseId) {
    return _mockModules[courseId] ?? [];
  }

  Future<String?> addModule(String courseId, Module module) async {
    if (!_mockModules.containsKey(courseId)) _mockModules[courseId] = [];
    _mockModules[courseId]!.add(module);
    await _saveToStorage();
    notifyListeners();
    return null;
  }

  // --- Lesson Operations ---

  List<Lesson> getLessons(String courseId, String moduleId) {
    return _mockLessons[moduleId] ?? [];
  }

  Future<String?> addLesson(String courseId, String moduleId, Lesson lesson) async {
    if (!_mockLessons.containsKey(moduleId)) _mockLessons[moduleId] = [];
    _mockLessons[moduleId]!.add(lesson);
    await _saveToStorage();
    notifyListeners();
    return null;
  }

  // --- Enrollment Operations ---

  Future<void> enrollStudent(String userId, String userName, String userEmail, String courseId) async {
    if (await isEnrolled(userId, courseId)) return; // Prevent duplicates

    _mockEnrollments.add({
      'userId': userId, 
      'userName': userName,
      'userEmail': userEmail,
      'courseId': courseId,
      'enrolledAt': DateTime.now().toIso8601String(),
    });
    
    // Update local course student count
    final index = _mockCourses.indexWhere((c) => c.id == courseId);
    if (index != -1) {
      final old = _mockCourses[index];
      _mockCourses[index] = old.copyWith(totalStudents: old.totalStudents + 1);
    }
    await _saveToStorage();
    notifyListeners();
  }

  Future<bool> isEnrolled(String userId, String courseId) async {
    return _mockEnrollments.any((e) => e['userId'] == userId && e['courseId'] == courseId);
  }
  
  // --- Review Operations ---

  Future<void> addReview(String courseId, Review review) async {
    _mockReviews.add(review);
    
    // Update Course Rating Avg (Simple calculation)
    final courseReviews = _mockReviews.where((r) => r.courseId == courseId).toList();
    if (courseReviews.isNotEmpty) {
      final avg = courseReviews.map((e) => e.rating).reduce((a, b) => a + b) / courseReviews.length;
      final index = _mockCourses.indexWhere((c) => c.id == courseId);
      if (index != -1) {
         _mockCourses[index] = _mockCourses[index].copyWith(ratingAvg: avg);
      }
    }

    await _saveToStorage();
    notifyListeners();
  }

  List<Review> getReviews(String courseId) {
    return _mockReviews.where((r) => r.courseId == courseId).toList();
  }

  List<String> getEnrolledCourseIds(String userId) {
     return _mockEnrollments.where((e) => e['userId'] == userId).map((e) => e['courseId'] as String).toList();
  }

  List<Map<String, dynamic>> getEnrolledStudents(String courseId) {
    return _mockEnrollments.where((e) => e['courseId'] == courseId).toList();
  }
}
