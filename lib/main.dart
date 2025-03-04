import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:campus_go/firebase_options.dart'; // Import for Firebase options
import 'package:campus_go/screens/admin/admin_forgot_password_screen.dart';
import 'package:campus_go/screens/admin/admin_signup_screen.dart';
import 'package:campus_go/screens/driver/driver_forgot_password_screen.dart';
import 'package:campus_go/screens/driver/driver_signup_screen.dart';
import 'package:campus_go/screens/student/student_forgot_password_screen.dart';
import 'package:campus_go/screens/student/student_signup_screen.dart';
import 'screens/student/student_login_screen.dart';
import 'screens/driver/driver_login_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'shared/theme.dart';

void main() async {
  // Initialize Firebase before running the app
  WidgetsFlutterBinding.ensureInitialized();  // Ensure binding is initialized before Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Correct way to initialize Firebase
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NavGo App',
      theme: AppTheme.themeData, // Centralized theme
      initialRoute: '/student_login',
      routes: {
        '/student_login': (context) => const StudentLoginScreen(),
        '/student_signup': (context) => const StudentSignupScreen(),
        '/student_forgot_password': (context) => const StudentForgotPasswordScreen(),
        '/driver_login': (context) => const DriverLoginScreen(),
        '/driver_signup': (context) => const DriverSignupScreen(),
        '/driver_forgot_password': (context) => const DriverForgotPasswordScreen(),
        '/admin_login': (context) => const AdminLoginScreen(),
        '/admin_signup': (context) => const AdminSignupScreen(),
        '/admin_forgot_password': (context) => const AdminForgotPasswordScreen(),
      },
    );
  }
}
