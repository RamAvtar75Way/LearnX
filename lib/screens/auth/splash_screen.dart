import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2)); // Fake loading
    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    // AuthService initializes in main, but let's make sure user model is fetched
    await authService.initialize();
    
    // Navigation logic handled by wrapper in main or here. 
    // Usually Splash just waits for init.
    // I'll let the StreamBuilder in main handle navigation, but Splash is good for initial loading.
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text('LearnX', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
