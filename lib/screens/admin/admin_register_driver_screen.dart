import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminRegisterDriverScreen extends StatefulWidget {
  const AdminRegisterDriverScreen({super.key});

  @override
  _AdminRegisterDriverScreenState createState() =>
      _AdminRegisterDriverScreenState();
}

class _AdminRegisterDriverScreenState
    extends State<AdminRegisterDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Method to register a new driver to Firestore
  Future<void> _registerDriver() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('drivers').add({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': '+91${_phoneController.text.trim()}',
          'licenseNumber': _licenseController.text.trim(),
          'password': _passwordController.text.trim(),
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver registered successfully!')),
        );

        // Clear the form fields
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _licenseController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      } catch (e) {
        print('Error registering driver: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Validation methods
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the driver\'s name';
    }
    final nameRegex = RegExp(r'^[A-Z][a-z]*(\s[A-Z][a-z]*)*$');
    if (!nameRegex.hasMatch(value)) {
      return 'Each word should start with a capital letter';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@(gmail\.com|kletech\.ac\.in)$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email must end with @gmail.com or @kletech.ac.in';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the phone number';
    }
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Phone number must have exactly 10 digits after +91';
    }
    return null;
  }

  String? _validateLicense(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the license number';
    }
    final licenseRegex = RegExp(r'^[A-Z]{2}[0-9]{2}\s[0-9]{11}$');
    if (!licenseRegex.hasMatch(value)) {
      return 'License number must be in format KA23 20220004001';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the password';
    }
    final passwordRegex =
        RegExp(r'^(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>])[a-zA-Z\d!@#$%^&*(),.?":{}|<>]{8,}$');
    if (!passwordRegex.hasMatch(value)) {
      return 'Password must have 1 uppercase, 1 special character, and minimum length 8';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm the password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Driver'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Driver Name',
                    helperText: 'Enter full name (Each word starts with a capital letter)',
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 16),
                
                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    helperText: 'Must end with @gmail.com or @kletech.ac.in',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                
                // Phone Number Field
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixText: '+91 ',
                    helperText: 'Enter 10 digits without +91 prefix',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),
                const SizedBox(height: 16),
                
                // License Number Field
                TextFormField(
                  controller: _licenseController,
                  decoration: const InputDecoration(
                    labelText: 'License Number',
                    helperText: 'Format: KA23 20220004001',
                  ),
                  validator: _validateLicense,
                ),
                const SizedBox(height: 16),
                
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    helperText: '1 uppercase, 1 special character, min length 8',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),
                
                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    helperText: 'Must match the password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isConfirmPasswordVisible,
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 24),
                
                // Register Driver Button
                ElevatedButton(
                  onPressed: _registerDriver,
                  child: const Text('Register Driver'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
