import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_search_screen.dart';
import 'student_location_screen.dart';
import 'student_routes_screen.dart';
import 'student_notifications_screen.dart';
import '../../shared/theme.dart'; // Import AppTheme for custom colors

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;

  // Widget options for the bottom navigation
  static final List<Widget> _widgetOptions = <Widget>[
    const HomePageContent(), // Custom Home Page Content with Feedback Option
    const StudentSearchScreen(), // The Search Screen
    const StudentLocationScreen(), // The Location Screen
    const StudentRoutesScreen(), // The Routes Screen
    const StudentNotificationsScreen(), // The Notifications Screen
  ];

  // Bottom navigation item selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Logout functionality
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      Navigator.pushNamedAndRemoveUntil(context, '/student_login', (route) => false); // Navigate to login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout Failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TrackItRide - Student Dashboard"),
        backgroundColor: AppTheme.primaryColor, // Use custom maroon color
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final confirmLogout = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );

              if (confirmLogout == true) {
                _logout();
              }
            },
          ),
        ],
      ),
      body: _widgetOptions[_selectedIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Location'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_bus), label: 'Routes'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
        ],
        currentIndex: _selectedIndex, // Track selected index
        selectedItemColor: Colors.white, // Selected item color
        unselectedItemColor: Colors.white70, // Unselected item color
        backgroundColor: AppTheme.primaryColor, // Maroon background for BottomNavigationBar
        onTap: _onItemTapped, // Set the on tap function to change views
        type: BottomNavigationBarType.fixed, // To ensure all icons are visible
      ),
    );
  }
}

// Custom Home Page Content Widget
class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final feedbackController = TextEditingController();

    Future<void> submitFeedback() async {
      final feedback = feedbackController.text;
      if (feedback.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback cannot be empty!')),
        );
        return;
      }

      try {
        // Save feedback to Firestore
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('feedbacks').add({
            'feedback': feedback,
            'userId': user.uid,
            'email': user.email,
            'timestamp': FieldValue.serverTimestamp(),
          });

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Thank You'),
              content: const Text('Thank you for your feedback.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(); // Close the dialog
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const StudentHomeScreen(),
                    )); // Navigate back to home screen
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You need to be logged in to submit feedback.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving feedback: ${e.toString()}')),
        );
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome to TrackItRide",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Track your rides, check routes, and get updates all in one place.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            const Text(
              "We Value Your Feedback",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Let us know about your experience.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                labelText: 'Your Feedback',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Submit Feedback',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
