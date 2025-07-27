import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

    String userName = user.displayName ?? '';

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        userName = userData?['userName'] ?? user.email ?? 'Unknown User';
      } else {
        debugPrint(
            'Warning: User document not found for UID: ${user.uid}. Falling back to display name or email.');
        userName = user.email ?? 'Unknown User';
      }
    } catch (e) {
      debugPrint('Error fetching user document: $e. Falling back to display name or email.');
      userName = user.displayName ?? user.email ?? 'Unknown User';
    }

    // Add user to lesson's students subcollection
    await _firestore
        .collection('lessons')
        .doc(lessonId)
        .collection('joinedStudents')
        .doc(user.uid)
        .set({
      'joinedAt': FieldValue.serverTimestamp(),
      'userName': userName,
      'email': user.email ?? '',
      'uid': user.uid,
    });

    return 'Successfully joined the class!';
  }
}
