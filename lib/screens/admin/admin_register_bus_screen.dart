import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminRegisterBusScreen extends StatefulWidget {
  final String? busId; // Optional busId for editing
  final String? busNumber; // Optional bus number for editing
  final String? numberPlate; // Optional number plate for editing

  const AdminRegisterBusScreen({
    super.key,
    this.busId,
    this.busNumber,
    this.numberPlate,
  });

  @override
  _AdminRegisterBusScreenState createState() =>
      _AdminRegisterBusScreenState();
}

class _AdminRegisterBusScreenState extends State<AdminRegisterBusScreen> {
  final TextEditingController _busNumberController = TextEditingController();
  final TextEditingController _numberPlateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If editing, set initial values
    if (widget.busId != null) {
      _busNumberController.text = widget.busNumber ?? '';
      _numberPlateController.text = widget.numberPlate ?? '';
    }
  }

  Future<void> _saveBus() async {
    final busNumber = _busNumberController.text;
    final numberPlate = _numberPlateController.text;

    if (busNumber.isNotEmpty && numberPlate.isNotEmpty) {
      if (widget.busId != null) {
        // Update bus if busId is passed (i.e., edit operation)
        await FirebaseFirestore.instance
            .collection('buses')
            .doc(widget.busId)
            .update({
          'busNumber': busNumber,
          'numberPlate': numberPlate,
          'updatedAt': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bus updated successfully!')),
        );
      } else {
        // Add new bus if busId is null (i.e., add operation)
        await FirebaseFirestore.instance.collection('buses').add({
          'busNumber': busNumber,
          'numberPlate': numberPlate,
          'createdAt': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bus added successfully!')),
        );
      }
      Navigator.pop(context); // Close the screen after saving
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.busId == null ? 'Add New Bus' : 'Edit Bus'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Space between the fields
            TextField(
              controller: _busNumberController,
              decoration: const InputDecoration(
                labelText: 'Bus Number',
              ),
            ),
            SizedBox(height: 20), // Adding space between fields

            TextField(
              controller: _numberPlateController,
              decoration: const InputDecoration(
                labelText: 'Number Plate',
              ),
            ),
            SizedBox(height: 20), // Adding space between fields

            ElevatedButton(
              onPressed: _saveBus,
              child: Text(widget.busId == null ? 'Add Bus' : 'Update Bus'),
            ),
          ],
        ),
      ),
    );
  }
}
