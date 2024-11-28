import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hacks/models/health_activity.dart';
import 'package:hacks/models/achievement.dart';

class MentalHealthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  MentalHealthService({required this.userId});

  Stream<List<MentalHealthActivity>> getTodayActivities() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('activities')
        .where('date', isEqualTo: startOfDay)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MentalHealthActivity.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Stream<List<Achievement>> getAchievements() {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Achievement.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> updateActivity(MentalHealthActivity activity) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc(activity.id)
        .set(activity.toMap());
  }

  Future<void> updateAchievement(Achievement achievement) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(achievement.id)
        .set(achievement.toMap());
  }
}