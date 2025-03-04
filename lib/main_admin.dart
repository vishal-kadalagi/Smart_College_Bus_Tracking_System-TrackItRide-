import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:campus_go/firebase_options.dart'; // Firebase options for initialization
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_signup_screen.dart';
import 'screens/admin/admin_forgot_password_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart'; // Importing the new AdminDashboardScreen
import 'screens/admin/admin_manage_buses_screen.dart' as buses_screen;  // Alias for buses screen
import 'screens/admin/admin_manage_drivers_screen.dart' as drivers_screen; // Alias for drivers screen
import 'screens/admin/admin_driver_edit_screen.dart';    // Ensure this import is correct
import 'screens/admin/admin_register_driver_screen.dart'; // Ensure this import is correct
import 'screens/admin/admin_route_management_screen.dart';
import 'screens/admin/admin_analytics_screen.dart';
import 'screens/admin/admin_view_feedback_screen.dart';
import 'screens/admin/assign_bus_route_screen.dart'; // Import the AssignBusRouteScreen
import 'shared/theme.dart';

void main() async {
  // Ensure Flutter bindings are initialized before Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific configurations
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Start the app
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NavGo Admin',
      theme: AppTheme.themeData, // Centralized theme
      debugShowCheckedModeBanner: false, // Disable debug banner
      initialRoute: '/admin_login', // Initial screen set to login

      // Define all routes for the admin module
      routes: {
        '/admin_login': (context) => const AdminLoginScreen(),
        '/admin_signup': (context) => const AdminSignupScreen(),
        '/admin_forgot_password': (context) => const AdminForgotPasswordScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(), // Add this route for the Admin Dashboard
        '/admin_manage_buses': (context) => const buses_screen.AdminManageBusesScreen(),  // AdminManageBusesScreen route with alias
        '/admin_manage_drivers': (context) => const drivers_screen.AdminManageDriversScreen(), // AdminManageDriversScreen route with alias
        '/admin_driver_edit': (context) => const AdminDriverEditScreen(
              driverId: '',
              name: '',
              email: '',
              phone: '',
              licenseNumber: '',
            ), // AdminDriverEditScreen route
        '/admin_register_driver': (context) => const AdminRegisterDriverScreen(),
        '/admin_route_management': (context) => const AdminRouteManagementScreen(),
        '/admin_analytics': (context) => const AdminAnalyticsScreen(),
        '/admin_view_feedback': (context) => const AdminViewFeedbackScreen(),
        '/assign_bus_route': (context) => const AssignBusRouteScreen(), // Add the AssignBusRouteScreen route
      },

      // Fallback for undefined routes
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const AdminLoginScreen(),
      ),
    );
  }
}
