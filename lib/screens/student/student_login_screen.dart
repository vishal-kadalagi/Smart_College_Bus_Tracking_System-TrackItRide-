import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../../shared/custom_textfield.dart';
import '../../shared/custom_button.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  _StudentLoginScreenState createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _passwordVisible = false; // Flag for password visibility

  // Handle login logic
  Future<void> handleLogin() async {
    try {
      // Attempt login with email and password
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Navigate to Home Screen after successful login
      Navigator.pushReplacementNamed(context, '/student_home');
    } on FirebaseAuthException catch (e) {
      // Show error message if login fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed', style: const TextStyle(color: Colors.red))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email Text Field
            CustomTextField(
              label: 'Email',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            // Password Text Field
            CustomTextField(
              label: 'Password',
              controller: passwordController,
              obscureText: !_passwordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
            ),
            const SizedBox(height: 30),
            // Login Button
            CustomButton(
              label: 'Login',
              onPressed: handleLogin, // Use the handleLogin function
            ),
            const SizedBox(height: 20),
            // Signup Link
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/student_signup'),
              child: const Text('If not registered, Signup', style: TextStyle(color: Colors.blue)),
            ),
            const SizedBox(height: 10),
            // Forgot Password Link
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/student_forgot_password'),
              child: const Text('Forgot Password?', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}
