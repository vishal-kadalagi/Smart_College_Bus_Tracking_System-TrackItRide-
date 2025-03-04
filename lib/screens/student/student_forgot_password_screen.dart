import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../shared/custom_textfield.dart';
import '../../shared/custom_button.dart';

class StudentForgotPasswordScreen extends StatefulWidget {
  const StudentForgotPasswordScreen({super.key});

  @override
  _StudentForgotPasswordScreenState createState() =>
      _StudentForgotPasswordScreenState();
}

class _StudentForgotPasswordScreenState
    extends State<StudentForgotPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final emailController = TextEditingController();
  bool isResetLinkSent = false;

  // Function to send password reset link
  Future<void> sendResetLink() async {
    final email = emailController.text.trim();

    // Validate email format and domain
    if (!email.endsWith('@kletech.ac.in')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please use a valid kletech.ac.in email.'),
        ),
      );
      return;
    }

    try {
      // Attempt to send a password reset email
      await _auth.sendPasswordResetEmail(email: email);

      setState(() {
        isResetLinkSent = true; // Update UI to reflect reset link was sent
      });

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Password Reset Email Sent'),
          content: const Text(
              'A password reset email has been sent to your registered email address. '
              'Please check your inbox and follow the instructions to reset your password.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/student_login');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email not found.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isResetLinkSent) ...[
              CustomTextField(
                label: 'Email',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 30),
              CustomButton(
                label: 'Send Reset Link',
                onPressed: sendResetLink,
              ),
            ],
            if (isResetLinkSent)
              const Text(
                'A password reset link has been sent to your email address. '
                'Please follow the instructions in the email to reset your password.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
