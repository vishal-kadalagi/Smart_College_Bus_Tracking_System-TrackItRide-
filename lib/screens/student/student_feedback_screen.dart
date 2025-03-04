import 'package:flutter/material.dart';
import '../../services/feedback_service.dart';

class StudentFeedbackScreen extends StatelessWidget {
  const StudentFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Feedback"),
        backgroundColor: const Color(0xFF800000), // Maroon color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "We value your feedback!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Enter your feedback here",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final feedback = feedbackController.text;
                if (feedback.isNotEmpty) {
                  await FeedbackService().submitFeedback(
                    "student_id", // Replace with actual student ID from authentication
                    feedback,
                    "student",
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Feedback submitted successfully!")),
                  );
                  feedbackController.clear();
                }
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
