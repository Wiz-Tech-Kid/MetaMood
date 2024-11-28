import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MentalHealthDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _usersCollection;

  MentalHealthDatabase() {
    _usersCollection = _firestore.collection('users');
  }

  Future<void> initializeUserActivities(String userId) async {
    final userActivities = _usersCollection.doc(userId).collection('activities');
    final batch = _firestore.batch();

    final defaultActivities = [
      {
        'title': 'Morning Meditation',
        'subtitle': '10 minutes of mindfulness',
        'time': '8:00 AM',
        'icon': Icons.self_improvement.codePoint,
        'completed': false,
        'date': DateTime.now(),
      },
      {
        'title': 'Gratitude Journal',
        'subtitle': 'Write 3 things you\'re grateful for',
        'time': '9:00 AM',
        'icon': Icons.book.codePoint,
        'completed': false,
        'date': DateTime.now(),
      },
      {
        'title': 'Exercise',
        'subtitle': '30 minutes of physical activity',
        'time': '4:00 PM',
        'icon': Icons.fitness_center.codePoint,
        'completed': false,
        'date': DateTime.now(),
      },
      {
        'title': 'Evening Reflection',
        'subtitle': 'Review your day',
        'time': '8:00 PM',
        'icon': Icons.nightlight_round.codePoint,
        'completed': false,
        'date': DateTime.now(),
      },
    ];

    for (var activity in defaultActivities) {
      final docRef = userActivities.doc();
      batch.set(docRef, activity);
    }

    await batch.commit();
  }

  // Initialize default achievements for a new user
  Future<void> initializeUserAchievements(String userId) async {
    final userAchievements = _usersCollection.doc(userId).collection('achievements');
    final batch = _firestore.batch();

    final defaultAchievements = [
      {
        'title': 'Early Bird',
        'description': 'Complete morning meditation 5 days in a row',
        'iconCode': Icons.wb_sunny.codePoint,
        'unlocked': false,
      },
      {
        'title': 'Gratitude Master',
        'description': 'Write in gratitude journal for 7 consecutive days',
        'iconCode': Icons.favorite.codePoint,
        'unlocked': false,
      },
      {
        'title': 'Exercise Champion',
        'description': 'Complete 10 exercise sessions',
        'iconCode': Icons.emoji_events.codePoint,
        'unlocked': false,
      },
      {
        'title': 'Mindfulness Warrior',
        'description': 'Complete all daily activities for a week',
        'iconCode': Icons.psychology.codePoint,
        'unlocked': false,
      },
    ];

    for (var achievement in defaultAchievements) {
      final docRef = userAchievements.doc();
      batch.set(docRef, achievement);
    }

    await batch.commit();
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    final userDoc = await _usersCollection.doc(userId).get();

    if (!userDoc.exists) {
      return {
        'totalActivitiesCompleted': 0,
        'achievementsUnlocked': 0,
        'currentStreak': 0,
      };
    }

    return userDoc.data() as Map<String, dynamic>;
  }

  // Update user statistics
  Future<void> updateUserStats(String userId, Map<String, dynamic> stats) async {
    await _usersCollection.doc(userId).set(stats, SetOptions(merge: true));
  }

  // Check and update achievements based on activity completion
  Future<void> checkAndUpdateAchievements(String userId) async {
    final activitiesSnapshot = await _usersCollection
        .doc(userId)
        .collection('activities')
        .where('completed', isEqualTo: true)
        .get();

    final achievementsSnapshot = await _usersCollection
        .doc(userId)
        .collection('achievements')
        .get();

    // Count consecutive days of morning meditation
    int meditationStreak = await _calculateMeditationStreak(userId);
    if (meditationStreak >= 5) {
      await _unlockAchievement(userId, 'Early Bird');
    }

    // Count consecutive days of gratitude journal
    int gratitudeStreak = await _calculateGratitudeStreak(userId);
    if (gratitudeStreak >= 7) {
      await _unlockAchievement(userId, 'Gratitude Master');
    }

    // Count total exercise sessions completed
    int exerciseCount = await _countCompletedExercises(userId);
    if (exerciseCount >= 10) {
      await _unlockAchievement(userId, 'Exercise Champion');
    }

    // Check for complete daily activities
    bool hasCompletedAllActivities = await _checkCompleteWeek(userId);
    if (hasCompletedAllActivities) {
      await _unlockAchievement(userId, 'Mindfulness Warrior');
    }
  }

  // Helper method to calculate meditation streak
  Future<int> _calculateMeditationStreak(String userId) async {
    final today = DateTime.now();
    final startDate = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 4));

    final querySnapshot = await _usersCollection
        .doc(userId)
        .collection('activities')
        .where('title', isEqualTo: 'Morning Meditation')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(DateTime(today.year, today.month, today.day)))
        .where('completed', isEqualTo: true)
        .get();

    // Process streak from results
    List<DateTime> completedDates = querySnapshot.docs
        .map((doc) => (doc.data()['date'] as Timestamp).toDate())
        .toList();

    completedDates.sort();
    int streak = 0;
    for (int i = 0; i < 5; i++) {
      if (completedDates.contains(today.subtract(Duration(days: i)))) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }


  // Helper method to calculate gratitude streak
  Future<int> _calculateGratitudeStreak(String userId) async {
    final today = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final query = await _usersCollection
          .doc(userId)
          .collection('activities')
          .where('title', isEqualTo: 'Gratitude Journal')
          .where('date', isEqualTo: Timestamp.fromDate(DateTime(date.year, date.month, date.day)))
          .where('completed', isEqualTo: true)
          .get();

      if (query.docs.isEmpty) break;
      streak++;
    }

    return streak;
  }

  // Helper method to count completed exercise sessions
  Future<int> _countCompletedExercises(String userId) async {
    final query = await _usersCollection
        .doc(userId)
        .collection('activities')
        .where('title', isEqualTo: 'Exercise')
        .where('completed', isEqualTo: true)
        .get();

    return query.docs.length;
  }

  // Helper method to check if all activities were completed for a week
  Future<bool> _checkCompleteWeek(String userId) async {
    final today = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final query = await _usersCollection
          .doc(userId)
          .collection('activities')
          .where('date', isEqualTo: Timestamp.fromDate(DateTime(date.year, date.month, date.day)))
          .get();

      final allCompleted = query.docs.every((doc) => doc.data()['completed'] == true);
      if (!allCompleted) return false;
    }

    return true;
  }

  // Helper method to unlock an achievement
  Future<void> _unlockAchievement(String userId, String achievementTitle) async {
    final achievementQuery = await _usersCollection
        .doc(userId)
        .collection('achievements')
        .where('title', isEqualTo: achievementTitle)
        .get();

    if (achievementQuery.docs.isNotEmpty) {
      final achievementDoc = achievementQuery.docs.first;
      if (!achievementDoc.data()['unlocked']) {
        await achievementDoc.reference.update({'unlocked': true});
      }
    }
  }

  // Reset daily activities
  Future<void> resetDailyActivities(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final batch = _firestore.batch();
    final activitiesRef = _usersCollection.doc(userId).collection('activities');

    final oldActivities = await activitiesRef
        .where('date', isLessThan: Timestamp.fromDate(startOfDay))
        .get();

    // Archive old activities if needed
    // ... (implementation for archiving)

    // Create new activities for today
    final defaultActivities = [
      {
        'title': 'Morning Meditation',
        'subtitle': '10 minutes of mindfulness',
        'time': '8:00 AM',
        'icon': Icons.self_improvement.codePoint,
        'completed': false,
        'date': Timestamp.fromDate(startOfDay),
      },
      // ... (other default activities)
    ];

    for (var activity in defaultActivities) {
      final docRef = activitiesRef.doc();
      batch.set(docRef, activity);
    }

    await batch.commit();
  }
}