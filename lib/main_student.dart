import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:campus_go/firebase_options.dart'; // Firebase options for initialization
import 'package:campus_go/screens/student/student_feedback_screen.dart';
import 'screens/student/student_login_screen.dart';
import 'screens/student/student_signup_screen.dart';
import 'screens/student/student_forgot_password_screen.dart';
import 'screens/student/student_home_screen.dart';
import 'screens/student/student_location_screen.dart';
import 'screens/student/student_notifications_screen.dart';
import 'screens/student/student_routes_screen.dart';
import 'screens/student/student_search_screen.dart';
import 'shared/theme.dart';

void main() async {
  // Ensure Flutter bindings are initialized before Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Start the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NavGo App',
      theme: AppTheme.themeData, // Centralized theme
      debugShowCheckedModeBanner: false, // Disable debug banner
      initialRoute: '/student_login', // Initial screen set to login

      // Define all routes for the app
      routes: {
        '/student_login': (context) => const StudentLoginScreen(),
        '/student_signup': (context) => const StudentSignupScreen(),
        '/student_forgot_password': (context) => const StudentForgotPasswordScreen(),
        '/student_home': (context) => const StudentHomeScreen(),
        '/student_location': (context) => const StudentLocationScreen(),
        '/student_notifications': (context) => const StudentNotificationsScreen(),
        '/student_search': (context) => const StudentSearchScreen(),
        '/student_routes': (context) => const StudentRoutesScreen(),
        '/student_feedback': (context) => const StudentFeedbackScreen(),
      },

      // Fallback for undefined routes
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const StudentLoginScreen(),
      ),
    );
  }
}
