import 'package:care_sprout/Services/firebase_service.dart';
import 'package:care_sprout/Services/local_db_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ProgressManager {
  static String userId = 'guest';

  //Notifier for reset listeners
  static final ValueNotifier<int> _progressResetNotifier = ValueNotifier(0);
  static ValueNotifier<int> get progressResetNotifier => _progressResetNotifier;

  static Future<void> init() async {
    await LocalDBService.init();
    final user = FirebaseAuth.instance.currentUser;
    userId = user?.uid ?? 'guest';
  }

  // Returns the highest unlocked level for this category (prefers cloud but falls back to local)
  static Future<int> getUnlockedLevel(String category) async {
    try {
      final cloud = await FirebaseService.getUnlockedLevel(userId, category);
      if (cloud != null) {
        await LocalDBService.setUnlockedLevel(userId, category, cloud);
        return cloud;
      }
    } catch (_) {
      // ignore cloud errors, fallback to local
    }
    // fallback to local
    return await LocalDBService.getUnlockedLevel(userId, category);
  }

  // If completedLevel >= currentUnlocked, unlock next level (but not beyond maxLevels)
  static Future<void> unlockNextLevelIfNeeded(
      String category, int completedLevel, int maxLevels) async {
    final current = await LocalDBService.getUnlockedLevel(userId, category);
    if (completedLevel >= current && current < maxLevels) {
      final newUnlocked = current + 1;
      await LocalDBService.setUnlockedLevel(userId, category, newUnlocked);
      try {
        await FirebaseService.setUnlockedLevel(userId, category, newUnlocked);
      } catch (_) {}
    }
  }

  /// set unlocked level explicitly
  static Future<void> setUnlockedLevel(String category, int level) async {
    await LocalDBService.setUnlockedLevel(userId, category, level);
    try {
      await FirebaseService.setUnlockedLevel(userId, category, level);
    } catch (_) {}
  }

  //Reset Levels
  static Future<void> resetProgress() async {
    await LocalDBService.resetAll(userId);
    await LocalDBService.resetLockAnimations(userId);

    try {
      await FirebaseService.resetAll(userId);
    } catch (_) {
      // ignore cloud errors
    }
  }

  // Lock animation
  static Future<bool> hasLockAnimationPlayed(String category, int level) async {
    return await LocalDBService.getLockAnimationPlayed(userId, category, level);
  }

  static Future<void> markLockAnimationPlayed(
      String category, int level) async {
    await LocalDBService.setLockAnimationPlayed(userId, category, level);
  }
}
