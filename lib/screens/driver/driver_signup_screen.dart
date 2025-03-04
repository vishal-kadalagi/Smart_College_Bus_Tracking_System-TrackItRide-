import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../shared/custom_textfield.dart';
import '../../shared/custom_button.dart';
// Import AppTheme for consistent theming

class DriverSignupScreen extends StatefulWidget {
  const DriverSignupScreen({super.key});

  @override
  _DriverSignupScreenState createState() => _DriverSignupScreenState();
}

class _DriverSignupScreenState extends State<DriverSignupScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController(text: '+91');
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final licenseNumberController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  // Email validation
  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  // Password validation
  bool isValidPassword(String password) {
    return RegExp(r'^(?=.*[A-Z])(?=.*\W)(?=.*[a-z]).{8,}$').hasMatch(password);
  }

  // Confirm password validation
  bool doPasswordsMatch() {
    return passwordController.text == confirmPasswordController.text;
  }

  // Function to sign up a new driver
  Future<void> _signUpDriver() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Create new user with email and password
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim());

        // Save driver details to Firestore
        await FirebaseFirestore.instance
            .collection('drivers')
            .doc(userCredential.user?.uid)
            .set({
          'name': nameController.text,
          'phone': phoneController.text,
          'email': emailController.text,
          'licenseNumber': licenseNumberController.text,
          'createdAt': Timestamp.now(),
        });

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Signup Successful'),
            content: const Text('Your driver account has been created.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pushReplacementNamed(context, '/driver_login');
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Input Field
                CustomTextField(
                  label: 'Full Name',
                  controller: nameController,
                  helperText: 'Enter full name (Each word starts with a capital letter)',
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                
                // Phone Number Input Field
                CustomTextField(
                  label: 'Phone Number',
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  helperText: 'Enter 10 digits without +91 prefix',
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Phone is required' : null,
                ),
                const SizedBox(height: 16),
                
                // Email Input Field
                CustomTextField(
                  label: 'Email',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  helperText: 'Must be a valid email address',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    } else if (!isValidEmail(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // License Number Input Field
                CustomTextField(
                  label: 'License Number',
                  controller: licenseNumberController,
                  helperText: 'Format: KA23 20220004001',
                  validator: (value) =>
                      value == null || value.isEmpty ? 'License is required' : null,
                ),
                const SizedBox(height: 16),
                
                // Password Input Field
                CustomTextField(
                  label: 'Password',
                  controller: passwordController,
                  obscureText: !_passwordVisible,
                  helperText: 'Password must have 1 uppercase, 1 special character, and min length 8',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    } else if (!isValidPassword(value)) {
                      return 'Password must include uppercase, special char, and 8+ chars';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Confirm Password Input Field
                CustomTextField(
                  label: 'Confirm Password',
                  controller: confirmPasswordController,
                  obscureText: !_confirmPasswordVisible,
                  helperText: 'Must match the password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    } else if (!doPasswordsMatch()) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                
                // Sign Up Button
                CustomButton(
                  label: 'Sign Up',
                  onPressed: _signUpDriver,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
