import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'learner_home_screen.dart';
import 'search_screen.dart';
import 'my_courses_screen.dart';
import '../profile/profile_screen.dart';

class LearnerMainScreen extends StatefulWidget {
  const LearnerMainScreen({super.key});

  @override
  State<LearnerMainScreen> createState() => _LearnerMainScreenState();
}

class _LearnerMainScreenState extends State<LearnerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const LearnerHomeScreen(),
    const SearchScreen(),
    const MyCoursesScreen(), // My Courses
    const ProfileScreen(), // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'My Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
