import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDriverEditScreen extends StatefulWidget {
  final String driverId;
  final String name;
  final String email;
  final String phone;
  final String licenseNumber;

  const AdminDriverEditScreen({
    super.key,
    required this.driverId,
    required this.name,
    required this.email,
    required this.phone,
    required this.licenseNumber,
  });

  @override
  _AdminDriverEditScreenState createState() => _AdminDriverEditScreenState();
}

class _AdminDriverEditScreenState extends State<AdminDriverEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _licenseController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _licenseController = TextEditingController(text: widget.licenseNumber);
  }

  // Update the driver details in Firestore
  Future<void> _updateDriver() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('drivers').doc(widget.driverId).update({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'licenseNumber': _licenseController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver details updated successfully!')),
        );

        // Navigate back after update
        Navigator.of(context).pop();
      } catch (e) {
        print('Error updating driver: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating driver. Please try again.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Driver Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Adding space around the form
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Driver Name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Driver Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the driver\'s name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16), // Space between fields

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the email';
                    } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16), // Space between fields

                // Phone number field
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16), // Space between fields

                // License number field
                TextFormField(
                  controller: _licenseController,
                  decoration: const InputDecoration(
                    labelText: 'License Number',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the license number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24), // Extra space before the update button

                // Update button
                ElevatedButton(
                  onPressed: _updateDriver,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Update Driver'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
