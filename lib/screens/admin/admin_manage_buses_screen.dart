import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_register_bus_screen.dart'; // Import the registration screen for bus

class AdminManageBusesScreen extends StatefulWidget {
  const AdminManageBusesScreen({super.key});

  @override
  _AdminManageBusesScreenState createState() => _AdminManageBusesScreenState();
}

class _AdminManageBusesScreenState extends State<AdminManageBusesScreen> {
  // Deleting a bus from the database
  Future<void> deleteBus(String busId) async {
    try {
      await FirebaseFirestore.instance.collection('buses').doc(busId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bus deleted successfully!')),
      );
    } catch (e) {
      print('Error deleting bus: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting bus. Please try again.')),
      );
    }
  }

  // Confirm delete action before deletion
  void _confirmDeleteBus(String busId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Bus'),
        content: const Text('Are you sure you want to delete this bus?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              deleteBus(busId);
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
        title: const Text('Manage Buses'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('buses') // Fetching buses from Firestore
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading buses.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No buses available.'));
          }

          final busList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: busList.length,
            itemBuilder: (context, index) {
              final bus = busList[index];
              final busId = bus.id; // Get the bus document ID
              final busNumber = bus['busNumber'];
              final numberPlate = bus['numberPlate'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('Bus Number: $busNumber'),
                  subtitle: Text('Number Plate: $numberPlate'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Button
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Navigate to the Edit screen and pass the bus data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminRegisterBusScreen(
                                busId: busId, // Pass busId for editing
                                busNumber: busNumber, // Pass busNumber for editing
                                numberPlate: numberPlate, // Pass numberPlate for editing
                              ),
                            ),
                          );
                        },
                      ),
                      // Delete Button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteBus(busId), // Show confirmation dialog
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
          // Navigate to the Bus Registration screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminRegisterBusScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
