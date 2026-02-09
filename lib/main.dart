
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_base/l10n/app_localizations.dart';
import 'services/auth_service.dart';
import 'services/course_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/learner/learner_main_screen.dart';
import 'screens/instructor/instructor_main_screen.dart';

import 'services/service_locator.dart';
import 'services/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CourseService()),
      ],
      child: MaterialApp(
        navigatorKey: getIt<Navigation>().navigatorKey,
        title: 'LearnX',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
          Locale('ar'),
        ],
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const RoleSelectionScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return StreamBuilder<bool>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(); // Initial check
        }

        if (snapshot.hasData && snapshot.data == true) {
           if (authService.userModel == null) {
              return FutureBuilder(
                future: authService.initialize(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return _getHome(authService.userModel?.role);
                  }
                  return const SplashScreen();
                }
              );
           } else {
             return _getHome(authService.userModel?.role);
           }
        }
        
        return const WelcomeScreen();
      },
    );
  }

  Widget _getHome(String? role) {
    if (role == 'instructor') {
       return const InstructorMainScreen(); 
    } else {
       return const LearnerMainScreen();
    }
  }
}
