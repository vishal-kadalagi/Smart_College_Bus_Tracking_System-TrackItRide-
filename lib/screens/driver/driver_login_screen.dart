import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../shared/custom_textfield.dart';
import '../../shared/custom_button.dart';
import '../../shared/theme.dart'; // Import AppTheme for consistent theming

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  _DriverLoginScreenState createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _isLoading = false; // For showing loading indicator

  // Login function for drivers
  Future<void> _loginDriver() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        // Sign in the user using email and password
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Fetch the driver details from Firestore based on email
        final driverEmail = userCredential.user?.email ?? '';
        
        // Debug: Ensure we are logging the correct user email
        print('Logged in as: $driverEmail');

        QuerySnapshot assignmentSnapshot = await FirebaseFirestore.instance
            .collection('drivers') // Changed to 'drivers' collection
            .where('email', isEqualTo: driverEmail)
            .limit(1) // Assuming one assignment per driver
            .get();

        // Debug: Check if the assignmentSnapshot is returned correctly
        if (assignmentSnapshot.docs.isNotEmpty) {
          final data = assignmentSnapshot.docs.first.data() as Map<String, dynamic>;

          // Extract the bus and route details from the assignment
          final busNumber = data['busNumber'] ?? 'N/A';
          final routeName = data['routeName'] ?? 'N/A';

          // Debug: Check bus and route details
          print('Bus Number: $busNumber');
          print('Route Name: $routeName');

          // Navigate to the driver dashboard with the bus and route data
          Navigator.pushReplacementNamed(
            context,
            '/driver_dashboard',
            arguments: {
              'driverEmail': driverEmail,
              'busNumber': busNumber,
              'routeName': routeName,
            },
          );
        } else {
          // If no assignment found for the driver
          setState(() {
            _isLoading = false; // Hide loading indicator
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No assignment found for this driver.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Login'),
        backgroundColor: AppTheme.primaryColor, // Maroon theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back, Driver!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please log in to access your dashboard.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Email input field
                CustomTextField(
                  label: 'Email',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Email is required' : null,
                ),
                const SizedBox(height: 16),
                
                // Password input field
                CustomTextField(
                  label: 'Password',
                  controller: passwordController,
                  obscureText: !_passwordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Password is required' : null,
                ),
                const SizedBox(height: 30),

                // Show loading indicator or login button
                _isLoading
                    ? const Center(child: CircularProgressIndicator()) // Show loading indicator
                    : CustomButton(
                        label: 'Login',
                        onPressed: _loginDriver,
                        color: AppTheme.primaryColor,
                        textColor: Colors.white,
                      ),
                
                const SizedBox(height: 10),

                // Forgot password link
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/driver_forgot_password');
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),

                // Sign up link
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/driver_signup');
                    },
                    child: const Text(
                      'Don\'t have an account? Sign Up',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
