import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitFeedback(String userId, String feedbackText, String userType) async {
    await _firestore.collection('feedback').add({
      'userId': userId,
      'feedbackText': feedbackText,
      'userType': userType, // 'student' or 'driver'
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getFeedback(String userType) {
    return _firestore
        .collection('feedback')
        .where('userType', isEqualTo: userType)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
