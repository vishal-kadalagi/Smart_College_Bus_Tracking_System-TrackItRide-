import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_register_driver_screen.dart'; // Import the registration screen
import 'admin_driver_edit_screen.dart' as drivers_screen; // Alias for the edit screen

class AdminManageDriversScreen extends StatefulWidget {
  const AdminManageDriversScreen({super.key});

  @override
  _AdminManageDriversScreenState createState() =>
      _AdminManageDriversScreenState();
}

class _AdminManageDriversScreenState extends State<AdminManageDriversScreen> {
  // Function to delete a driver
  Future<void> deleteDriver(String driverId) async {
    try {
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Driver deleted successfully!')),
      );
    } catch (e) {
      print('Error deleting driver: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting driver. Please try again.')),
      );
    }
  }

  // Confirm delete action before deletion
  void _confirmDeleteDriver(String driverId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Driver'),
        content: const Text('Are you sure you want to delete this driver?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              deleteDriver(driverId);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Drivers'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('drivers')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading drivers.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No drivers available.'));
          }

          final driverList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: driverList.length,
            itemBuilder: (context, index) {
              final driver = driverList[index];
              final driverId = driver.id;
              final name = driver['name'];
              final email = driver['email'];
              final phone = driver['phone'];
              final licenseNumber = driver['licenseNumber'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: $email', style: TextStyle(color: Colors.grey[600])),
                      Text('Phone: $phone', style: TextStyle(color: Colors.grey[600])),
                      Text('License: $licenseNumber', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => drivers_screen.AdminDriverEditScreen(
                                driverId: driverId,
                                name: name,
                                email: email,
                                phone: phone,
                                licenseNumber: licenseNumber,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteDriver(driverId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminRegisterDriverScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
