import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Lesson {
  final String id;
  final String name;
  final String color;
  final Timestamp createdAt;

  Lesson({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  factory Lesson.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Lesson(
      id: doc.id,
      name: data['name'] ?? '',
      color: data['color'] ?? '#dbeafe',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}

class Post {
  final String id;
  final String lessonId;
  final String name;
  final String text;
  final Timestamp createdAt;

  Post({
    required this.id,
    required this.lessonId,
    required this.name,
    required this.text,
    required this.createdAt,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      lessonId: data['lessonId'] ?? '',
      name: data['name'] ?? 'Admin',
      text: data['text'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}

class LessonService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get Lessons from the Firestore
  Stream<List<Lesson>> getLessonsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('lessons')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Lesson> lessons = [];
      for (var doc in snapshot.docs) {
        final joined = await doc.reference
            .collection('joinedStudents')
            .doc(user.uid)
            .get();
        if (joined.exists) {
          lessons.add(Lesson.fromFirestore(doc));
        }
      }
      return lessons;
    });
  }

  // Get a single lesson by ID
  Future<Lesson?> getLessonById(String lessonId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('lessons').doc(lessonId).get();
      if (doc.exists) {
        return Lesson.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting lesson: $e');
      return null;
    }
  }

  // Get posts for a specific lesson
  Stream<List<Post>> getPostsStream(String lessonId) {
    return _firestore
        .collection('lessons')
        .doc(lessonId)
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    });
  }

  // Add a new post to a lesson
  Future<void> addPost(String lessonId, String text, String authorName) async {
    try {
      await _firestore
          .collection('lessons')
          .doc(lessonId)
          .collection('posts')
          .add({
        'lessonId': lessonId,
        'name': authorName,
        'text': text,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Error adding post: $e');
      rethrow;
    }
  }

  // Convert hex color string to Color
  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
