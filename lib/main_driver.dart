import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:campus_go/firebase_options.dart';
import 'screens/driver/driver_login_screen.dart';
import 'screens/driver/driver_signup_screen.dart';
import 'screens/driver/driver_forgot_password_screen.dart';
import 'screens/driver/driver_dashboard_screen.dart' as dashboard; // Alias for dashboard
import 'screens/driver/driver_route_overview_screen.dart' as overview; // Alias for route overview
import 'screens/driver/driver_profile_screen.dart';
import 'screens/driver/driver_view_feedback_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized before Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the default options for the current platform (e.g., Android or iOS)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the application once Firebase is initialized
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NavGo - Driver', // The title of the app
      theme: ThemeData(
        primarySwatch: Colors.blue, // Theme customization (Blue color)
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black), // Use bodyMedium instead of bodyText2
        ),
      ),
      initialRoute: '/driver_login', // Initial route when the app starts
      onGenerateRoute: (settings) {
        // Route generation based on the route name
        switch (settings.name) {
          case '/driver_login':
            return MaterialPageRoute(
                builder: (context) => const DriverLoginScreen());
          case '/driver_signup':
            return MaterialPageRoute(
                builder: (context) => const DriverSignupScreen());
          case '/driver_forgot_password':
            return MaterialPageRoute(
                builder: (context) => const DriverForgotPasswordScreen());
          case '/driver_dashboard':
            return MaterialPageRoute(
                builder: (context) => const dashboard.DriverDashboardScreen());
          case '/driver_route_overview':
            // Extract arguments passed through the route
            if (settings.arguments is Map<String, String>) {
              final args = settings.arguments as Map<String, String>;
              final driverEmail = args['driverEmail']!;
              final busNumber = args['busNumber']!;
              final routeName = args['routeName']!;
              final busId = args['busId']!;
              final routeId = args['routeId']!;

              // Return the DriverRouteOverviewScreen with the extracted arguments
              return MaterialPageRoute(
                builder: (context) => overview.DriverRouteOverviewScreen(
                  driverEmail: driverEmail,
                  busNumber: busNumber,
                  routeName: routeName,
                  busId: busId,
                  routeId: routeId, // Pass routeId to the screen
                ),
              );
            }
            // If arguments are not passed correctly, return an error screen or fallback screen
            return MaterialPageRoute(
                builder: (context) => const DriverLoginScreen()); 
          case '/driver_profile':
            return MaterialPageRoute(
                builder: (context) => const DriverProfileScreen());
          case '/driver_view_feedback':
            return MaterialPageRoute(
                builder: (context) => const DriverViewFeedbackScreen());
          default:
            return MaterialPageRoute(
                builder: (context) => const DriverLoginScreen()); // Default route
        }
      },
    );
  }
}
