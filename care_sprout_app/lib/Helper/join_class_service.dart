import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinClassService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Attempts to join a lesson by code. Returns a success message or throws an error.
  Future<String> joinClassByCode(String code) async {
    final trimmedCode = code.trim().toUpperCase();
    if (trimmedCode.isEmpty) {
      throw Exception('Please enter a class code.');
    }

    // Find lesson with the given join code
    final query = await _firestore
        .collection('lessons')
        .where('joinCode', isEqualTo: trimmedCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Class code not found.');
    }

    final lessonId = query.docs.first.id;
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to join a class.');
    }

    // Check if already joined
    final studentDoc = await _firestore
        .collection('lessons')
        .doc(lessonId)
        .collection('joinedStudents')
        .doc(user.uid)
        .get();
    if (studentDoc.exists) {
      throw Exception('You have already joined this class.');
    }

    // Add user to lesson's students subcollection
    await _firestore
        .collection('lessons')
        .doc(lessonId)
        .collection('joinedStudents')
        .doc(user.uid)
        .set({
      'joinedAt': FieldValue.serverTimestamp(),
      'userName': user.displayName ?? '',
      'email': user.email ?? '',
    });

    return 'Successfully joined the class!';
  }
}
