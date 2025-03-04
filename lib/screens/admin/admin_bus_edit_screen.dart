import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminBusEditScreen extends StatefulWidget {
  final String busId;
  final String busNumber;
  final String numberPlate;

  const AdminBusEditScreen({
    super.key,
    required this.busId,
    required this.busNumber,
    required this.numberPlate,
  });

  @override
  _AdminBusEditScreenState createState() => _AdminBusEditScreenState();
}

class _AdminBusEditScreenState extends State<AdminBusEditScreen> {
  final _busNumberController = TextEditingController();
  final _numberPlateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _busNumberController.text = widget.busNumber;
    _numberPlateController.text = widget.numberPlate;
  }

  Future<void> _updateBus() async {
    final busNumber = _busNumberController.text;
    final numberPlate = _numberPlateController.text;

    if (busNumber.isEmpty || numberPlate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields!')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('buses').doc(widget.busId).update({
        'busNumber': busNumber,
        'numberPlate': numberPlate,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bus updated successfully!')),
      );

      Navigator.of(context).pop(); // Navigate back after successful bus update
    } catch (e) {
      print('Error updating bus: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating bus. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Bus'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _busNumberController,
              decoration: const InputDecoration(labelText: 'Bus Number'),
            ),
            TextField(
              controller: _numberPlateController,
              decoration: const InputDecoration(labelText: 'Number Plate'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateBus,
              child: const Text('Update Bus'),
            ),
          ],
        ),
      ),
    );
  }
}
