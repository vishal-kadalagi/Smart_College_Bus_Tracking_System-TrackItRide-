import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  _DriverProfileScreenState createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  late Future<Map<String, dynamic>> _driverData;

  // Fetch driver data based on the current logged-in email
  Future<Map<String, dynamic>> fetchDriverData(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('drivers')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      }
      return {}; // Return empty if no data found
    } catch (e) {
      print("Error fetching driver data: $e");
      return {}; // Return empty in case of an error
    }
  }

  @override
  void initState() {
    super.initState();

    // Get the current user's email
    String? email = FirebaseAuth.instance.currentUser?.email;

    // Fetch driver data if email is not null
    if (email != null) {
      _driverData = fetchDriverData(email);
    } else {
      _driverData = Future.value({});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Profile'),
        automaticallyImplyLeading: false, // Remove back button
        backgroundColor:
            const Color.fromARGB(255, 132, 38, 6), // AppBar background color
        elevation: 0, // Remove shadow from AppBar
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _driverData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final driverData = snapshot.data;

          if (driverData == null || driverData.isEmpty) {
            return const Center(child: Text('No driver data found'));
          }

          // Display the driver's details in an attractive design
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color.fromARGB(255, 116, 30, 8),
                    child:
                        const Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    driverData['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    driverData['email'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Profile details section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileDetailRow('Phone:', driverData['phone']),
                        _buildProfileDetailRow(
                            'License Number:', driverData['licenseNumber']),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper method to build each profile detail row
  Widget _buildProfileDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$title ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Unknown',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
