import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final _fs = FirebaseFirestore.instance;

  static Future<int?> getUnlockedLevel(String userId, String category) async {
    final doc = await _fs
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc(category)
        .get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    return (data['unlockedLevel'] as int?);
  }

  static Future<void> setUnlockedLevel(
      String userId, String category, int level) async {
    final docRef = _fs
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc(category);

    await _fs.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final current = (snap.data()?['unlockedLevel'] as int?) ?? 1;
      final next = level > current ? level : current;

      tx.set(
        docRef,
        {
          'unlockedLevel': next,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  /// 🔹 Reset all categories for a user in Firebase
  static Future<void> resetAll(String userId) async {
    final categories = [
      'Intervention',
      'Functional Academics',
      'Transitional',
      'Transition Livelihood Program',
      'Alphabet',
      'Numbers',
      'Colors',
      'Animals',
      'Shapes',
      'Memory',
    ];

    final batch = _fs.batch();
    final userRef = _fs.collection('users').doc(userId);

    for (final category in categories) {
      final docRef = userRef.collection('progress').doc(category);
      batch.set(
          docRef,
          {
            'unlockedLevel': 1,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    }

    await batch.commit();
  }
}
