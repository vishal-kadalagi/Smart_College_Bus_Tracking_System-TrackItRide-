import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../../shared/custom_textfield.dart';
import '../../shared/custom_button.dart';

class StudentSignupScreen extends StatefulWidget {
  const StudentSignupScreen({super.key});

  @override
  _StudentSignupScreenState createState() => _StudentSignupScreenState();
}

class _StudentSignupScreenState extends State<StudentSignupScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController(text: '+91');
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  String? _phoneError;

  bool isValidFullName(String name) {
    return RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)*$').hasMatch(name);
  }

  bool isValidPhoneNumber(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone.replaceFirst('+91', ''));
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@kletech\.ac\.in$').hasMatch(email);
  }

  bool isValidPassword(String password) {
    return RegExp(r'^(?=.*[A-Z])(?=.*\W)(?=.*[a-z]).{8,}$').hasMatch(password);
  }

  bool doPasswordsMatch() {
    return passwordController.text == confirmPasswordController.text;
  }

  Future<void> _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);

        await FirebaseFirestore.instance
            .collection('students')
            .doc(userCredential.user?.uid)
            .set({
          'name': nameController.text,
          'phone': phoneController.text,
          'email': emailController.text,
          'createdAt': Timestamp.now(),
        });

        // Show dialog after successful signup
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sign Up Successful'),
            content: const Text('Your account has been created successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login', // Navigate to the login screen
                    (route) => false, // Remove all previous routes
                  );
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
      appBar: AppBar(title: const Text('Student Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: 'Full Name (e.g., Xxxx Xxxx)',
                  controller: nameController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^[A-Za-z\s]*$')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Full Name is required';
                    } else if (!isValidFullName(value)) {
                      return 'Full Name must contain only alphabets and spaces';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Phone Number (Fixed +91, enter 10 digits)',
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^[0-9+]*$')),
                    LengthLimitingTextInputFormatter(13),
                  ],
                  onChanged: (value) {
                    setState(() {
                      if (!isValidPhoneNumber(value)) {
                        _phoneError =
                            'Phone Number must start with +91 and be followed by 10 digits';
                      } else {
                        _phoneError = null;
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone Number is required';
                    } else if (_phoneError != null) {
                      return _phoneError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Email (e.g., 02fe23bcs431@kletech.ac.in)',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    } else if (!isValidEmail(value)) {
                      return 'Email must end with @kletech.ac.in';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Password (At least 1 uppercase, 1 special character)',
                  controller: passwordController,
                  obscureText: !_passwordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
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
                      return 'Password must have uppercase, special character, lowercase, and be 8+ characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Confirm Password',
                  controller: confirmPasswordController,
                  obscureText: !_confirmPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
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
                CustomButton(
                  label: 'Sign Up',
                  onPressed: _signUp,
                  color: const Color.fromARGB(119, 20, 80, 198),
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
