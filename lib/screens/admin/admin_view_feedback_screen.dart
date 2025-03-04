import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/theme.dart'; // Import AppTheme for custom colors

class AdminViewFeedbackScreen extends StatelessWidget {
  const AdminViewFeedbackScreen({super.key});

  // Function to delete feedback from Firestore
  Future<void> _deleteFeedback(String feedbackId) async {
    try {
      await FirebaseFirestore.instance.collection('feedbacks').doc(feedbackId).delete();
    } catch (e) {
      print('Error deleting feedback: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Feedback'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('feedbacks') // Fetch from 'feedbacks' collection
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading feedback.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No feedback available.'));
          }

          final feedbackList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: feedbackList.length,
            itemBuilder: (context, index) {
              final feedback = feedbackList[index];
              final feedbackId = feedback.id; // Get the feedback document ID
              final feedbackText = feedback['feedback'] ?? 'No feedback provided.';
              final email = feedback['email'] ?? 'Anonymous';
              final timestamp = feedback['timestamp']?.toDate().toString() ?? 'Unknown';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(feedbackText),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('From: $email', style: TextStyle(color: Colors.grey[600])),
                      Text('Date: $timestamp', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteFeedback(feedbackId), // Delete the feedback
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
