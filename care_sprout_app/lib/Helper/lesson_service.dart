import 'dart:convert';

import 'package:care_sprout/Helper/downloads_database.dart';
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Lesson.fromJson(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      createdAt: Timestamp.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}

class Post {
  final String id;
  final String lessonId;
  final String name;
  final String text;
  final Timestamp createdAt;
  final List<Attachment> attachments;

  Post({
    required this.id,
    required this.lessonId,
    required this.name,
    required this.text,
    required this.createdAt,
    this.attachments = const [],
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<Attachment> parsedAttachments = [];
    if (data['attachments'] is List) {
      for (var attachmentMap in data['attachments']) {
        if (attachmentMap is Map<String, dynamic>) {
          parsedAttachments.add(Attachment.fromMap(attachmentMap));
        }
      }
    }
    return Post(
      id: doc.id,
      lessonId: data['lessonId'] ?? '',
      name: data['name'] ?? 'Admin',
      text: data['text'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      attachments: parsedAttachments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'name': name,
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'attachments': jsonEncode(attachments.map((a) => a.toMap()).toList()),
    };
  }

  factory Post.fromJson(Map<String, dynamic> map) {
    final attachmentsData = jsonDecode(map['attachments']) as List<dynamic>;
    return Post(
      id: map['id'],
      lessonId: map['lessonId'],
      name: map['name'],
      text: map['text'],
      createdAt: Timestamp.fromMillisecondsSinceEpoch(map['createdAt']),
      attachments: attachmentsData.map((a) => Attachment.fromMap(a)).toList(),
    );
  }
}

class Attachment {
  final String id;
  final String name;
  final String url;
  final String type;
  final String? format;
  final String? mimeType;

  Attachment({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    this.mimeType,
    this.format,
  });

  factory Attachment.fromMap(Map<String, dynamic> data) {
    return Attachment(
      id: data['id'],
      name: data['name'] ?? 'Untitled Attachment',
      url: data['url'] ?? '',
      type: data['type'] ?? 'file',
      mimeType: data['mimeType'],
      format: data['format'], // Optional, can be null
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'type': type,
      'mimeType': mimeType,
      'format': format, // Optional, can be null
    };
  }
}

class LessonService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Lesson>> getLessonsFromLocal() async {
    final lessonMaps = await DownloadsDatabase.instance.getLessons();
    return lessonMaps.map((map) => Lesson.fromJson(map)).toList();
  }

  Future<List<Post>> getPostsFromLocal(String lessonId) async {
    final postMaps =
        await DownloadsDatabase.instance.getPostsForLesson(lessonId);
    return postMaps.map((map) => Post.fromJson(map)).toList();
  }

  Future<Lesson?> getLessonByIdFromLocal(String lessonId) async {
    final lessonMaps = await DownloadsDatabase.instance.getLessons();
    final lessonMap = lessonMaps.firstWhere(
      (map) => map['id'] == lessonId,
      orElse: () => {},
    );
    if (lessonMap.isNotEmpty) {
      return Lesson.fromJson(lessonMap);
    }
    return null;
  }

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

      final lessonMaps = lessons.map((l) => l.toJson()).toList();
      await DownloadsDatabase.instance.cacheLessons(lessonMaps);

      return lessons;
    });
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
      final posts =
          snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();

      final postMaps = posts.map((p) => p.toJson()).toList();
      DownloadsDatabase.instance.cachePosts(lessonId, postMaps);

      return posts;
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
